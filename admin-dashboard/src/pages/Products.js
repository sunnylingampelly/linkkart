import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Products.css';

function Products() {
  const [products, setProducts] = useState([]);
  const [stores, setStores] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedStore, setSelectedStore] = useState('all');

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      
      // Fetch stores first
      const storesRes = await axios.get('http://localhost:8000/stores');
      const storesData = storesRes.data.data || [];
      setStores(storesData);
      
      // Fetch products for all stores
      let allProducts = [];
      for (const store of storesData) {
        try {
          const productsRes = await axios.get(`http://localhost:8000/products/${store.id}`);
          if (productsRes.data.data) {
            const productsWithStore = productsRes.data.data.map(p => ({
              ...p,
              storeName: store.name
            }));
            allProducts = [...allProducts, ...productsWithStore];
          }
        } catch (err) {
          console.error(`Error fetching products for store ${store.id}:`, err);
        }
      }
      
      setProducts(allProducts);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching data:', error);
      setLoading(false);
    }
  };

  const filteredProducts = products.filter(product => {
    const matchesSearch = product.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         (product.description && product.description.toLowerCase().includes(searchTerm.toLowerCase()));
    const matchesStore = selectedStore === 'all' || product.store_id === parseInt(selectedStore);
    return matchesSearch && matchesStore;
  });

  if (loading) {
    return (
      <div className="page-loading">
        <div className="spinner"></div>
        <p>Loading products...</p>
      </div>
    );
  }

  return (
    <div className="products-page">
      <div className="page-header">
        <div>
          <h1>Products Management</h1>
          <p className="subtitle">View and manage all products across stores</p>
        </div>
      </div>

      <div className="page-toolbar">
        <div className="search-box">
          <svg className="search-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
          <input
            type="text"
            placeholder="Search products..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <select 
          className="store-filter"
          value={selectedStore}
          onChange={(e) => setSelectedStore(e.target.value)}
        >
          <option value="all">All Stores</option>
          {stores.map(store => (
            <option key={store.id} value={store.id}>{store.name}</option>
          ))}
        </select>
        <div className="toolbar-stats">
          <span className="stat-badge">Total: {filteredProducts.length}</span>
        </div>
      </div>

      <div className="products-grid">
        {filteredProducts.length > 0 ? (
          filteredProducts.map(product => (
            <div key={product.id} className="product-card">
              <div className="product-image">
                {product.image ? (
                  <img src={product.image} alt={product.name} />
                ) : (
                  <div className="image-placeholder">
                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                    </svg>
                  </div>
                )}
              </div>
              <div className="product-content">
                <h3>{product.name}</h3>
                <p className="product-description">
                  {product.description || 'No description available'}
                </p>
                <div className="product-meta">
                  <span className="product-price">₹{product.price}</span>
                  <span className="product-store">
                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
                    </svg>
                    {product.storeName}
                  </span>
                </div>
              </div>
            </div>
          ))
        ) : (
          <div className="empty-state">
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
            </svg>
            <h3>No products found</h3>
            <p>No products match your search criteria</p>
          </div>
        )}
      </div>
    </div>
  );
}

export default Products;
