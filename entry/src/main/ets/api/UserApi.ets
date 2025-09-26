import http from '@ohos.net.http';
import { ResultData, UserPageQueryDto, GetUserPagedResponse } from '../types/UserApiTypes';
import fs from '@ohos.file.fs';
import { BusinessError } from '@ohos.base';

/**
 * 用户分页查询接口
 * @param dto 查询参数
 * @param callback 回调函数，返回结果或 null
 */
export function fetchUserPage(dto: UserPageQueryDto, callback: (result: GetUserPagedResponse | null) => void) {
  let httpRequest = http.createHttp();
  httpRequest.request(
    "https://www.apisorcery.com/demo-api/user/paged",
    {
      method: http.RequestMethod.POST,
      header: { "Content-Type": "application/json" },
      extraData: JSON.stringify(dto)
    },
    (err, data) => {
      if (!err) {
        let resp: ResultData<GetUserPagedResponse>;
        if (typeof data.result === 'string') {
          try {
            resp = JSON.parse(data.result) as ResultData<GetUserPagedResponse>;
          } catch (e) {
            console.error('响应解析失败:', data.result);
            callback(null);
            httpRequest.destroy();
            return;
          }
        } else {
          resp = data.result as ResultData<GetUserPagedResponse>;
        }
        if (resp.status === 0 && resp.data) {
          callback(resp.data as GetUserPagedResponse);
        } else {
          callback(null);
        }
      } else {
        console.error("请求失败:", JSON.stringify(err));
        callback(null);
      }
      httpRequest.destroy();
    }
  );
}


/**
 * 简化的文件上传接口，直接返回文件URL
 * @param filePath 文件路径（URI）
 * @param description 文件描述（可选）
 * @param callback 回调函数，返回文件URL或null
 */
export async function uploadFile(filePath: string, description?: string,
  callback?: (url: string | null) => void): Promise<void> {
  const httpRequest: http.HttpRequest = http.createHttp();

  try {
    // 从文件路径中提取文件名
    const fileName: string = filePath.substring(filePath.lastIndexOf('/') + 1) || 'upload.jpg';

    // 异步处理文件读取和上传
    try {
      console.info('开始处理文件上传，文件路径:', filePath);
      const file: fs.File = await fs.open(filePath, fs.OpenMode.READ_ONLY);
      try {
        // 限制文件大小为500KB以避免413错误
        const maxFileSize: number = 500 * 1024; // 500KB
        const initialBuffer: ArrayBuffer = new ArrayBuffer(maxFileSize);

        // 读取文件内容
        const bytesRead: number = await fs.read(file.fd, initialBuffer);
        const fileSizeKB = Math.round(bytesRead / 1024);
        console.info('实际读取字节数:', bytesRead, '(' + fileSizeKB + 'KB)');

        // 关闭文件
        await fs.close(file.fd);

        if (bytesRead === 0) {
          console.error('文件为空或读取失败');
          callback?.(null);
          httpRequest.destroy();
          return;
        }

        // 检查文件大小是否超过限制
        if (bytesRead >= maxFileSize) {
          const maxSizeKB = Math.round(maxFileSize / 1024);
          const actualSizeKB = Math.round(bytesRead / 1024);
          console.error('文件过大，超过限制大小', maxSizeKB, 'KB，实际读取了', actualSizeKB, 'KB');
          callback?.(null);
          httpRequest.destroy();
          return;
        }

        // 构建multipart/form-data格式的请求体
        const boundary: string = '----WebKitFormBoundary' + Math.random().toString(36).substr(2, 16);
        let body: string = '';

        // 添加文件字段
        body += `--${boundary}\r\n`;
        body += `Content-Disposition: form-data; name="file"; filename="${fileName}"\r\n`;
        body += `Content-Type: image/jpeg\r\n\r\n`;

        // 将ArrayBuffer转换为二进制字符串
        const uint8Array: Uint8Array = new Uint8Array(initialBuffer, 0, bytesRead);
        let binaryString: string = '';
        for (let i = 0; i < uint8Array.length; i++) {
          binaryString += String.fromCharCode(uint8Array[i]);
        }

        body += binaryString;
        body += '\r\n';

        // 添加描述字段（如果有）
        if (description) {
          body += `--${boundary}\r\n`;
          body += `Content-Disposition: form-data; name="description"\r\n\r\n`;
          body += description;
          body += '\r\n';
        }

        body += `--${boundary}--\r\n`;

        // 发送请求
        httpRequest.request(
          "https://www.apisorcery.com/demo-api/file/upload",
          {
            method: http.RequestMethod.POST,
            header: {
              'Content-Type': `multipart/form-data; boundary=${boundary}`
            },
            extraData: body
          },
          (err: BusinessError | undefined, data: http.HttpResponse): void => {
            if (!err && data) {
              try {
                let result: string = '';

                if (typeof data.result === 'string') {
                  // 检查是否是HTML错误响应（如413错误）
                  if (data.result.includes('<html>') || data.result.includes('413 Request Entity Too Large')) {
                    console.error('服务器返回413错误 - 文件过大:', data.result);
                    callback?.(null);
                    httpRequest.destroy();
                    return;
                  }
                  
                  // 检查其他常见的HTML错误
                  if (data.result.includes('<html>') && data.result.includes('<title>')) {
                    console.error('服务器返回HTML错误页面:', data.result);
                    callback?.(null);
                    httpRequest.destroy();
                    return;
                  }

                  // 尝试解析JSON响应
                  try {
                    const resp: Record<string, string | number | boolean | Object> =
                      JSON.parse(data.result) as Record<string, string | number | boolean | Object>;

                    // 如果返回的是包装的响应，提取URL
                    if (resp.data && typeof resp.data === 'string') {
                      result = resp.data;
                    } else if (resp.url && typeof resp.url === 'string') {
                      result = resp.url;
                    } else {
                      result = data.result;
                    }
                  } catch (parseError) {
                    // 如果解析失败，假设直接返回的是URL字符串
                    result = data.result;
                  }
                } else {
                  result = String(data.result);
                }

                if (result && result.length > 0 && !result.includes('<html>')) {
                  console.info('文件上传成功，URL:', result);
                  callback?.(result);
                } else {
                  console.error('文件上传响应格式异常:', data.result);
                  callback?.(null);
                }
              } catch (processError) {
                console.error('文件上传响应处理失败:', processError);
                callback?.(null);
              }
            } else {
              console.error("文件上传请求失败:", err ? JSON.stringify(err) : '未知错误');
              callback?.(null);
            }
            httpRequest.destroy();
          }
        );

      } catch (fileError) {
        // 确保文件被关闭
        try {
          await fs.close(file.fd);
        } catch (closeError) {
          console.warn('关闭文件失败:', closeError);
        }
        // 将错误转换为标准Error类型
        if (fileError instanceof Error) {
          throw fileError;
        } else {
          throw new Error('文件操作失败: ' + String(fileError));
        }
      }

    } catch (error) {
      console.error('文件操作失败:', error);
      callback?.(null);
      httpRequest.destroy();
    }

  } catch (error) {
    console.error('创建上传请求失败:', error);
    callback?.(null);
    httpRequest.destroy();
  }
}
