// 统一响应拦截器注册入口
import { AxiosInstance, AxiosResponse } from '@ohos/axios';
import { BlobResp } from '../types/axios';

/**
 * 注册通用响应拦截器：
 * - 成功直接返回 response
 * - 失败打印错误并向上抛出
 * 可扩展：
 *   1. 业务错误码集中处理
 *   2. 自动刷新 token / 重试逻辑
 *   3. 将后端包装结构扁平化
 */
export function registerResponseInterceptors(instance: AxiosInstance) {
  instance.interceptors.response.use(
    async (res: AxiosResponse) => {
      // 从 config 中获取请求ID
      const requestId = (res.config as any).requestId || 'UNKNOWN';
      
      // 打印响应日志
      console.info(`=== API 响应成功 【${requestId}】 ===`);
      console.info(`【${requestId}】响应状态码:`, res.status);
      console.info(`【${requestId}】响应URL:`, res.config.url);
      console.info(`【${requestId}】响应头:`, JSON.stringify(res.headers));
      
      // 可以在这里做统一的 data 解包，例如：
      // if (response.data && typeof response.data === 'object' && 'status' in response.data) { ... }
      
      // Return blob format for file download
      if (res.data instanceof ArrayBuffer) {
        console.info(`【${requestId}】响应类型: 文件下载 (ArrayBuffer)`);
        console.info(`=== 【${requestId}】 响应结束 ===`);
        return <BlobResp>{
          data: res.data,
          type: res.headers['content-type'],
          name: decodeURIComponent(
            res.headers['content-disposition'].substring(
              res.headers['content-disposition'].indexOf('=') + 1
            )
          ),
        };
      }
      
      // 打印响应数据
      if (res.data) {
        console.info(`【${requestId}】响应数据:`, JSON.stringify(res.data));
      }
      
      if (res.data.status === 0) {
        console.info(`【${requestId}】业务状态: 成功 (status=0)`);
        console.info(`【${requestId}】返回数据:`, JSON.stringify(res.data.data));
        console.info(`=== 【${requestId}】 响应结束 ===`);
        return res.data.data;
      }

      // 业务错误
      let dataErrMsg = res.data.message || 'Error';
      console.warn(`【${requestId}】业务状态: 失败`);
      console.warn(`【${requestId}】错误状态码:`, res.data.status);
      console.warn(`【${requestId}】错误信息:`, dataErrMsg);
      console.info(`=== 【${requestId}】 响应结束 ===`);
      return Promise.reject(new Error(dataErrMsg));
    },
    async (error: any) => {
      // 从 config 中获取请求ID
      const requestId = (error.config as any)?.requestId || 'UNKNOWN';
      
      console.error(`=== API 响应错误 【${requestId}】 ===`);
      console.error(`【${requestId}】错误对象:`, typeof error === 'object' ? JSON.stringify(error) : String(error));
      
      if (error.response) {
        console.error(`【${requestId}】HTTP状态码:`, error.response.status);
        console.error(`【${requestId}】响应头:`, JSON.stringify(error.response.headers));
        console.error(`【${requestId}】响应数据:`, JSON.stringify(error.response.data));
      } else if (error.request) {
        console.error(`【${requestId}】请求已发送但未收到响应`);
        console.error(`【${requestId}】请求信息:`, JSON.stringify(error.request));
      } else {
        console.error(`【${requestId}】请求配置错误:`, error.message);
      }
      
      if (error.config) {
        console.error(`【${requestId}】请求配置:`, JSON.stringify({
          url: error.config.url,
          method: error.config.method,
          baseURL: error.config.baseURL,
          headers: error.config.headers
        }));
      }
      console.error(`=== 【${requestId}】 响应结束 ===`);
      
      return Promise.reject(error);
    }
  );
}
