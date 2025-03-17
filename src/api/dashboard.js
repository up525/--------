import request from '@/utils/request';
import { processResponse } from './statistics'; // 导入共享的处理函数

/**
 * 获取首页统计数据
 * @returns {Promise}
 */
export function getDashboardStatistics() {
  console.log('获取首页统计数据');
  
  // 实际API调用
  return request({
    url: '/statistics/dashboard',
    method: 'get',
    timeout: 30000,
    responseType: 'json'
  }).then(response => {
    const processedResponse = processResponse(response);
    console.log('处理后的首页统计数据:', processedResponse);
    
    // 如果是数组或对象，但没有预期的数据结构，增加兼容处理
    if (processedResponse.data) {
      // 确保关键字段存在
      const ensureFields = ['customerCount', 'monthlySales', 'orderCount', 'newCustomerCount'];
      ensureFields.forEach(field => {
        if (processedResponse.data[field] === undefined) {
          processedResponse.data[field] = 0;
        } else if (typeof processedResponse.data[field] === 'object' && processedResponse.data[field] !== null) {
          // 如果某个字段是对象（例如，可能是BLOB处理后的JSON对象），提取其value属性
          console.log(`${field}字段是对象:`, processedResponse.data[field]);
          const value = processedResponse.data[field].value || processedResponse.data[field].count || 0;
          processedResponse.data[field] = typeof value === 'number' ? value : parseInt(value) || 0;
        }
      });
    }
    
    return processedResponse;
  });
}

/**
 * 获取客户总数
 * @returns {Promise}
 */
export function getCustomerCount() {
  console.log('获取客户总数');
  
  // 实际API调用
  return request({
    url: '/customers/count',
    method: 'get',
    timeout: 30000
  }).then(processResponse);
}

/**
 * 获取本月销售额
 * @returns {Promise}
 */
export function getMonthlySales() {
  console.log('获取本月销售额');
  
  // 实际API调用
  return request({
    url: '/statistics/sales/monthly',
    method: 'get',
    params: {
      period: 'current'
    },
    timeout: 30000,
    responseType: 'json'
  }).then(processResponse);
}

/**
 * 获取订单数量
 * @returns {Promise}
 */
export function getOrderCount() {
  console.log('获取订单数量');
  
  // 实际API调用
  return request({
    url: '/orders/count',
    method: 'get',
    timeout: 30000
  }).then(processResponse);
}

/**
 * 获取新增客户数量
 * @returns {Promise}
 */
export function getNewCustomerCount() {
  console.log('获取新增客户数量');
  
  // 实际API调用
  return request({
    url: '/customers/new-count',
    method: 'get',
    timeout: 30000
  }).then(processResponse);
} 