import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || 'http://localhost:8000';

export const loadRazorpayScript = () => {
  return new Promise((resolve) => {
    const script = document.createElement('script');
    script.src = 'https://checkout.razorpay.com/v1/checkout.js';
    script.onload = () => resolve(true);
    script.onerror = () => resolve(false);
    document.body.appendChild(script);
  });
};

export const initializePayment = async (subscriptionId, amount, options = {}) => {
  try {
    const res = await loadRazorpayScript();

    if (!res) {
      alert('Razorpay SDK failed to load. Are you online?');
      return;
    }

    // 1. Create order on backend
    const token = localStorage.getItem('admin_token');
    const orderResponse = await axios.post(`${API_BASE_URL}/api/create-order`, {
      subscription_id: subscriptionId,
      amount: amount
    }, {
      headers: token ? { Authorization: `Bearer ${token}` } : {}
    });

    if (!orderResponse.data.success) {
      alert('Failed to create order. Please try again.');
      return;
    }

    const order = orderResponse.data.data;

    // 2. Open Razorpay Modal
    const razorpayOptions = {
      key: process.env.REACT_APP_RAZORPAY_KEY_ID,
      amount: order.amount * 100, // Razorpay expects paise
      currency: order.currency,
      name: 'LinkKart Luxury',
      description: 'Subscription Upgrade',
      order_id: order.razorpay_order_id,
      handler: async function (response) {
        // 3. Verify payment on backend
        try {
          const verifyResponse = await axios.post(`${API_BASE_URL}/api/verify-payment`, {
            razorpay_order_id: response.razorpay_order_id,
            razorpay_payment_id: response.razorpay_payment_id,
            razorpay_signature: response.razorpay_signature
          }, {
            headers: token ? { Authorization: `Bearer ${token}` } : {}
          });

          if (verifyResponse.data.success) {
            if (options.onSuccess) options.onSuccess(verifyResponse.data.data);
          } else {
            alert('Payment verification failed.');
          }
        } catch (err) {
          console.error('Verification error:', err);
          alert('Something went wrong during payment verification.');
        }
      },
      prefill: options.prefill || {},
      theme: {
        color: '#D4AF37' // Luxury Gold
      },
      modal: {
        ondismiss: function() {
          if (options.onCancel) options.onCancel();
        }
      }
    };

    const rzp = new window.Razorpay(razorpayOptions);
    
    rzp.on('payment.failed', function (response) {
      console.error('Payment failed:', response.error);
      alert(`Payment failed: ${response.error.description}`);
    });

    rzp.open();

  } catch (error) {
    console.error('Payment initialization error:', error);
    alert('Failed to initialize payment.');
  }
};
