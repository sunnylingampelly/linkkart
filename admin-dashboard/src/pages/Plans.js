import React, { useEffect, useState } from 'react';
import axios from 'axios';
import './Dashboard.css';

function Plans() {
  const [plans, setPlans] = useState([]);
  const [loading, setLoading] = useState(true);
  const [savingId, setSavingId] = useState(null);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchPlans();
  }, []);

  const fetchPlans = async () => {
    try {
      setLoading(true);
      setError('');
      const token = localStorage.getItem('admin_token');
      const response = await axios.get('https://api.linkkart.shop/api/v1/admin/plans', {
        headers: token ? { Authorization: `Bearer ${token}` } : {},
      });
      setPlans(response.data?.data || []);
    } catch (e) {
      setError('Unable to load plans. Make sure you are logged in as admin.');
    } finally {
      setLoading(false);
    }
  };

  const updatePlanField = (id, field, value) => {
    setPlans((prev) =>
      prev.map((plan) => (plan.id === id ? { ...plan, [field]: value } : plan))
    );
  };

  const savePlan = async (plan) => {
    try {
      setSavingId(plan.id);
      setError('');
      const token = localStorage.getItem('admin_token');
      await axios.put(
        `https://api.linkkart.shop/api/v1/admin/plans/${plan.id}`,
        {
          name: plan.name,
          price: Number(plan.price),
          product_limit: Number(plan.product_limit),
          order_limit: Number(plan.order_limit),
          sort_order: Number(plan.sort_order),
          is_active: Number(plan.is_active) === 1 || plan.is_active === true,
          features: Array.isArray(plan.features)
            ? plan.features
            : String(plan.features || '')
                .split('\n')
                .map((x) => x.trim())
                .filter(Boolean),
        },
        {
          headers: token ? { Authorization: `Bearer ${token}` } : {},
        }
      );
      fetchPlans();
    } catch (e) {
      setError(`Failed to save plan "${plan.name}".`);
    } finally {
      setSavingId(null);
    }
  };

  if (loading) return (
    <div className="dashboard-loading">
      <div className="spinner"></div>
      <p>Loading Plans...</p>
    </div>
  );

  return (
    <div className="plans-page">
      <div className="page-header">
        <div>
          <h1>Subscription Plans</h1>
          <p className="subtitle">Configure pricing and limits for store owners</p>
        </div>
      </div>

      {error && <div className="error-alert">{error}</div>}

      <div className="plans-list">
        {plans.map((plan) => (
          <div key={plan.id} className="plan-editor-card">
            <div className="card-header">
              <div className="header-top">
                <input
                  className="plan-name-input"
                  value={plan.name || ''}
                  onChange={(e) => updatePlanField(plan.id, 'name', e.target.value)}
                  placeholder="Plan name"
                />
                <div className="plan-status">
                   <label className="switch">
                    <input
                      type="checkbox"
                      checked={Number(plan.is_active) === 1 || plan.is_active === true}
                      onChange={(e) => updatePlanField(plan.id, 'is_active', e.target.checked ? 1 : 0)}
                    />
                    <span className="slider"></span>
                    <span className="label-text">{plan.is_active ? 'Active' : 'Hidden'}</span>
                  </label>
                </div>
              </div>
            </div>

            <div className="card-body">
              <div className="inputs-grid">
                <div className="input-group">
                  <label>Monthly Price (₹)</label>
                  <input
                    type="number"
                    value={plan.price}
                    onChange={(e) => updatePlanField(plan.id, 'price', e.target.value)}
                  />
                </div>
                <div className="input-group">
                  <label>Product Limit</label>
                  <input
                    type="number"
                    value={plan.product_limit}
                    onChange={(e) => updatePlanField(plan.id, 'product_limit', e.target.value)}
                  />
                </div>
                <div className="input-group">
                  <label>Order Limit</label>
                  <input
                    type="number"
                    value={plan.order_limit}
                    onChange={(e) => updatePlanField(plan.id, 'order_limit', e.target.value)}
                  />
                </div>
                <div className="input-group">
                  <label>Sort Order</label>
                  <input
                    type="number"
                    value={plan.sort_order}
                    onChange={(e) => updatePlanField(plan.id, 'sort_order', e.target.value)}
                  />
                </div>
              </div>

              <div className="features-group">
                <label>Features (one per line)</label>
                <textarea
                  value={Array.isArray(plan.features) ? plan.features.join('\n') : plan.features || ''}
                  onChange={(e) => updatePlanField(plan.id, 'features', e.target.value)}
                  placeholder="e.g. Custom Store Link"
                />
              </div>
            </div>

            <div className="card-footer">
              <button 
                className={`btn btn-primary ${savingId === plan.id ? 'saving' : ''}`}
                onClick={() => savePlan(plan)} 
                disabled={savingId === plan.id}
              >
                {savingId === plan.id ? 'Saving...' : 'Save Plan Details'}
              </button>
            </div>
          </div>
        ))}
      </div>

      <style dangerouslySetInnerHTML={{ __html: `
        .plans-list { display: flex; flex-direction: column; gap: 32px; max-width: 900px; }
        .plan-editor-card { background: white; border-radius: 12px; border: 1px solid var(--slate-200); box-shadow: var(--shadow-sm); overflow: hidden; }
        .card-header { padding: 24px 32px; border-bottom: 1px solid var(--slate-200); background: var(--slate-50); }
        .header-top { display: flex; justify-content: space-between; align-items: center; }
        .plan-name-input { font-size: 20px; font-weight: 800; color: var(--slate-900); border: none; background: transparent; width: 60%; font-family: 'Playfair Display', serif; }
        .card-body { padding: 32px; }
        .inputs-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 24px; margin-bottom: 24px; }
        .input-group label { display: block; font-size: 11px; font-weight: 700; color: var(--slate-600); text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px; }
        .input-group input, .features-group textarea { width: 100%; padding: 12px 16px; border: 1px solid var(--slate-200); border-radius: 8px; font-size: 14px; font-weight: 500; transition: all 0.2s; color: var(--slate-900); }
        .input-group input:focus, .features-group textarea:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 4px var(--primary-glow); }
        .features-group label { display: block; font-size: 11px; font-weight: 700; color: var(--slate-600); text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px; }
        .card-footer { padding: 24px 32px; background: var(--slate-50); border-top: 1px solid var(--slate-200); display: flex; justify-content: flex-end; }
        .switch { display: flex; align-items: center; gap: 12px; cursor: pointer; }
        .label-text { font-size: 12px; font-weight: 700; color: var(--slate-600); text-transform: uppercase; }
      `}} />
    </div>
  );
}

export default Plans;
