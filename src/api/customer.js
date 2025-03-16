import request from '@/utils/request';

// 客户管理相关API

/**
 * 获取客户列表
 * @param {Object} params - 查询参数
 * @returns {Promise}
 */
export function getCustomerList(params) {
  return request({
    url: '/customers',
    method: 'get',
    params
  });
}

/**
 * 根据ID获取客户详情
 * @param {Number} id - 客户ID
 * @returns {Promise}
 */
export function getCustomerById(id) {
  return request({
    url: `/customers/${id}`,
    method: 'get'
  });
}

/**
 * 添加客户
 * @param {Object} data - 客户数据
 * @returns {Promise}
 */
export function addCustomer(data) {
  return request({
    url: '/customers',
    method: 'post',
    data
  });
}

/**
 * 修改客户
 * @param {Object} data - 客户数据
 * @returns {Promise}
 */
export function updateCustomer(data) {
  return request({
    url: '/customers',
    method: 'put',
    data
  });
}

/**
 * 删除客户
 * @param {Number} id - 客户ID
 * @returns {Promise}
 */
export function deleteCustomer(id) {
  return request({
    url: `/customers/${id}`,
    method: 'delete'
  });
} 