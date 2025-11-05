// Axios 全局实例封装
import axios, { AxiosInstance } from '@ohos/axios';
import { registerRequestInterceptors } from '../../interceptors/request';
import { registerResponseInterceptors } from '../../interceptors/response';

// 基础配置，可按需放到环境配置中
const requestClient: AxiosInstance = axios.create({
  baseURL: 'https://www.apisorcery.com/demo-api',
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json'
  }
});

// 注册统一请求拦截器（抽离到单独文件）
registerRequestInterceptors(requestClient);

// 注册统一响应拦截器（抽离到单独文件）
registerResponseInterceptors(requestClient);

export interface PlainResult<T> {
  status?: number;
  message?: string;
  data?: T;

  [k: string]: unknown;
}

export default requestClient;