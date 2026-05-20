import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet';
import axios from 'axios';
import { API_ENDPOINTS, API_BASE_URL } from '../config';
import './HomePage.css';

function HomePage() {
  const [stores, setStores] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStores();
  }, []);

  const fetchStores = async () => {
    try {
      setLoading(true);
      console.log('=== FETCHING STORES ===');
      
      const urls = [
        API_ENDPOINTS.STORES,
        'https://api.linkkart.shop/api/v1/stores'
      ];
      
      let response = null;
      for (const url of urls) {
        try {
          console.log('Trying URL:', url);
          response = await axios.get(url);
          console.log('Response received:', response.data);
          if (response.data.success && response.data.data) {
            console.log('✅ SUCCESS! Found', response.data.data.length, 'stores');
            break;
          }
        } catch (err) {
          console.error('❌ Failed URL:', url, err.message);
          continue;
        }
      }
      
      if (response && response.data.success && response.data.data) {
        console.log('Setting stores:', response.data.data);
        setStores(response.data.data);
      } else {
        console.error('❌ No valid response from any URL');
        setStores([]); // Set empty array to show "No stores" message
      }
    } catch (error) {
      console.error('❌ Error fetching stores:', error);
      setStores([]); // Set empty array on error
    } finally {
      setLoading(false);
      console.log('=== FETCH COMPLETE ===');
    }
  };

  if (loading) {
    return (
      <div className="home-loading">
        <div className="loading-spinner"></div>
        <p>Loading...</p>
      </div>
    );
  }

  return (
    <>
      <Helmet>
        <title>LinkKart - Create Your Store in 2 Minutes</title>
        <meta name="description" content="Build beautiful storefronts and sell faster on WhatsApp. Create your online store in minutes without technical skills." />
        <meta name="theme-color" content="#D4AF37" />
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
      </Helmet>

      <div className="home-page">
      {/* Navigation */}
      <nav className="top-nav">
        <div className="nav-container">
          <div className="nav-logo">
            <img src="/lk_luxury_monogram_only.png" alt="LK" className="logo-img" />
          </div>
          <div className="nav-links">
            <a href="#stores">Stores</a>
            <a href="#features">Features</a>
            <a href="#about">About</a>
          </div>
          <button className="nav-cta">Get Started</button>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="hero-section" style={{ background: "url('/hero_bg.png') center/cover no-repeat" }}>
        <div className="hero-overlay"></div>
        <div className="hero-container">
          <div className="hero-content">
            <span className="hero-badge">ELEGANCE IN COMMERCE</span>
            <h1 className="hero-title">
              Build Beautiful<br />
              <span>Storefronts.</span> Sell Faster on WhatsApp.

            </h1>
            <p className="hero-description">
              Create your online store in minutes and start selling through WhatsApp.<br />
              No technical skills required. Just add products and share your link.
            </p>
            <div className="hero-buttons">
              <button className="btn-primary">Get Started</button>
              <button className="btn-secondary">Learn More</button>
            </div>
          </div>
        </div>
      </section>

      {/* Stores Section */}
      <section className="stores-section" id="stores">
        <div className="section-container">
          <div className="section-header-main">
            <span className="section-badge">OUR STORES</span>
            <h2 className="section-title-main">Designer Stores Like High Fashion Houses</h2>
            <p className="section-subtitle-main">
              Browse through our curated collection of premium stores.<br />
              Each store is crafted with care and attention to detail.
            </p>
          </div>

          {stores.length === 0 ? (
            <div className="empty-state">
              <div className="empty-icon">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
                </svg>
              </div>
              <h3>No Stores Yet</h3>
              <p>Stores will appear here once they're created</p>
            </div>
          ) : (
            <div className="stores-grid-premium">
              {stores.map((store, index) => (
                <Link 
                  key={store.id} 
                  to={`/store/${store.slug || store.id}`}
                  className="store-card-premium"
                  style={{ animationDelay: `${index * 0.1}s` }}
                >
                  <div className="store-image-container">
                    {(store.image || store.logo) ? (
                      <img 
                        src={store.image || store.logo} 
                        alt={store.name} 
                        className="store-image"
                        onError={(e) => {
                          e.target.style.display = 'none';
                          e.target.nextSibling.style.display = 'flex';
                        }}
                      />
                    ) : null}
                    <div className="store-image-placeholder" style={{ display: (store.image || store.logo) ? 'none' : 'flex' }}>
                      <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
                      </svg>
                    </div>
                    <div className="store-overlay">
                      <span className="store-view-btn">View Store →</span>
                    </div>
                  </div>
                  <div className="store-info">
                    <h3 className="store-title">{store.name}</h3>
                    <p className="store-description">
                      {store.description || 'Premium products curated with care'}
                    </p>
                  </div>
                </Link>
              ))}
            </div>
          )}
        </div>
      </section>

      {/* Features Section */}
      <section className="features-section" id="features">
        <div className="section-container">
          <div className="section-header-main">
            <span className="section-badge">WHY CHOOSE US</span>
            <h2 className="section-title-main">Built for Speed, Trust and Scale</h2>
          </div>

          <div className="features-grid">
            <div className="feature-card">
              <div className="feature-icon">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </div>
              <h3 className="feature-title">Instant Setup</h3>
              <p className="feature-description">
                Create your store in less than 2 minutes. No coding required.
              </p>
            </div>

            <div className="feature-card">
              <div className="feature-icon">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z" />
                </svg>
              </div>
              <h3 className="feature-title">WhatsApp Orders</h3>
              <p className="feature-description">
                Customers order directly via WhatsApp. Simple and familiar.
              </p>
            </div>

            <div className="feature-card">
              <div className="feature-icon">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
              </div>
              <h3 className="feature-title">Track & Grow</h3>
              <p className="feature-description">
                Real-time analytics to understand your customers better.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="cta-section">
        <div className="cta-container">
          <h2 className="cta-title">Start Selling Without Limits</h2>
          <p className="cta-description">
            Join thousands of sellers who trust LK for their online business
          </p>
          <button className="cta-button">Get Started Free</button>
        </div>
      </section>

      {/* Footer */}
      <footer className="footer">
        <div className="footer-container">
          <div className="footer-brand">
            <div className="footer-logo">
              <img src="/lk_luxury_monogram_only.png" alt="LK" className="logo-img-small" />
            </div>
            <p className="footer-tagline">
              Create your store in 2 minutes
            </p>
          </div>
          <div className="footer-links">
            <a href="#stores">Stores</a>
            <a href="#features">Features</a>
            <a href="#about">About</a>
          </div>
          <div className="footer-bottom">
            <p>© 2024 LK. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
    </>
  );
}

export default HomePage;
