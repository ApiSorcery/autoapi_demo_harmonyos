// 统一请求拦截器注册入口
import { AxiosInstance, InternalAxiosRequestConfig } from '@ohos/axios';

// 生成唯一的请求ID
let requestIdCounter = 0;
function generateRequestId(): string {
  requestIdCounter++;
  return `REQ_${Date.now()}_${requestIdCounter}`;
}

/**
 * 注册通用请求拦截器：
 * - 可在此注入 token / 设备信息 / 语言 / 版本号 等
 * - 可做公共参数拼装
 */
export function registerRequestInterceptors(instance: AxiosInstance) {
  instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
    // 生成请求ID并存储在 config 中
    const requestId = generateRequestId();
    (config as any).requestId = requestId;
    
    // 打印请求日志
    console.info(`=== API 请求开始 【${requestId}】 ===`);
    console.info(`【${requestId}】请求方法:`, config.method?.toUpperCase());
    console.info(`【${requestId}】请求URL:`, config.baseURL + config.url);
    console.info(`【${requestId}】请求头:`, JSON.stringify(config.headers));
    
    if (config.params) {
      console.info(`【${requestId}】请求参数(params):`, JSON.stringify(config.params));
    }
    
    if (config.data) {
      // 如果是 FormData，不打印内容（太大）
      if (typeof config.data === 'string') {
        console.info(`【${requestId}】请求体(data):`, config.data);
      } else {
        console.info(`【${requestId}】请求体(data):`, JSON.stringify(config.data));
      }
    }
    console.info(`=== 【${requestId}】 请求发送 ===`);
    
    // 示例：追加统一 Header（按需开启）
    // config.headers = { ...(config.headers || {}), 'X-App-Version': '1.0.0' };
    // TODO: 可在此添加 token，例如：
    // const token = GlobalState.token; if (token) { config.headers = { ...(config.headers || {}), Authorization: `Bearer ${token}` }; }
    return config;
  }, (error: any) => {
    console.error('=== API 请求拦截器错误 ===');
    console.error('错误信息:', JSON.stringify(error));
    return Promise.reject(error);
  });
}
