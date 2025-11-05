// 统一请求拦截器注册入口
import { AxiosInstance, InternalAxiosRequestConfig } from '@ohos/axios';

/**
 * 注册通用请求拦截器：
 * - 可在此注入 token / 设备信息 / 语言 / 版本号 等
 * - 可做公共参数拼装
 */
export function registerRequestInterceptors(instance: AxiosInstance) {
  instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
    // 示例：追加统一 Header（按需开启）
    // config.headers = { ...(config.headers || {}), 'X-App-Version': '1.0.0' };
    // TODO: 可在此添加 token，例如：
    // const token = GlobalState.token; if (token) { config.headers = { ...(config.headers || {}), Authorization: `Bearer ${token}` }; }
    return config;
  });
}
