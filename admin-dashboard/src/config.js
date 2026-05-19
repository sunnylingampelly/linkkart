// LinkKart Admin Dashboard Configuration

// PRODUCTION: Using live API URL
export const API_BASE_URL = 'https://api.linkkart.shop';

// LOCAL DEVELOPMENT: Uncomment below for local testing
// export const API_BASE_URL = 'http://localhost:8000';

export const API_ENDPOINTS = {
  AUTH_LOGIN: `${API_BASE_URL}/api/v1/auth/login`,
  STORES: `${API_BASE_URL}/api/v1/stores`,
  PRODUCTS: `${API_BASE_URL}/api/v1/products`,
  ANALYTICS: `${API_BASE_URL}/api/v1/analytics`,
  PAYMENTS: `${API_BASE_URL}/api/v1/payments/history`,
  PLANS: `${API_BASE_URL}/api/v1/admin/plans`,
};

export default API_BASE_URL;
