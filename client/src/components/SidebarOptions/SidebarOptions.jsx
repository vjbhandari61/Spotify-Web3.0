import React from "react";
import "./SidebarOptions.css";

function SidebarOptions({ title, Icon }) {
  return (
    <div className="sidebar__options">
      {Icon && <Icon className="sidebar__options__icon" />}
      {Icon ? <h4>{title}</h4> : <p>{title}</p>}
    </div>
  );
}

export default SidebarOptions;
