import axios, { AxiosInstance } from '@ohos/axios';
import { registerRequestInterceptors } from '../interceptors/request';
import { registerResponseInterceptors } from '../interceptors/response';

// 基础配置，可按需放到环境配置中
const requestClient: AxiosInstance = axios.create({
  baseURL: 'https://www.apisorcery.com/demo-api',
  timeout: 15000,
  headers: {
    'X-Requested-With': 'XMLHttpRequest',
    'Content-Type': 'application/json',
  }
});

// 注册统一请求拦截器
registerRequestInterceptors(requestClient);

// 注册统一响应拦截器
registerResponseInterceptors(requestClient);

export default requestClient;