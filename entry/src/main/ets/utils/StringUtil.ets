/**
 * 字符串处理工具类
 */
class StringUtil {
  
  /**
   * 将字符串转换为Uint8Array
   * @param str 要转换的字符串
   * @returns Uint8Array
   */
  static stringToUint8Array(str: string): Uint8Array {
    const bytes = new Uint8Array(str.length);
    for (let i = 0; i < str.length; i++) {
      bytes[i] = str.charCodeAt(i) & 0xFF;
    }
    return bytes;
  }
}

export default StringUtil;