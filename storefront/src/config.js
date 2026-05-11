// LinkKart Storefront Configuration
// Dynamically detect API host for local network testing
const currentHost = window.location.hostname;
const apiPort = '8000';

// Fallback to the known local IP if localhost is used but might be accessed from network
export const API_BASE_URL = currentHost === 'localhost' || currentHost === '127.0.0.1' 
  ? `http://${currentHost}:${apiPort}` 
  : `http://${currentHost}:${apiPort}`;

// If you need to force a specific IP for production, replace above with your URL
// export const API_BASE_URL = 'http://192.168.1.8:8000';

export const API_VERSION = '/api/v1';

export const API_ENDPOINTS = {
  STORES: `${API_BASE_URL}${API_VERSION}/stores`,
  PRODUCTS: `${API_BASE_URL}${API_VERSION}/products`,
  ANALYTICS: `${API_BASE_URL}${API_VERSION}/analytics`,
  ORDERS: `${API_BASE_URL}${API_VERSION}/orders`,
};
