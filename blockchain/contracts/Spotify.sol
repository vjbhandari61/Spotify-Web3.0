// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {SafeMath} from "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import {Counters} from "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IMusicNFT.sol" as IMusicNFT;

contract Spotify is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    IMusicNFT public musicNFT;
    address public owner;

    Counters.Counter private _saleCounter;
    Counters.Counter private _auctionCounter;

    struct Auction {
        address auctioneer;
        uint256 songId;
        uint256 reservedPrice;
        uint256 lastBid;
        address lastBidder;
        uint256 timeStarted;
        uint256 timeEnded;
    }

    struct Sale {
        address seller;
        uint256 songId;
        uint256 sellingPrice;
        uint256 timeStarted;
        uint256 timeEnded;
        bool sold;
    }

    mapping(uint256 => Auction) internal auctions;
    mapping(uint256 => Sale) internal sales;

    event SongCreated(address creator, string uri);
    event SongDeleted(address creator);
    event AuctionStarted(
        uint256 _auctionId,
        address _auctioneer,
        uint256 _reservedPrice,
        uint256 _timeStarted,
        uint256 _songId
    );
    event SongAuctioned(
        uint256 _auctionId,
        address _auctioneer,
        address _highestBidder,
        uint256 _songId
    );
    event AuctionEnded(
        uint256 _auctionId,
        address _auctioneer,
        uint256 _timeEnded,
        uint256 _songId
    );
    event BidCreated(
        uint256 _auctionId,
        address _bidder,
        uint256 _bidAmt,
        uint256 _songId
    );
    event SongSaleStarted(
        uint256 _saleId,
        address _seller,
        uint256 _sellingPrice,
        uint256 _timeStarted
    );
    event SongSold(
        uint256 _saleId,
        address _seller,
        address _buyer,
        uint256 _sellingPrice
    );

    constructor() {
        _disableInitializers();
        owner = msg.sender;
    }

    function addNFTAddress(address _musicNFT) public {
        require(owner == msg.sender, "Not Authorized!");
        musicNFT = IMusicNFT(_musicNFT);
    }

    function initialize() public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function createSong(string memory _tokenURI) public {
        musicNFT.newSong(tx.origin, _tokenURI);

        emit SongCreated(tx.origin, _tokenURI);
    }

    function deleteSong(uint256 _tokenId) public {
        musicNFT.deleteSong(_tokenId);

        emit SongDeleted(tx.origin);
    }

    function startAuction(
        uint256 reservedPrice,
        uint256 songId,
        uint256 timeEnded
    ) public {
        require(
            musicNFT.ownerOf(songId) != address(this),
            "Auction Already Exists!"
        );
        uint256 auctionId = _auctionCounter.current();
        _auctionCounter.increment();

        musicNFT.safeTransferFrom(tx.origin, address(this), songId);

        auctions[auctionId] = Auction(
            tx.origin,
            songId,
            reservedPrice,
            0,
            address(0),
            block.timestamp,
            timeEnded
        );

        emit AuctionStarted(
            auctionId,
            tx.origin,
            reservedPrice,
            block.timestamp,
            songId
        );
    }

    function createBid(uint256 auctionId) public payable {
        Auction memory auction = auctions[auctionId];
        require(auction.timeEnded >= block.timestamp, "Auction Ended!");
        require(
            msg.value >= auction.reservedPrice && msg.value >= auction.lastBid,
            "Cannot Bid Lower Than Previous Bid"
        );

        auction.lastBid = msg.value;
        auction.lastBidder = tx.origin;

        emit BidCreated(auctionId, tx.origin, msg.value, auction.songId);
    }

    function endAuction(uint256 auctionId) public {
        Auction memory auction = auctions[auctionId];
        uint256 creatorRoyalty = auction.lastBid.mul(5).div(100);
        uint256 auctionRevenue = auction.lastBid.mul(95).div(100);
        require(
            musicNFT.ownerOf(auction.songId) == address(this),
            "Auction Does Not Exist!"
        );
        require(auction.timeEnded <= block.timestamp, "Time Is Still Left!");

        musicNFT.safeTransferFrom(
            address(this),
            auction.lastBidder,
            auction.songId
        );
        payable(auction.auctioneer).transfer(auctionRevenue);
        payable(musicNFT.ownerOf(auction.songId)).transfer(creatorRoyalty);

        delete auctions[auctionId];

        emit AuctionEnded(
            auctionId,
            auction.auctioneer,
            block.timestamp,
            auction.songId
        );
    }

    function startSale(
        uint256 songId,
        uint256 sellingPrice,
        uint256 timeEnded
    ) public {
        require(
            musicNFT.ownerOf(songId) != address(this),
            "Auction Already Exists!"
        );
        uint256 saleId = _saleCounter.current();
        _saleCounter.increment();

        musicNFT.safeTransferFrom(tx.origin, address(this), songId);

        sales[saleId] = Sale(
            tx.origin,
            songId,
            sellingPrice,
            block.timestamp,
            timeEnded,
            false
        );

        emit SongSaleStarted(saleId, tx.origin, sellingPrice, block.timestamp);
    }

    function buySong(uint256 saleId) public {
        Sale memory sale = sales[saleId];
        uint256 creatorRoyalty = sale.sellingPrice.mul(5).div(100);
        uint256 saleRevenue = sale.sellingPrice.mul(95).div(100);
        require(
            musicNFT.ownerOf(sale.songId) == address(this),
            "Sale Does Not Exist!"
        );
        require(sale.timeEnded <= block.timestamp, "Time Is Still Left!");

        musicNFT.safeTransferFrom(address(this), tx.origin, sale.songId);
        payable(sale.seller).transfer(saleRevenue);
        payable(musicNFT.ownerOf(sale.songId)).transfer(creatorRoyalty);

        delete sales[saleId];

        emit SongSold(saleId, sale.seller, tx.origin, sale.songId);
    }

    function stopSale(uint256 saleId) public {
        Sale memory sale = sales[saleId];
        require(
            musicNFT.ownerOf(sale.songId) == address(this),
            "Sale Does Not Exist!"
        );
        require(sale.timeEnded <= block.timestamp, "Cannot Stop Sale Yet!");
        musicNFT.safeTransferFrom(address(this), tx.origin, sale.songId);

        emit SongSold(saleId, sale.seller, tx.origin, sale.songId);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function updateNFTAddress(
        IMusicNFT _musicNFT
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        musicNFT = IMusicNFT(_musicNFT);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}
}
