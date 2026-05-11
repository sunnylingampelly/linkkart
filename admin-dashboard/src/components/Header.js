import React from 'react';
import './Header.css';

function Header() {
  return (
    <header className="header">
      <div className="header-content">
        <h2 className="page-title">Platform Administration</h2>
        <div className="header-actions">
          <div className="admin-info">
            <span className="admin-name">Administrator</span>
            <span className="admin-email">SECURE ACCESS</span>
          </div>
        </div>
      </div>
    </header>
  );
}

export default Header;
