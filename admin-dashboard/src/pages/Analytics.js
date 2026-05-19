import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import './Analytics.css';

function Analytics() {
  const [analytics, setAnalytics] = useState([]);
  const [stores, setStores] = useState([]);
  const [loading, setLoading] = useState(true);
    const [stats, setStats] = useState({
        totalViews: 0,
        totalClicks: 0,
        conversionRate: 0
    });

    useEffect(() => {
        fetchAnalytics();
    }, []);

    const fetchAnalytics = async () => {
        try {
            setLoading(true);

            // Fetch analytics events - using the aliased endpoint
            const analyticsRes = await axios.get('https://api.linkkart.shop/analytics');
            const analyticsData = analyticsRes.data.data || [];

            // Fetch stores - using the aliased endpoint
            const storesRes = await axios.get('https://api.linkkart.shop/stores');
            const storesData = storesRes.data.data || [];

            setAnalytics(analyticsData);
            setStores(storesData);

            // Calculate stats
            const views = analyticsData.filter(a => a.event_type === 'store_view' || a.event_type === 'view').length;
            const clicks = analyticsData.filter(a => a.event_type === 'product_click' || a.event_type === 'click').length;
            const conversion = views > 0 ? ((clicks / views) * 100).toFixed(1) : 0;

            setStats({
                totalViews: views,
                totalClicks: clicks,
                conversionRate: conversion
            });

            setLoading(false);
        } catch (error) {
            console.error('Error fetching analytics:', error);
            setLoading(false);
        }
    };

    // Prepare chart data
    const getEventsByStore = () => {
        const storeEvents = {};

        stores.forEach(store => {
            const storeAnalytics = analytics.filter(a => a.store_id === store.id);
            storeEvents[store.name] = {
                name: store.name,
                views: storeAnalytics.filter(a => a.event_type === 'store_view' || a.event_type === 'view').length,
                clicks: storeAnalytics.filter(a => a.event_type === 'product_click' || a.event_type === 'click').length
            };
        });

        return Object.values(storeEvents);
    };

    const getEventsByDate = () => {
        const dateEvents = {};

        analytics.forEach(event => {
            // Use created_at as timestamp
            const date = new Date(event.created_at || event.timestamp).toLocaleDateString();
            if (!dateEvents[date]) {
                dateEvents[date] = { date, views: 0, clicks: 0 };
            }
            if (event.event_type === 'store_view' || event.event_type === 'view') {
                dateEvents[date].views++;
            } else if (event.event_type === 'product_click' || event.event_type === 'click') {
                dateEvents[date].clicks++;
            }
        });

        return Object.values(dateEvents).sort((a, b) => new Date(a.date) - new Date(b.date));
    };

  if (loading) {
    return (
      <div className="page-loading">
        <div className="spinner"></div>
        <p>Loading analytics...</p>
      </div>
    );
  }

  const storeData = getEventsByStore();
  const dateData = getEventsByDate();

  return (
    <div className="analytics-page">
      <div className="page-header">
        <div>
          <h1>Analytics Dashboard</h1>
          <p className="subtitle">Track store performance and user engagement</p>
        </div>
      </div>

      <div className="analytics-stats">
        <div className="stat-card">
          <div className="stat-icon views">
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
            </svg>
          </div>
          <div className="stat-content">
            <h3>Total Views</h3>
            <p className="stat-number">{stats.totalViews}</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon clicks">
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 15l-2 5L9 9l11 4-5 2zm0 0l5 5M7.188 2.239l.777 2.897M5.136 7.965l-2.898-.777M13.95 4.05l-2.122 2.122m-5.657 5.656l-2.12 2.122" />
            </svg>
          </div>
          <div className="stat-content">
            <h3>Total Clicks</h3>
            <p className="stat-number">{stats.totalClicks}</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon conversion">
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
          </div>
          <div className="stat-content">
            <h3>Conversion Rate</h3>
            <p className="stat-number">{stats.conversionRate}%</p>
          </div>
        </div>
      </div>

      <div className="charts-container">
        <div className="chart-card">
          <h2>Events Over Time</h2>
          {dateData.length > 0 ? (
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={dateData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                <XAxis dataKey="date" stroke="#6b7280" />
                <YAxis stroke="#6b7280" />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: '#fff', 
                    border: '1px solid #e5e7eb',
                    borderRadius: '8px'
                  }} 
                />
                <Legend />
                <Line type="monotone" dataKey="views" stroke="#5B6CFF" strokeWidth={2} name="Views" />
                <Line type="monotone" dataKey="clicks" stroke="#00C2A8" strokeWidth={2} name="Clicks" />
              </LineChart>
            </ResponsiveContainer>
          ) : (
            <div className="empty-chart">
              <p>No data available</p>
            </div>
          )}
        </div>

        <div className="chart-card">
          <h2>Events by Store</h2>
          {storeData.length > 0 ? (
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={storeData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                <XAxis dataKey="name" stroke="#6b7280" />
                <YAxis stroke="#6b7280" />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: '#fff', 
                    border: '1px solid #e5e7eb',
                    borderRadius: '8px'
                  }} 
                />
                <Legend />
                <Bar dataKey="views" fill="#5B6CFF" name="Views" />
                <Bar dataKey="clicks" fill="#00C2A8" name="Clicks" />
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <div className="empty-chart">
              <p>No data available</p>
            </div>
          )}
        </div>
      </div>

      <div className="events-table">
        <h2>Recent Events</h2>
        <div className="table-container">
          {analytics.length > 0 ? (
            <table className="data-table">
              <thead>
                <tr>
                  <th>Event Type</th>
                  <th>Store ID</th>
                  <th>Timestamp</th>
                </tr>
              </thead>
              <tbody>
                {analytics.slice(0, 20).map((event, index) => (
                  <tr key={index}>
                    <td>
                      <span className={`event-badge ${event.event_type}`}>
                        {event.event_type === 'view' ? '👁️' : '🖱️'} {event.event_type}
                      </span>
                    </td>
                    <td>#{event.store_id}</td>
                    <td>{new Date(event.timestamp).toLocaleString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <div className="empty-state">
              <p>No events recorded yet</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default Analytics;
