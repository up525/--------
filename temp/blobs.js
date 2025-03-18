/**
 * 处理BLOB数据工具函数
 * 用于处理后端返回的BLOB类型数据
 */

/**
 * 处理对象中的BLOB字段
 * @param {Object} obj - 含有BLOB数据的对象
 * @returns {Object} - 处理后的对象
 */
export function processBlobs(obj) {
  if (!obj || typeof obj !== 'object') return obj;
  
  const result = Array.isArray(obj) ? [] : {};
  
  for (const key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      const value = obj[key];
      
      if (value === '<<BLOB>>') {
        // 如果值是BLOB标记，替换为空字符串
        result[key] = '';
      } else if (typeof value === 'object' && value !== null) {
        // 递归处理嵌套对象
        result[key] = processBlobs(value);
      } else {
        // 保持其他值不变
        result[key] = value;
      }
    }
  }
  
  return result;
}