// 统一响应拦截器注册入口
import { AxiosInstance, AxiosResponse } from '@ohos/axios';
import { BlobResp } from '../../../auto/demo/model';

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
      // 可以在这里做统一的 data 解包，例如：
      // if (response.data && typeof response.data === 'object' && 'status' in response.data) { ... }
      if (res.data.status === 0) {
        return res.data.data;
      }

      // Return blob format for file download
      if (res.data instanceof ArrayBuffer) {
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

      let dataErrMsg = res.data.message || 'Error';
      return Promise.reject(new Error(dataErrMsg));
    },
    async (error: any) => {
      try {
        console.error(
          'HTTP 响应错误:',
          typeof error === 'object' ? JSON.stringify(error) : String(error)
        );
      } catch {
        /* 序列化忽略 */
      }
      return Promise.reject(error);
    }
  );
}
