import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Helmet } from 'react-helmet';
import axios from 'axios';
import { API_ENDPOINTS, API_BASE_URL } from '../config';
import CheckoutDrawer from '../components/CheckoutDrawer';
import './ProductPage.css';

function ProductPage() {
  const { slug, productId } = useParams();
  const navigate = useNavigate();
  const [store, setStore] = useState(null);
  const [product, setProduct] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedImageIndex, setSelectedImageIndex] = useState(0);
  const [quantity, setQuantity] = useState(1);
  const [selectedSize, setSelectedSize] = useState(null);
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
  const [isSizeChartOpen, setIsSizeChartOpen] = useState(false);

  useEffect(() => {
    fetchProductData();
    // eslint-disable-next-line
  }, [slug, productId]);

  const fetchProductData = async () => {
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
          console.log('Trying product URL:', url);
          response = await axios.get(url);
          console.log('Product response:', response.data);
          if (response.data.success) {
            break;
          }
        } catch (err) {
          console.error('Failed product URL:', url, err.message);
          continue;
        }
      }
      
      if (response && response.data.success) {
        const storeData = response.data.data;
        setStore(storeData);
        
        // Find the product
        const foundProduct = storeData.products?.find(p => p.id === parseInt(productId));
        if (foundProduct) {
          setProduct(foundProduct);
          console.log('✅ Product loaded:', foundProduct.name);
          
          // Track product view
          trackEvent('product_view', foundProduct.id);
        } else {
          setError('Product not found');
        }
      } else {
        setError('Store not found');
      }
    } catch (err) {
      console.error('Error loading product:', err);
      setError('Failed to load product');
    } finally {
      setLoading(false);
    }
  };

  const trackEvent = async (eventType, productId) => {
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
            event_type: eventType,
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

  const handleWhatsAppClick = () => {
    if (product.has_sizes && !selectedSize) {
      // Create a more elegant notification instead of alert
      const sizeSelector = document.querySelector('.size-section');
      if (sizeSelector) {
        sizeSelector.scrollIntoView({ behavior: 'smooth', block: 'center' });
        sizeSelector.classList.add('shake-animation');
        setTimeout(() => sizeSelector.classList.remove('shake-animation'), 500);
      }
      return;
    }
    trackEvent('product_click', product.id);
    setIsDrawerOpen(true);
  };

  const incrementQuantity = () => {
    const maxStock = selectedSize ? product.sizes[selectedSize] : product.stock_quantity;
    if (maxStock && quantity >= maxStock) return;
    setQuantity(prev => prev + 1);
  };

  const decrementQuantity = () => {
    if (quantity > 1) {
      setQuantity(prev => prev - 1);
    }
  };

  const getProductImages = () => {
    if (!product) return [];
    
    const images = [];
    
    // Primary image
    if (product.image) {
      images.push(product.image.startsWith('http') ? product.image : `${API_BASE_URL}${product.image}`);
    }
    
    // Additional images from JSON
    if (product.images) {
      try {
        const additionalImages = typeof product.images === 'string' ? JSON.parse(product.images) : product.images;
        if (Array.isArray(additionalImages)) {
          additionalImages.forEach(img => {
            if (img) {
              images.push(img.startsWith('http') ? img : `${API_BASE_URL}${img}`);
            }
          });
        }
      } catch (e) {
        console.error('Error parsing images:', e);
      }
    }
    
    return images.length > 0 ? images : [null];
  };

  if (loading) {
    return (
      <div className="product-loading">
        <div className="loading-spinner"></div>
        <p>Loading product...</p>
      </div>
    );
  }

  if (error || !product) {
    return (
      <div className="product-error">
        <div className="error-icon">
          <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <h2>Product Not Found</h2>
        <p>The product you're looking for doesn't exist.</p>
        <button onClick={() => navigate(`/store/${slug}`)} className="back-btn">
          Back to Store
        </button>
      </div>
    );
  }

  const productImages = getProductImages();

  return (
    <>
      <Helmet>
        <title>{product?.name && store?.name ? `${product.name} - ${store.name}` : 'Product Details'}</title>
        <meta name="description" content={product?.description || `Buy ${product?.name || 'product'} from ${store?.name || 'our store'}`} />
        <meta name="theme-color" content="#FFFFFF" />
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
      </Helmet>

      <div className="product-page">
        {/* Minimalist Header */}
        <header className="product-header">
          <button onClick={() => navigate(`/store/${slug}`)} className="back-button">
            <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M15 19l-7-7 7-7" />
            </svg>
            <span className="back-text">Back to Store</span>
          </button>
          <div className="header-store-info">
            <span className="store-name-small">{store.name}</span>
          </div>
        </header>

        {/* Main Content Layout */}
        <div className="product-content">
          {/* Left Side - Luxury Gallery */}
          <div className="product-left">
            <div className="image-gallery-container">
              {/* Vertical Side Thumbnails */}
              <div className="thumbnail-list">
                {productImages.map((img, index) => (
                  <div
                    key={index}
                    className={`thumbnail-item ${selectedImageIndex === index ? 'active' : ''}`}
                    onClick={() => setSelectedImageIndex(index)}
                  >
                    {img ? (
                      <img src={img} alt={`${product.name} thumbnail ${index + 1}`} />
                    ) : (
                      <div className="thumbnail-placeholder">
                        <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                        </svg>
                      </div>
                    )}
                  </div>
                ))}
              </div>

              {/* Featured Main Image */}
              <div className="main-image-display">
                {productImages[selectedImageIndex] ? (
                  <img src={productImages[selectedImageIndex]} alt={product.name} />
                ) : (
                  <div className="main-image-placeholder">
                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Right Side - Editorial Details */}
          <div className="product-right">
            <div className="product-details-sticky">
              <div className="product-header-info">
                {product.product_id && (
                  <div className="product-sku">Catalog Ref: {product.product_id}</div>
                )}
                <h1 className="product-title">{product.name}</h1>
                <div className="product-price-large">
                  ₹{product.price.toLocaleString('en-IN')}
                  <span className="tax-info-inline">INR</span>
                </div>
                <p className="tax-info">Complimentary shipping on all orders.</p>
              </div>

              <div className="availability-section">
                {product.stock_quantity > 0 ? (
                  <div className="stock-badge in-stock">
                    <div className="pulse-dot"></div>
                    <span>Limited Availability ({product.stock_quantity})</span>
                  </div>
                ) : (
                  <div className="stock-badge out-of-stock">
                    <span>Awaiting Restock</span>
                  </div>
                )}
              </div>

              {product.description && (
                <div className="product-description-box">
                  <p>{product.description}</p>
                </div>
              )}

              <div className="product-specs">
                {product.category && (
                  <div className="spec-item">
                    <span className="spec-label">Collection</span>
                    <span className="spec-value">{product.category}</span>
                  </div>
                )}
                <div className="spec-item">
                  <span className="spec-label">Origin</span>
                  <span className="spec-value">Handcrafted</span>
                </div>
                <div className="spec-item">
                  <span className="spec-label">Service</span>
                  <span className="spec-value">Concierge Support</span>
                </div>
              </div>

              {product.has_sizes && product.sizes && (
                <div className="size-section">
                  <div className="size-header">
                    <label className="size-label">Select Size</label>
                    {product.size_chart_image && (
                      <button 
                        className="size-chart-link"
                        onClick={() => setIsSizeChartOpen(true)}
                      >
                        Size Guide
                      </button>
                    )}
                  </div>
                  <div className="size-selector">
                    {Object.entries(product.sizes).map(([size, stock]) => (
                      <button
                        key={size}
                        className={`size-btn ${selectedSize === size ? 'active' : ''} ${stock === 0 ? 'out-of-stock' : ''}`}
                        onClick={() => stock > 0 && setSelectedSize(size)}
                        disabled={stock === 0}
                      >
                        {size}
                      </button>
                    ))}
                  </div>
                  {selectedSize && product.sizes[selectedSize] < 10 && product.sizes[selectedSize] > 0 && (
                    <p className="low-stock-warning">Only {product.sizes[selectedSize]} left in this size!</p>
                  )}
                </div>
              )}

              <div className="quantity-section">
                <label className="quantity-label">Select Quantity</label>
                <div className="quantity-selector">
                  <button 
                    className="qty-btn" 
                    onClick={decrementQuantity}
                    disabled={quantity <= 1}
                  >
                    −
                  </button>
                  <input 
                    type="number" 
                    className="qty-input" 
                    value={quantity}
                    readOnly
                  />
                  <button 
                    className="qty-btn" 
                    onClick={incrementQuantity}
                    disabled={product.stock_quantity && quantity >= product.stock_quantity}
                  >
                    +
                  </button>
                </div>
              </div>

              <button 
                className="order-whatsapp-btn-sticky"
                onClick={handleWhatsAppClick}
                disabled={product.stock_quantity === 0}
              >
                <svg className="whatsapp-icon" width="24" height="24" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
                </svg>
                <span className="whatsapp-text">Order on WhatsApp</span>
              </button>

              <div className="seller-info-card">
                <h3 className="seller-title">Authorized Merchant</h3>
                <div className="seller-details-row">
                  <div className="seller-avatar-small">
                    {store.logo ? (
                      <img 
                        src={store.logo.startsWith('http') ? store.logo : `${API_BASE_URL}${store.logo}`} 
                        alt={store.name} 
                      />
                    ) : (
                      <div className="avatar-placeholder-small">
                        <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
                        </svg>
                      </div>
                    )}
                  </div>
                  <div className="seller-info-text">
                    <h4 className="seller-name">{store.name}</h4>
                    <p className="seller-contact">
                      Contact Representative: {store.phone}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      {product && store && (
        <CheckoutDrawer 
          isOpen={isDrawerOpen} 
          onClose={() => setIsDrawerOpen(false)} 
          product={product}
          store={store}
          quantity={quantity}
          selectedSize={selectedSize}
          total={product.price * quantity}
        />
      )}

      {isSizeChartOpen && (
        <div className="size-chart-modal" onClick={() => setIsSizeChartOpen(false)}>
          <div className="size-chart-content" onClick={e => e.stopPropagation()}>
            <button className="close-modal" onClick={() => setIsSizeChartOpen(false)}>×</button>
            <h3>Size Guide</h3>
            <div className="size-chart-image-container">
              <img 
                src={product.size_chart_image.startsWith('http') ? product.size_chart_image : `${API_BASE_URL}${product.size_chart_image}`} 
                alt="Size Chart" 
              />
            </div>
          </div>
        </div>
      )}
    </>
  );
}

export default ProductPage;
