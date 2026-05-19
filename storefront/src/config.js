// LinkKart Storefront Configuration
// PRODUCTION: Using live API URL
export const API_BASE_URL = 'https://api.linkkart.shop';

// LOCAL DEVELOPMENT: Uncomment below for local testing
// export const API_BASE_URL = 'http://localhost:8000';

// For dynamic detection (if backend runs on same machine as storefront):
// const currentHost = window.location.hostname;
// const apiPort = '8000';
// export const API_BASE_URL = `http://${currentHost}:${apiPort}`;

export const API_VERSION = '/api/v1';

export const API_ENDPOINTS = {
  STORES: `${API_BASE_URL}${API_VERSION}/stores`,
  PRODUCTS: `${API_BASE_URL}${API_VERSION}/products`,
  ANALYTICS: `${API_BASE_URL}${API_VERSION}/analytics`,
  ORDERS: `${API_BASE_URL}${API_VERSION}/orders`,
};
