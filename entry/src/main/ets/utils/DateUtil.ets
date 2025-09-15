// 日期相关工具方法
// 将 UTC ISO 时间字符串转为东八区格式: YYYY-MM-DD HH:mm:ss
export function formatToCST(iso: string): string {
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

// 预留：相对时间（x分钟前）可在这里继续拓展
export function formatRelativeFromNow(iso: string): string {
  if (!iso) return '';
  const d = new Date(iso);
  if (isNaN(d.getTime())) return iso;
  const now = Date.now();
  const diffSec = Math.floor((now - d.getTime()) / 1000);
  if (diffSec < 60) return '刚刚';
  if (diffSec < 3600) return `${Math.floor(diffSec / 60)} 分钟前`;
  if (diffSec < 86400) return `${Math.floor(diffSec / 3600)} 小时前`;
  if (diffSec < 86400 * 7) return `${Math.floor(diffSec / 86400)} 天前`;
  return formatToCST(iso).split(' ')[0];
}
