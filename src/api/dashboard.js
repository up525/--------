import request from '@/utils/request';

/**
 * 获取首页统计数据
 * @returns {Promise}
 */
export function getDashboardStatistics() {
  console.log('获取首页统计数据');
  
  // 实际API调用
  return request({
    url: '/statistics/dashboard',
    method: 'get'
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
    method: 'get'
  });
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
    }
  });
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
    method: 'get'
  });
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
    method: 'get'
  });
} 