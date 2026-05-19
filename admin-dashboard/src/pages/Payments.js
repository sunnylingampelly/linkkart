import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Payments.css';

function Payments() {
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchPayments();
  }, []);

  const fetchPayments = async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('admin_token');
      const response = await axios.get('https://api.linkkart.shop/api/v1/payments/history', {
        headers: token ? { Authorization: `Bearer ${token}` } : {}
      });
      setPayments(response.data.data || []);
      setLoading(false);
    } catch (err) {
      console.error('Error fetching payments:', err);
      setError('Unable to load payment history.');
      setLoading(false);
    }
  };

  const totalRevenue = payments
    .filter(p => p.status === 'success')
    .reduce((sum, p) => sum + Number(p.amount), 0);

  if (loading) return (
    <div className="dashboard-loading">
      <div className="spinner"></div>
      <p>Loading Transactions...</p>
    </div>
  );

  return (
    <div className="payments-page">
      <div className="page-header">
        <div>
          <h1>Revenue & Transactions</h1>
          <p className="subtitle">Monitor platform subscription earnings</p>
        </div>
        <div className="revenue-card">
          <span className="label">Total Platform Revenue</span>
          <span className="amount">₹{totalRevenue.toLocaleString()}</span>
        </div>
      </div>

      {error && <div className="error-alert">{error}</div>}

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Date</th>
              <th>Boutique</th>
              <th>Plan</th>
              <th>Amount</th>
              <th>Order ID</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {payments.length > 0 ? (
              payments.map(payment => (
                <tr key={payment.id}>
                  <td className="text-secondary">{new Date(payment.created_at).toLocaleDateString()}</td>
                  <td className="font-semibold">{payment.store_name}</td>
                  <td>{payment.plan_name}</td>
                  <td className="font-semibold">₹{Number(payment.amount).toLocaleString()}</td>
                  <td className="text-secondary">{payment.razorpay_order_id}</td>
                  <td>
                    <span className={`status-badge ${payment.status}`}>
                      {payment.status}
                    </span>
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="6" className="empty-row">No transactions found</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default Payments;
