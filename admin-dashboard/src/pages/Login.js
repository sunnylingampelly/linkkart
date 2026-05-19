import React, { useState } from 'react';
import axios from 'axios';
import './Login.css';

function Login({ onLogin }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const response = await axios.post('https://api.linkkart.shop/api/v1/auth/login', {
        email,
        password
      });

      const { token, user } = response.data.data;

      if (user.role !== 'admin') {
        setError('Access denied. Admin privileges required.');
        setLoading(false);
        return;
      }

      onLogin(token);
      setLoading(false);
    } catch (err) {
      console.error('Login error:', err);
      const message = err.response?.data?.message || 'Invalid email or password';
      setError(message);
      setLoading(false);
    }
  };

  return (
    <div className="login-portal">
      <div className="portal-left">
        <div className="portal-brand">
          <h1 className="brand-logo">LinkKart<span>.</span></h1>
          <p className="brand-tagline">PLATFORM ADMINISTRATION</p>
        </div>
      </div>
      
      <div className="portal-right">
        <form onSubmit={handleSubmit} className="auth-form">
          <div className="auth-header">
            <h2>Welcome Back</h2>
            <p>Access the global dashboard</p>
          </div>

          <div className="auth-body">
            <div className="input-field">
              <label>Email Address</label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@linkkart.com"
                required
              />
            </div>

            <div className="input-field">
              <label>Password</label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                required
              />
            </div>

            {error && <div className="auth-error">{error}</div>}

            <button type="submit" className="auth-submit" disabled={loading}>
              {loading ? 'Verifying Identity...' : 'Sign Into Dashboard'}
            </button>
          </div>

          <div className="auth-footer">
            <p>© 2026 LinkKart Platform. All rights reserved.</p>
          </div>
        </form>
      </div>
    </div>
  );
}

export default Login;
