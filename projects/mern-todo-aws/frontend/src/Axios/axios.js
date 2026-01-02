import axios from 'axios';

// Determine API base URL based on environment
// For production (CloudFront): use relative /api (proxied to EC2)
// For development: use localhost
const API_BASE = (() => {
  if (typeof window !== 'undefined' && window.location.hostname === 'localhost') {
    return 'http://localhost:8001/api';
  }
  // Production: use relative path that CloudFront will proxy to EC2
  return '/api';
})();

const instance = axios.create({
  baseURL: API_BASE,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Token auto add for protected routes (JWT Bearer)
instance.interceptors.request.use((config) => {
  let token = localStorage.getItem('authToken');
  if (token) {
    // token may be stored raw or JSON-stringified. Try to parse, otherwise use as-is.
    try {
      token = JSON.parse(token);
    } catch (e) {
      // not JSON, leave token as-is
    }
    if (token) config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Error handling (401 token expire pe logout)
instance.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('authToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default instance;