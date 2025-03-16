import axios from 'axios';
import { ElMessage } from 'element-plus';

// 创建axios实例
const request = axios.create({
  // 基础URL，将自动加在 url 前面
  baseURL: '/api',
  // 请求超时时间
  timeout: 10000
});

// 请求拦截器
request.interceptors.request.use(
  config => {
    // 可以在这里设置请求头、token等
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
    const res = response.data;
    
    // 如果返回的code不为1，说明后端接口返回了错误信息
    if (res.code !== 1) {
      ElMessage.error(res.msg || '请求失败');
      return Promise.reject(new Error(res.msg || '未知错误'));
    } else {
      return res;
    }
  },
  error => {
    let message = '';
    if (error.response) {
      // 服务器返回错误状态码
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
      message = '服务器无响应，请稍后重试';
    } else {
      // 请求设置有误
      message = '请求配置错误';
    }
    
    console.error('请求错误:', error);
    ElMessage.error(message);
    return Promise.reject(error);
  }
);

export default request; 