import React from 'react';
import ToggleItem from './ToggleItem.jsx';

export default ({dataNav, changeClass=()=>{}}) => (
    <ul className="nav-dataset"> {dataNav.map(({id, text, use}) =>
      <li
        className={use}
        key={id}
        onClick={changeClass.bind(null, id)}
        >
        <ToggleItem
          className="vizName"
          value={text}
        />
      </li>
    )}</ul>
)
