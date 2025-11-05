import fs from '@ohos.file.fs';

// 文件读取失败原因枚举
export enum FileReadFailReason {
  EMPTY_FILE = 'EMPTY_FILE',
  FILE_TOO_LARGE = 'FILE_TOO_LARGE'
}

// 文件读取结果类型别名，统一复用
// 文件读取结果类型别名，统一复用
export interface FileReadResult {
  ok: boolean;
  bytesRead: number;
  data: ArrayBuffer | null;
  reason?: FileReadFailReason;
}

/**
 * 文件处理工具类
 */
class FileUtil {
  /**
   * 根据文件扩展名确定Content-Type
   * @param fileName 文件名
   * @returns Content-Type字符串
   */
  static getContentType(fileName: string): string {
    const ext = fileName.toLowerCase().substring(fileName.lastIndexOf('.') + 1);
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'image/jpeg'; // 默认
    }
  }

  /**
   * 判断文件名是否为常见图片类型
   * @param fileName 文件名或路径
   * @returns 是否图片扩展
   */
  static isImage(fileName: string): boolean {
    if (!fileName) {
      return false;
    }
    const lastDot = fileName.lastIndexOf('.');
    if (lastDot === -1 || lastDot === fileName.length - 1) {
      return false; // 无扩展名
    }
    const ext = fileName.substring(lastDot + 1).toLowerCase();
    // 扩展白名单（包含 getContentType 支持的与补充格式）
    const imageExts: Set<string> = new Set([
      'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg', 'ico', 'tiff', 'tif', 'avif'
    ]);
    return imageExts.has(ext);
  }

  /**
   * 读取文件并做大小校验（最大值包含上限前的所有字节，超出或等于上限视为失败）
   * @param file 文件
   * @param maxFileSizeBytes 最大允许字节数（例如 500 * 1024）
   * @returns Promise 包含校验结果
   */
  static async readFileWithinLimit(file: fs.File, maxFileSizeBytes: number): Promise<FileReadResult> {
    const buffer = new ArrayBuffer(maxFileSizeBytes);
    const bytesRead: number = await fs.read(file.fd, buffer);
    const sizeKB = Math.round(bytesRead / 1024);
    console.info('实际读取字节数:', bytesRead, '(' + sizeKB + 'KB)');
    if (bytesRead === 0) {
      return {
        ok: false,
        bytesRead,
        data: null,
        reason: FileReadFailReason.EMPTY_FILE
      };
    }
    if (bytesRead >= maxFileSizeBytes) {
      return {
        ok: false,
        bytesRead,
        data: null,
        reason: FileReadFailReason.FILE_TOO_LARGE
      };
    }

    return { ok: true, bytesRead, data: buffer };
  }
}

export default FileUtil;