// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract MusicNFT is
    Initializable,
    ERC721Upgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    ERC721BurnableUpgradeable,
    UUPSUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    CountersUpgradeable.Counter private _tokenIdCounter;
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    struct Song {
        address creator;
        string url;
    }

    mapping(uint256 => Song) internal songs;

    modifier onlyOwner(uint256 _tokenId) {
        require(msg.sender == songs[_tokenId].creator);
        _;
    }

    constructor() {
        _disableInitializers();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function initialize() public initializer {
        __ERC721_init("MusicNFT", "mNFT");
        __Pausable_init();
        __AccessControl_init();
        __ERC721Burnable_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    /** Creates a new song nft */
    function newSong(
        address _to,
        string memory _tokenURI
    ) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_to, tokenId);

        songs[tokenId] = Song(_to, _tokenURI);
    }

    /** Delete song nft */
    function deleteSong(uint256 _tokenId) public onlyOwner(_tokenId) {
        burn(_tokenId);
        delete songs[_tokenId];
    }

    /** Find song details using token id*/
    function songsById(uint256 _tokenId) public view returns (Song memory) {
        require(songs[_tokenId].creator != address(0), "Invalid Token ID");
        return songs[_tokenId];
    }

    /** Return Base URI */
    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    /** Return Token URI */
    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        string memory uri = string.concat(_baseURI(), songs[_tokenId].url);
        return uri;
    }

    /** Pause All Contract Operations */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /** Unpause All Contract Operations */
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /** ------------------- Solidity Utility Functions ------------------------------------ */

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
