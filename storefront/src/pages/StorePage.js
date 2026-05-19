import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { Helmet } from 'react-helmet';
import axios from 'axios';
import { API_ENDPOINTS, API_BASE_URL } from '../config';
import './StorePage.css';

function StorePage() {
  const { slug } = useParams();
  const [store, setStore] = useState(null);
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchStoreData();
    // Track analytics
    trackEvent('view');
    // eslint-disable-next-line
  }, [slug]);

  const fetchStoreData = async () => {
    try {
      setLoading(true);
      
      // Try multiple URLs
      const urls = [
        `${API_ENDPOINTS.STORES}/${slug}`,
        `https://api.linkkart.shop/api/v1/stores/${slug}`
      ];
      
      let response = null;
      for (const url of urls) {
        try {
          console.log('Trying store URL:', url);
          response = await axios.get(url);
          console.log('Store response:', response.data);
          if (response.data.success) {
            break;
          }
        } catch (err) {
          console.error('Failed store URL:', url, err.message);
          continue;
        }
      }
      
      if (response && response.data.success) {
        console.log('=== STORE DATA ===');
        console.log('Store:', response.data.data);
        console.log('Products array:', response.data.data.products);
        console.log('Products length:', response.data.data.products?.length);
        
        setStore(response.data.data);
        const productsArray = response.data.data.products || [];
        setProducts(productsArray);
        
        console.log('✅ Store loaded with', productsArray.length, 'products');
        console.log('Products state set to:', productsArray);
      } else {
        setError('Store not found');
      }
    } catch (err) {
      console.error('Error loading store:', err);
      setError('Store not found');
    } finally {
      setLoading(false);
    }
  };

  const trackEvent = async (eventType, productId = null) => {
    try {
      if (!store) return;
      const urls = [
        `${API_ENDPOINTS.ANALYTICS}/track`,
        'https://api.linkkart.shop/api/v1/analytics/track'
      ];
      
      for (const url of urls) {
        try {
          await axios.post(url, {
            store_id: store.id,
            product_id: productId,
            event_type: eventType === 'view' ? 'store_view' : 'product_click',
            metadata: {}
          });
          break;
        } catch (err) {
          continue;
        }
      }
    } catch (err) {
      console.error('Analytics tracking failed:', err);
    }
  };

  if (loading) {
    return (
      <div className="loading-screen">
        <div className="loading-content">
          <div className="loading-spinner"></div>
          <div className="loading-dots">
            <span></span>
            <span></span>
            <span></span>
          </div>
          <p>Loading store...</p>
        </div>
      </div>
    );
  }

  if (error || !store) {
    return (
      <div className="error-screen">
        <div className="error-content">
          <div className="error-icon">
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <h1>Store Not Found</h1>
          <p>The store you're looking for doesn't exist or has been removed.</p>
        </div>
      </div>
    );
  }

  return (
    <>
      <Helmet>
        <title>{store?.name ? `${store.name} - Boutique Collection` : 'Boutique Collection'}</title>
        <meta name="description" content={`Discover the exclusive collection at ${store?.name || 'our boutique'}. Artisanal quality, ordered via WhatsApp.`} />
        <meta name="theme-color" content="#FFFFFF" />
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
      </Helmet>

      <div className="storefront">
        <header className="store-header">
          <div className="header-content">
            <div className="store-avatar">
              {store.logo ? (
                <img src={store.logo.startsWith('http') ? store.logo : `${API_BASE_URL}${store.logo}`} alt={store.name} />
              ) : (
                <div className="avatar-placeholder">
                  <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
                  </svg>
                </div>
              )}
            </div>
            <div className="store-info">
              <span className="collection-label">Private Collection</span>
              <h1 className="store-name">{store.name}</h1>
            </div>
            <div className="header-actions">
              <div className="store-contact-tag">
                {store.phone}
              </div>
            </div>
          </div>
        </header>

        {/* Products Section */}
        <main className="products-container">
          {products.length === 0 ? (
            <div className="empty-state">
              <div className="error-icon">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
                </svg>
              </div>
              <h3>Curating Products...</h3>
              <p>Our luxury collection is arriving soon. Please check back.</p>
            </div>
          ) : (
            <>
              <div className="section-header">
                <h2>Our Collection</h2>
                <span className="product-count">{products.length} exclusive items</span>
              </div>
              <div className="products-grid">
                {products.map((product, index) => (
                  <Link
                    key={product.id}
                    to={`/store/${slug}/product/${product.id}`}
                    className="product-card"
                    style={{ animationDelay: `${index * 0.1}s` }}
                  >
                    <div className="product-image">
                      {product.image ? (
                        <img 
                          src={product.image.startsWith('http') ? product.image : `${API_BASE_URL}${product.image}`} 
                          alt={product.name} 
                          loading="lazy" 
                        />
                      ) : (
                        <div className="image-placeholder">
                          <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                          </svg>
                        </div>
                      )}
                      <div className="quick-view">
                        <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.5L12 19.5M19.5 12L4.5 12" />
                        </svg>
                      </div>
                    </div>
                    <div className="product-details">
                      <h3 className="product-name">{product.name}</h3>
                      {product.description && (
                        <p className="product-description">{product.description}</p>
                      )}
                      <div className="product-footer">
                        <span className="product-price">₹{product.price}</span>
                        <span className="view-details">Explore →</span>
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            </>
          )}
        </main>

        {/* Premium Footer */}
        <footer className="store-footer">
          <div className="footer-content">
            <p className="powered-text">Powered by</p>
            <div className="linkkart-logo">
              <img src="/lk_luxury_monogram_only.png" alt="LinkKart" className="logo-img-tiny" />
            </div>
          </div>
        </footer>
      </div>
    </>
  );
}

export default StorePage;
