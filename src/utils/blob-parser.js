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
 * 格式化BLOB字段对象
 * 用于处理整个对象中的BLOB字段
 * @param {Object} obj - 包含BLOB字段的对象
 * @param {Array<String>} blobFields - BLOB字段名称数组
 * @returns {Object} - 处理后的对象
 */
export function formatObjectWithBlobs(obj, blobFields = ['content', 'nextPlan']) {
  if (!obj || typeof obj !== 'object') {
    return obj;
  }
  
  const result = { ...obj };
  
  blobFields.forEach(field => {
    if (obj[field] !== undefined) {
      result[field] = parseBlobContent(obj[field], '');
    }
  });
  
  return result;
}

/**
 * 处理整个数据列表中的BLOB字段
 * @param {Array<Object>} list - 对象数组
 * @param {Array<String>} blobFields - BLOB字段名称数组
 * @returns {Array<Object>} - 处理后的对象数组
 */
export function formatListWithBlobs(list, blobFields = ['content', 'nextPlan']) {
  if (!Array.isArray(list)) {
    return [];
  }
  
  return list.map(item => formatObjectWithBlobs(item, blobFields));
}

export default {
  parseBlobContent,
  readBlobAsync,
  formatObjectWithBlobs,
  formatListWithBlobs
}; 