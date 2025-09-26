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
}

export default FileUtil;