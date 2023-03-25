import React from "react";
import SidebarOptions from "../SidebarOptions/SidebarOptions";
import HomeIcon from "@mui/icons-material/Home";
import SearchIcon from "@mui/icons-material/Search";
import LibraryMusicIcon from "@mui/icons-material/LibraryMusic";
import AddBoxIcon from "@mui/icons-material/AddBox";
import LoyaltyIcon from "@mui/icons-material/Loyalty";
import LocalGroceryStoreIcon from "@mui/icons-material/LocalGroceryStore";

import "./Sidebar.css";

function Sidebar() {
  return (
    <div className="sidebar">
      <img
        className="sidebar__logo"
        src="https://getheavy.com/wp-content/uploads/2019/12/spotify2019-830x350.jpg"
        alt=""
      />
      <SidebarOptions title={"Home"} Icon={HomeIcon} />
      <SidebarOptions title={"Search"} Icon={SearchIcon} />
      <SidebarOptions title={"Your Library"} Icon={LibraryMusicIcon} />

      <br />
      <SidebarOptions title={"Create Playlist"} Icon={AddBoxIcon} />
      <SidebarOptions title={"Liked Songs"} Icon={LoyaltyIcon} />
      <SidebarOptions title={"MarketPlace"} Icon={LocalGroceryStoreIcon} />

      <br />
      <hr />
    </div>
  );
}

export default Sidebar;
