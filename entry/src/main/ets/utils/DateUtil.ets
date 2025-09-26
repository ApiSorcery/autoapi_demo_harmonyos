/**
 * 日期处理工具类
 */
class DateUtil {
  
  /**
   * 将 UTC ISO 时间字符串转为东八区格式: YYYY-MM-DD HH:mm:ss
   * @param iso ISO时间字符串
   * @returns 格式化的日期字符串
   */
  static formatToCST(iso: string): string {
    if (!iso) return '';
    const d = new Date(iso);
    if (isNaN(d.getTime())) {
      return iso; // 非法日期原样返回
    }
    const bjMs = d.getTime() + 8 * 3600 * 1000; // +8 小时
    const bj = new Date(bjMs);
    const pad = (n: number) => (n < 10 ? '0' + n : '' + n);
    const Y = bj.getUTCFullYear();
    const M = pad(bj.getUTCMonth() + 1);
    const D = pad(bj.getUTCDate());
    const h = pad(bj.getUTCHours());
    const m = pad(bj.getUTCMinutes());
    const s = pad(bj.getUTCSeconds());
    return `${Y}-${M}-${D} ${h}:${m}:${s}`;
  }

  /**
   * 格式化为相对时间（x分钟前）
   * @param iso ISO时间字符串
   * @returns 相对时间字符串
   */
  static formatRelativeFromNow(iso: string): string {
    if (!iso) return '';
    const d = new Date(iso);
    if (isNaN(d.getTime())) return iso;
    const now = Date.now();
    const diffSec = Math.floor((now - d.getTime()) / 1000);
    if (diffSec < 60) return '刚刚';
    if (diffSec < 3600) return `${Math.floor(diffSec / 60)} 分钟前`;
    if (diffSec < 86400) return `${Math.floor(diffSec / 3600)} 小时前`;
    if (diffSec < 86400 * 7) return `${Math.floor(diffSec / 86400)} 天前`;
    return DateUtil.formatToCST(iso).split(' ')[0];
  }
}

export default DateUtil;
