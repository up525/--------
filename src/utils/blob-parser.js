/**
 * BLOB数据解析工具
 * 用于解析后端返回的BLOB/二进制数据
 */
import arrToString from 'arraybuffer-to-string';

/**
 * 尝试解析BLOB数据为字符串
 * @param {Object|Blob|String|ArrayBuffer} data - 要解析的数据
 * @param {String} defaultValue - 解析失败时的默认值
 * @returns {String} - 解析后的字符串
 */
export function parseBlobContent(data, defaultValue = '') {
  // 如果数据为空，返回默认值
  if (data === null || data === undefined) {
    console.log('BLOB数据为空');
    return defaultValue;
  }
  
  try {
    // 如果是ArrayBuffer
    if (data instanceof ArrayBuffer) {
      console.log('解析ArrayBuffer');
      try {
        // 尝试使用UTF-8解码
        return arrToString(data, 'utf8');
      } catch (e) {
        // 如果失败，使用其他编码尝试
        console.warn('UTF-8解码失败，尝试ASCII:', e);
        return arrToString(data, 'ascii');
      }
    }
    
    // 如果是Blob对象
    if (data instanceof Blob) {
      console.log('解析Blob对象');
      // 注意：这是异步操作，这里我们无法直接返回结果
      // 实际使用时应该返回一个Promise
      return '查看详情...';
    }
    
    // 如果是类似Blob的JSON对象
    if (typeof data === 'object' && data !== null) {
      console.log('解析类Blob对象');
      
      // 检查是否是MySQL BLOB数据的特殊表示
      if (data._buf || data.buffer) {
        const buf = data._buf || data.buffer;
        if (buf instanceof ArrayBuffer || (buf && buf.type === 'Buffer')) {
          console.log('MySQL BLOB数据');
          try {
            // 如果是Buffer数据
            if (buf.type === 'Buffer' && Array.isArray(buf.data)) {
              const buffer = new Uint8Array(buf.data).buffer;
              return arrToString(buffer, 'utf8');
            }
            // 如果是ArrayBuffer
            return arrToString(buf, 'utf8');
          } catch (e) {
            console.warn('BLOB缓冲区解析失败:', e);
            return '二进制数据...';
          }
        }
      }
      
      if (data.data && data.type) {
        // 可能是JSON格式的Blob表示
        return '二进制数据...';
      }
      
      // 普通对象，尝试各种方法获取值
      if (data.value !== undefined) {
        return String(data.value);
      }
      
      if (data.content !== undefined) {
        return String(data.content);
      }
      
      if (data.text !== undefined) {
        return String(data.text);
      }
      
      // 其他对象转为JSON字符串
      return JSON.stringify(data);
    }
    
    // 如果是字符串，检查是否是JSON字符串
    if (typeof data === 'string') {
      // 检查是否是JSON字符串
      if (data.startsWith('{') && data.endsWith('}')) {
        try {
          const obj = JSON.parse(data);
          // 尝试从对象中提取值
          if (obj.value !== undefined) {
            return String(obj.value);
          }
          
          if (obj.content !== undefined) {
            return String(obj.content);
          }
          
          if (obj.text !== undefined) {
            return String(obj.text);
          }
          
          // 没有找到值属性，返回原始字符串
          return data;
        } catch (e) {
          // 解析失败，可能不是有效的JSON
          console.warn('JSON解析失败:', e);
          return data;
        }
      }
      
      // 普通字符串直接返回
      return data;
    }
    
    // 其他类型，转为字符串
    return String(data);
  } catch (e) {
    console.error('BLOB解析错误:', e);
    return defaultValue;
  }
}

/**
 * 异步解析BLOB数据
 * 用于需要异步读取的Blob对象
 * @param {Blob} blob - Blob对象
 * @returns {Promise<String>} - 解析后的字符串Promise
 */
export function readBlobAsync(blob) {
  return new Promise((resolve, reject) => {
    if (!(blob instanceof Blob)) {
      resolve(parseBlobContent(blob, '非Blob数据'));
      return;
    }
    
    const reader = new FileReader();
    reader.onload = () => {
      try {
        const text = reader.result;
        resolve(parseBlobContent(text, '读取成功但无法解析'));
      } catch (e) {
        console.error('Blob读取后解析出错:', e);
        reject(e);
      }
    };
    reader.onerror = (e) => {
      console.error('Blob读取错误:', e);
      reject(e);
    };
    reader.readAsText(blob);
  });
}

/**
 * BLOB数据处理工具函数
 * 用于处理后端返回的BLOB二进制数据和各种格式的数据结构
 */

/**
 * 处理单个对象中的BLOB字段
 * @param {Object} obj - 需要处理的对象
 * @returns {Object} - 处理后的对象
 */
