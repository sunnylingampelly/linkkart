import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Dashboard.css';

function Dashboard() {
  const [stats, setStats] = useState({
    totalStores: 0,
    totalRevenue: 0,
    totalClicks: 0
  });
  const [recentStores, setRecentStores] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('admin_token');
      const headers = token ? { Authorization: `Bearer ${token}` } : {};
      const storesRes = await axios.get('http://localhost:8000/api/v1/stores', { headers });
      const stores = storesRes.data.data || [];
      const paymentsRes = await axios.get('http://localhost:8000/api/v1/payments/history', { headers }).catch(() => ({ data: { data: [] } }));
      const payments = paymentsRes.data.data || [];
      const revenue = payments.filter(p => p.status === 'success').reduce((sum, p) => sum + Number(p.amount), 0);
      const analyticsRes = await axios.get('http://localhost:8000/api/v1/analytics', { headers }).catch(() => ({ data: { data: [] } }));
      const analytics = analyticsRes.data.data || [];
      const clicks = analytics.filter(a => a.event_type === 'click' || a.event_type === 'product_click').length;
      
      setStats({
        totalStores: stores.length,
        totalRevenue: revenue,
        totalClicks: clicks
      });
      setRecentStores(stores.slice(0, 5));
      setLoading(false);
    } catch (error) {
      console.error('Error fetching dashboard data:', error);
      setLoading(false);
    }
  };

  if (loading) return (
    <div className="dashboard-loading">
      <div className="spinner"></div>
      <p>Loading Dashboard...</p>
    </div>
  );

  return (
    <div className="dashboard">
      <div className="dashboard-header">
        <h1>Overview</h1>
        <p className="subtitle">Real-time performance metrics</p>
      </div>

      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-icon">
            <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
            </svg>
          </div>
          <div className="stat-info">
            <span className="stat-label">Boutiques</span>
            <h2 className="stat-value">{stats.totalStores}</h2>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon">
            <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div className="stat-info">
            <span className="stat-label">Revenue</span>
            <h2 className="stat-value">₹{stats.totalRevenue.toLocaleString()}</h2>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon">
            <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
            </svg>
          </div>
          <div className="stat-info">
            <span className="stat-label">Engagements</span>
            <h2 className="stat-value">{stats.totalClicks.toLocaleString()}</h2>
          </div>
        </div>
      </div>

      <div className="panel-header">
        <h3>Recent Boutiques</h3>
        <button className="btn btn-outline" style={{padding: '6px 16px', fontSize: '10px'}}>View All</button>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Store Name</th>
              <th>Phone</th>
              <th>Status</th>
              <th>Created</th>
            </tr>
          </thead>
          <tbody>
            {recentStores.map(store => (
              <tr key={store.id}>
                <td className="font-semibold">{store.name}</td>
                <td className="text-secondary">{store.phone}</td>
                <td>
                  <span className={`status-badge ${store.is_active ? 'active' : 'pending'}`}>
                    {store.is_active ? 'ACTIVE' : 'INACTIVE'}
                  </span>
                </td>
                <td className="text-secondary">{new Date(store.created_at).toLocaleDateString()}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default Dashboard;
