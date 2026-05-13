// LinkKart Storefront Configuration
// IMPORTANT: Update this IP address to match your backend server IP
// Find your IP: Windows (ipconfig) | Linux/Mac (ifconfig)
export const API_BASE_URL = 'http://localhost:8000';

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
