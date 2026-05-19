import React, { useState } from 'react';
import './CheckoutDrawer.css';
import axios from 'axios';
import { API_ENDPOINTS } from '../config';

function CheckoutDrawer({ isOpen, onClose, product, store, quantity, total }) {
  const [formData, setFormData] = useState({
    name: '',
    phone: '+91 ',
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState(null);

  if (!isOpen) return null;

  const handleChange = (e) => {
    let value = e.target.value;
    
    // Enforce +91 prefix for phone
    if (e.target.name === 'phone') {
      if (!value.startsWith('+91 ')) {
        // If they deleted part of the prefix, restore it
        if (value.startsWith('+91')) {
          value = '+91 ' + value.substring(3).trim();
        } else {
          value = '+91 ' + value.replace(/[^0-9]/g, '');
        }
      }
      
      // Limit to 10 digits after +91 
      if (value.length > 14) {
        value = value.substring(0, 14);
      }
    }
    
    setFormData({
      ...formData,
      [e.target.name]: value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.name || formData.phone.length !== 14) {
      setError('Name is required and Phone must be 10 digits.');
      return;
    }

    setIsSubmitting(true);
    setError(null);

    try {
      // Create order in backend
      const urls = [
        API_ENDPOINTS.ORDERS,
        'https://api.linkkart.shop/api/v1/orders'
      ];
      
      let success = false;
      let orderId = '';
      
      for (const url of urls) {
        try {
          const res = await axios.post(url, {
            store_id: store.id,
            product_id: product.id,
            name: formData.name,
            phone: formData.phone,
            quantity: quantity,
            total_price: total
          });
          if (res.data.success) {
            success = true;
            orderId = res.data.data.order_id;
            break;
          }
        } catch (err) {
          continue;
        }
      }

      // Format beautiful WhatsApp message
      const orderRef = success ? `\n🏷️ *Order ID:* #LK-${orderId}` : '';
      const productLink = window.location.href; // current product URL
      
      const message = encodeURIComponent(
        `✨ *New Order Request* ✨\n\n` +
        `Hi ${store.name}! I would like to place an order from your store.${orderRef}\n\n` +
        `━━━━━━━━━━━━━━━\n\n` +
        `🛍️ *Product Details*\n` +
        `*Name:* ${product.name}\n` +
        `*Link:* ${productLink}\n` +
        `*Quantity:* ${quantity}\n` +
        `*Total Price:* ₹${total.toLocaleString('en-IN')}\n\n` +
        `━━━━━━━━━━━━━━━\n\n` +
        `👤 *Customer Details*\n` +
        `*Name:* ${formData.name}\n` +
        `*Phone:* ${formData.phone}\n\n` +
        `Please confirm my order. Thank you! 🙏`
      );
      
      const phone = store.phone.replace(/[^0-9]/g, '');
      
      // Close drawer and redirect
      onClose();
      window.open(`https://wa.me/${phone}?text=${message}`, '_blank');
      
    } catch (err) {
      console.error('Checkout error:', err);
      setError('Failed to process order. Please try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className={`drawer-overlay ${isOpen ? 'open' : ''}`} onClick={onClose}>
      <div className={`drawer-content ${isOpen ? 'open' : ''}`} onClick={e => e.stopPropagation()}>
        <div className="drawer-header">
          <div className="drawer-handle"></div>
          <h2>Complete Order</h2>
          <button className="close-btn" onClick={onClose}>
            <svg width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        
        <div className="order-summary-mini">
          <div className="mini-product-info">
            <span className="mini-qty">{quantity}x</span>
            <span className="mini-name">{product.name}</span>
          </div>
          <span className="mini-total">₹{total.toLocaleString('en-IN')}</span>
        </div>

        {error && <div className="drawer-error">{error}</div>}

        <form className="checkout-form" onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Full Name *</label>
            <input 
              type="text" 
              name="name" 
              value={formData.name} 
              onChange={handleChange} 
              placeholder="Enter your name"
              required 
            />
          </div>
          <div className="form-group">
            <label>WhatsApp Number *</label>
            <input 
              type="tel" 
              name="phone" 
              value={formData.phone} 
              onChange={handleChange} 
              placeholder="+91 XXXXXXXXXX"
              required 
            />
          </div>
          
          <button 
            type="submit" 
            className={`submit-order-btn ${isSubmitting ? 'loading' : ''}`}
            disabled={isSubmitting}
          >
            {isSubmitting ? 'Processing...' : 'Continue to WhatsApp'}
            {!isSubmitting && (
              <svg width="20" height="20" fill="currentColor" viewBox="0 0 24 24" style={{marginLeft: '8px'}}>
                <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
            </svg>
          )}
        </button>
      </form>
    </div>
  </div>
  );
}

export default CheckoutDrawer;
