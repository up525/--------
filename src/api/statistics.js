import request from '@/utils/request';

/**
 * 获取月度销售统计数据
 * @param {Object} params - 查询参数
 * @returns {Promise}
 */
export function getMonthlySalesStatistics(params) {
  console.log('获取月度销售统计数据，参数:', params);
  
  // 实际API调用
  return request({
    url: '/statistics/sales/monthly',
    method: 'get',
    params
  });
}

/**
 * 获取客户地区分布统计数据
 * @param {Object} params - 查询参数
 * @returns {Promise}
 */
export function getCustomerDistribution(params) {
  console.log('获取客户地区分布统计数据，参数:', params);
  
  // 实际API调用
  return request({
    url: '/statistics/customer/distribution',
    method: 'get',
    params
  });
}

/**
 * 获取产品销售占比统计数据
 * @param {Object} params - 查询参数
 * @returns {Promise}
 */
export function getProductSalesPercentage(params) {
  console.log('获取产品销售占比统计数据，参数:', params);
  
  // 实际API调用
  return request({
    url: '/statistics/product/percentage',
    method: 'get',
    params
  });
}

/**
 * 获取销售渠道分析统计数据
 * @param {Object} params - 查询参数
 * @returns {Promise}
 */
export function getSalesChannelAnalysis(params) {
  console.log('获取销售渠道分析统计数据，参数:', params);
  
  // 实际API调用
  return request({
    url: '/statistics/sales/channel',
    method: 'get',
    params
  });
}

/**
 * 获取销售人员业绩排名统计数据
 * @param {Object} params - 查询参数
 * @returns {Promise}
 */
export function getSalespersonPerformance(params) {
  console.log('获取销售人员业绩排名统计数据，参数:', params);
  
  // 实际API调用
  return request({
    url: '/statistics/salesperson/performance',
    method: 'get',
    params
  });
}

/**
 * 生成统计数据
 * @param {Object} data - 统计参数
 * @returns {Promise}
 */
export function generateStatistics(data) {
  console.log('生成统计数据，参数:', data);
  
  // 实际API调用
  return request({
    url: '/statistics/generate',
    method: 'post',
    data
  });
} 