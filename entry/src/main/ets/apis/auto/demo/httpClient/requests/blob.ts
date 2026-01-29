// Axios 全局实例封装
import axios, { AxiosInstance } from '@ohos/axios';
import { registerRequestInterceptors } from '../interceptors/request';
import { registerResponseInterceptors } from '../interceptors/response';

// Create axios instance   withCredentials: true,
const requestClient = axios.create({
  baseURL: 'https://www.apisorcery.com/demo-api',
  timeout: 60000,
  responseType: 'array_buffer',
  headers: {
    'X-Requested-With': 'XMLHttpRequest',
  },
})

// 注册统一请求拦截器
registerRequestInterceptors(requestClient);

// 注册统一响应拦截器
registerResponseInterceptors(requestClient);

export default requestClient
