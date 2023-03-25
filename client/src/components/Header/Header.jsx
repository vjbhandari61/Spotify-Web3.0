import React from "react";
import "./Header.css";
import SearchIcon from "@mui/icons-material/Search";
import { Avatar } from "@mui/material";

function Header() {
  return (
    <div className="header">
      <div className="header__left">
        <SearchIcon />
        <input
          type="text"
          placeholder="Search for Artists, Songs or Podcasts"
        />
      </div>

      <div className="header__right">
        <Avatar src="" alt="VJ" />
        <h4>Vijay Bhandari</h4>
      </div>
    </div>
  );
}

export default Header;
