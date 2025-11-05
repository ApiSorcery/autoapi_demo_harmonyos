import http from '@ohos.net.http';
import { ResultData, UserPageQueryDto, GetUserPagedResponse } from '../types/UserApiTypes';
import { BusinessError } from '@ohos.base';
import fs from '@ohos.file.fs';
import stringUtil from '../utils/StringUtil';
import fileUtil from '../utils/FileUtil';

// 上传文件参数对象接口
interface GeneratedTypeLiteralInterface_1 {
  data: Uint8Array;
  bytesRead: number;
}

export interface UploadFileOptions {
  filePath: string; // 文件路径或 URI
  description?: string; // 可选描述
  callback?: (url: string | null) => void; // 上传完成回调
  preRead?: GeneratedTypeLiteralInterface_1;
}

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
export async function uploadFile(options: UploadFileOptions): Promise<void> {
  const filePath = options.filePath;
  const description = options.description;
  const callback = options.callback;
  const preRead = options.preRead;
  const httpRequest: http.HttpRequest = http.createHttp();

  try {
    // 从文件路径中提取文件名
    const fileName: string = filePath.substring(filePath.lastIndexOf('/') + 1) || 'upload.jpg';

    // 获取文件Content-Type
    const contentType = fileUtil.getContentType(fileName);

    // 异步处理文件读取和上传
    try {
      console.info('开始处理文件上传，文件路径:', filePath);
      let fileData: Uint8Array;
      let bytesRead: number;
      if (preRead) {
        // 使用外部传入的预读取结果
        fileData = preRead.data;
        bytesRead = preRead.bytesRead;
        console.info('使用预读取数据，字节数:', bytesRead);
      } else {
        // 正常读取文件
        const file: fs.File = await fs.open(filePath, fs.OpenMode.READ_ONLY);
        const stat = await fs.stat(filePath);
        const buffer = new ArrayBuffer(stat.size);
        bytesRead = await fs.read(file.fd, buffer);
        await fs.close(file.fd);
        console.info('读取文件完成，字节数:', bytesRead);
        fileData = new Uint8Array(buffer, 0, bytesRead);
      }

      // 构建multipart/form-data格式的请求体
      const boundary: string = '----WebKitFormBoundary' + Math.random().toString(36).substr(2, 16);

      // 准备multipart数据的各个部分
      const boundaryBytes = stringUtil.stringToUint8Array(`--${boundary}\r\n`);
      const headerBytes = stringUtil.stringToUint8Array(
        `Content-Disposition: form-data; name="file"; filename="${fileName}"\r\n` +
          `Content-Type: ${contentType}\r\n\r\n`
      );
      const endBoundaryPart1 = stringUtil.stringToUint8Array('\r\n');

      let descriptionBytes = new Uint8Array(0);
      if (description) {
        descriptionBytes = stringUtil.stringToUint8Array(
          `--${boundary}\r\n` +
            `Content-Disposition: form-data; name="description"\r\n\r\n` +
            description + '\r\n'
        );
      }

      const finalBoundary = stringUtil.stringToUint8Array(`--${boundary}--\r\n`);

      // 计算总长度
      const totalLength = boundaryBytes.length + headerBytes.length + fileData.length +
      endBoundaryPart1.length + descriptionBytes.length + finalBoundary.length;

      // 创建完整的请求体ArrayBuffer
      const bodyBuffer = new ArrayBuffer(totalLength);
      const bodyView = new Uint8Array(bodyBuffer);

      let offset = 0;
      bodyView.set(boundaryBytes, offset);
      offset += boundaryBytes.length;
      bodyView.set(headerBytes, offset);
      offset += headerBytes.length;
      bodyView.set(fileData, offset);
      offset += fileData.length;
      bodyView.set(endBoundaryPart1, offset);
      offset += endBoundaryPart1.length;
      if (descriptionBytes.length > 0) {
        bodyView.set(descriptionBytes, offset);
        offset += descriptionBytes.length;
      }
      bodyView.set(finalBoundary, offset);

      // 发送请求
      httpRequest.request(
        "https://www.apisorcery.com/demo-api/file/upload",
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': `multipart/form-data; boundary=${boundary}`
          },
          extraData: bodyBuffer
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