export function formatObjectWithBlobs(obj) {
  if (!obj || typeof obj !== 'object') return obj;
  
  const result = { ...obj };
  
  // 遍历所有字段
  for (const key in result) {
    // 跳过继承的属性
    if (!Object.prototype.hasOwnProperty.call(result, key)) continue;
    
    const value = result[key];
    
    // 处理嵌套对象
    if (value && typeof value === 'object' && !Array.isArray(value)) {
      // 检查是否是BLOB对象
      if (value.data instanceof Array || 
          value instanceof Uint8Array || 
          value instanceof ArrayBuffer) {
        
        try {
          // 尝试将BLOB转换为字符串
          let text = '';
          if (value instanceof Uint8Array) {
            text = new TextDecoder().decode(value);
          } else if (value.data instanceof Array) {
            text = new TextDecoder().decode(new Uint8Array(value.data));
          } else {
            text = JSON.stringify(value);
          }
          
          // 尝试解析为JSON
          try {
            result[key] = JSON.parse(text);
            console.log(`成功解析${key}字段为JSON对象`);
          } catch (e) {
            console.warn(`${key}字段内容不是有效的JSON，保留为文本`);
            result[key] = text;
          }
        } catch (e) {
          console.error(`处理${key}字段BLOB数据失败:`, e);
        }
      } else {
        // 递归处理普通嵌套对象
        result[key] = formatObjectWithBlobs(value);
      }
    } 
    // 处理字符串类型（可能是JSON字符串）
    else if (typeof value === 'string' && value.trim().startsWith('{')) {
      try {
        result[key] = JSON.parse(value);
        console.log(`成功解析${key}字符串为JSON对象`);
      } catch (e) {
        // 保持原始值
      }
    }
    // 处理数组
    else if (Array.isArray(value)) {
      result[key] = formatListWithBlobs(value);
    }
  }
  
  return result;
}

/**
 * 处理数组中的BLOB字段
 * @param {Array} list - 需要处理的数组
 * @returns {Array} - 处理后的数组
 */
export function formatListWithBlobs(list) {
  if (!Array.isArray(list)) return list;
  
  return list.map(item => {
    if (item && typeof item === 'object') {
      return formatObjectWithBlobs(item);
    }
    return item;
  });
}

/**
 * 安全解析JSON字符串
 * @param {String} str - 需要解析的JSON字符串
 * @param {*} defaultValue - 解析失败时的默认值
 * @returns {*} - 解析结果或默认值
 */
export function safeParseJSON(str, defaultValue = null) {
  if (typeof str !== 'string') return defaultValue;
  
  try {
    return JSON.parse(str);
  } catch (e) {
    console.warn('JSON解析失败:', e);
    return defaultValue;
  }
}

/**
 * 提取值和趋势
 * @param {Object} data - 数据对象
 * @param {String} fieldName - 字段名
 * @param {*} defaultValue - 默认值
 * @returns {Object} - {value, trend} 格式的结果
 */
export function extractValueAndTrend(data, fieldName, defaultValue = 0) {
  if (!data || typeof data !== 'object') {
    return { value: defaultValue, trend: 0 };
  }
  
  try {
    const fieldData = data[fieldName];
    const trendField = `${fieldName}Trend`;
    let value = defaultValue;
    let trend = 0;
    
    if (fieldData === undefined || fieldData === null) {
      console.warn(`${fieldName} 字段不存在或为空`);
    } else if (typeof fieldData === 'object') {
      // 如果是对象，尝试获取value和trend属性
      value = fieldData.value !== undefined ? fieldData.value : 
             fieldData.count !== undefined ? fieldData.count : defaultValue;
      trend = fieldData.trend !== undefined ? fieldData.trend : data[trendField] || 0;
    } else if (typeof fieldData === 'string') {
      // 如果是字符串，尝试解析为JSON
      const parsedValue = safeParseJSON(fieldData);
      if (parsedValue !== null && typeof parsedValue === 'object') {
        value = parsedValue.value !== undefined ? parsedValue.value : 
               parsedValue.count !== undefined ? parsedValue.count : defaultValue;
        trend = parsedValue.trend !== undefined ? parsedValue.trend : data[trendField] || 0;
      } else {
        value = parsedValue !== null ? parsedValue : 
               (isNaN(Number(fieldData)) ? defaultValue : Number(fieldData));
        trend = data[trendField] || 0;
      }
    } else {
      // 数字或其他类型，直接使用
      value = fieldData;
      trend = data[trendField] || 0;
    }
    
    return { value, trend };
  } catch (e) {
    console.error(`处理${fieldName}时出错:`, e);
    return { value: defaultValue, trend: 0 };
  }
}

/**
 * 格式化数字
 * @param {*} num - 需要格式化的数字
 * @param {String} defaultValue - 默认值
 * @returns {String} - 格式化后的字符串
 */
export function formatNumber(num, defaultValue = '0') {
  if (num === undefined || num === null) return defaultValue;
  
  // 确保num是数字
  const value = typeof num === 'string' ? parseFloat(num) : num;
  if (isNaN(value)) return defaultValue;
  
  return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

export default {
  parseBlobContent,
  readBlobAsync,
  formatObjectWithBlobs,
  formatListWithBlobs
}; 