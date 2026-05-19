import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Stores.css';

function Stores() {
  const [stores, setStores] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    fetchStores();
  }, []);

  const fetchStores = async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('admin_token');
      const response = await axios.get('https://api.linkkart.shop/api/v1/stores', {
        headers: token ? { Authorization: `Bearer ${token}` } : {}
      });
      setStores(response.data.data || []);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching stores:', error);
      setLoading(false);
    }
  };

  const filteredStores = stores.filter(store =>
    (store.name || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
    (store.phone || '').includes(searchTerm)
  );

  if (loading) return (
    <div className="dashboard-loading">
      <div className="spinner"></div>
      <p>Loading Boutiques...</p>
    </div>
  );

  return (
    <div className="stores-page">
      <div className="page-header">
        <div>
          <h1>Boutiques Management</h1>
          <p className="subtitle">View and manage all registered digital stores</p>
        </div>
        <div className="header-actions">
           <div className="search-box">
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            <input
              type="text"
              placeholder="Search by name or phone..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
        </div>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Boutique</th>
              <th>Phone Number</th>
              <th>Status</th>
              <th>Registered Date</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {filteredStores.length > 0 ? (
              filteredStores.map(store => (
                <tr key={store.id}>
                  <td>
                    <div className="store-cell">
                      <div className="store-avatar">
                        {store.logo ? <img src={store.logo} alt="" /> : <span>{store.name.charAt(0)}</span>}
                      </div>
                      <div className="store-info">
                        <span className="font-semibold">{store.name}</span>
                        <span className="text-secondary" style={{fontSize: '12px', display: 'block'}}>slug: {store.slug}</span>
                      </div>
                    </div>
                  </td>
                  <td className="text-secondary">{store.phone}</td>
                  <td>
                    <span className={`status-badge ${store.is_active ? 'active' : 'pending'}`}>
                      {store.is_active ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                  <td className="text-secondary">{new Date(store.created_at).toLocaleDateString()}</td>
                  <td>
                    <div className="action-btns">
                      <a 
                        href={`https://linkkart.shop/store/${store.slug}`} 
                        target="_blank" 
                        rel="noopener noreferrer"
                        className="btn btn-outline"
                      >
                        Visit
                      </a>
                    </div>
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="5" className="empty-row">No boutiques found</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default Stores;
