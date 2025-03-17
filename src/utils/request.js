import axios from 'axios';
import { ElMessage } from 'element-plus';

// 创建axios实例
const request = axios.create({
  // 基础URL，将自动加在 url 前面
  baseURL: '/api',
  // 请求超时时间
  timeout: 30000,
  // 允许跨域带Cookie
  withCredentials: true,
  // 默认接受JSON响应
  responseType: 'json'
});

// 请求拦截器
request.interceptors.request.use(
  config => {
    // 可以在这里设置请求头、token等
    console.log('Request sent:', config.method.toUpperCase(), config.baseURL + config.url, config.params || config.data);
    
    // 添加请求标识
    config.requestId = Date.now() + Math.random().toString(36).substring(2, 10);
    
    return config;
  },
  error => {
    console.error('请求拦截器错误:', error);
    return Promise.reject(error);
  }
);

// 响应拦截器
request.interceptors.response.use(
  response => {
    console.log('Response received:', response.config.url, response.status, response.headers['content-type'] || '未知类型');
    
    // 根据内容类型处理响应
    const contentType = response.headers['content-type'] || '';
    
    // BLOB数据特殊处理
    if (contentType.includes('application/octet-stream') || contentType.includes('text/plain')) {
      console.log('收到二进制或文本响应:', contentType);
      
      // 尝试判断响应是否已经是对象
      if (typeof response.data === 'object' && response.data !== null && !Buffer.isBuffer(response.data)) {
        console.log('二进制响应已被解析为对象');
        if (response.data.code !== 1) {
          ElMessage.error(response.data.message || '请求失败');
          return Promise.reject(new Error(response.data.message || '未知错误'));
        }
        return response.data;
      }
      
      // 尝试作为JSON解析
      if (typeof response.data === 'string') {
        try {
          const jsonData = JSON.parse(response.data);
          console.log('文本响应解析为JSON对象');
          
          if (jsonData.code !== 1) {
            ElMessage.error(jsonData.message || '请求失败');
            return Promise.reject(new Error(jsonData.message || '未知错误'));
          }
          return jsonData;
        } catch (e) {
          console.log('响应不是有效的JSON格式，返回原始数据');
          // 不是有效的JSON，返回原始响应
          return {
            code: 1,
            message: 'success',
            data: response.data
          };
        }
      }
      
      // 其他二进制数据，包装为标准响应格式
      return {
        code: 1,
        message: 'success',
        data: response.data
      };
    }
    
    // 标准JSON响应处理
    const res = response.data;
    
    // 检查响应格式
    if (res === undefined || res === null) {
      console.error('响应数据为空');
      return {
        code: 1,
        message: 'success',
        data: { list: [], total: 0 }
      };
    }
    
    // 如果已经是标准对象但没有code字段，添加标准字段
    if (typeof res === 'object' && res !== null && res.code === undefined) {
      console.log('响应对象没有code字段，添加标准字段');
      return {
        code: 1,
        message: 'success',
        data: res
      };
    }
    
    // 如果返回的code不为1，说明后端接口返回了错误信息
    if (res.code !== 1) {
      console.error('API error response:', res);
      ElMessage.error(res.message || '请求失败');
      return Promise.reject(new Error(res.message || '未知错误'));
    } else {
      return res;
    }
  },
  error => {
    let message = '';
    if (error.response) {
      // 服务器返回错误状态码
      console.error('Server error:', error.response.status, error.response.data);
      switch (error.response.status) {
        case 400:
          message = '请求错误';
          break;
        case 401:
          message = '未授权，请重新登录';
          // 可以在这里处理登录过期或未登录的情况
          break;
        case 403:
          message = '拒绝访问';
          break;
        case 404:
          message = '请求地址不存在';
          break;
        case 500:
          message = '服务器内部错误';
          break;
        default:
          message = `请求失败: ${error.response.status}`;
      }
    } else if (error.request) {
      // 请求发出但没有收到响应
      console.error('No response from server:', error.request);
      message = '服务器无响应，请稍后重试';
    } else {
      // 请求设置有误
      console.error('Request configuration error:', error.message);
      message = '请求配置错误';
    }
    
    console.error('请求错误:', error);
    ElMessage.error(message);
    return Promise.reject(error);
  }
);

export default request; 