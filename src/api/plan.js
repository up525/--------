import request from '@/utils/request';

// 开发计划管理相关API

/**
 * 获取开发计划列表
 * @param {Object} params - 查询参数
 * @returns {Promise}
 */
export function getPlanList(params) {
  return request({
    url: '/plans',
    method: 'get',
    params
  });
}

/**
 * 根据ID获取开发计划详情
 * @param {Number} id - 开发计划ID
 * @returns {Promise}
 */
export function getPlanById(id) {
  return request({
    url: `/plans/${id}`,
    method: 'get'
  });
}

/**
 * 添加开发计划
 * @param {Object} data - 开发计划数据
 * @returns {Promise}
 */
export function addPlan(data) {
  return request({
    url: '/plans',
    method: 'post',
    data
  });
}

/**
 * 修改开发计划
 * @param {Object} data - 开发计划数据
 * @returns {Promise}
 */
export function updatePlan(data) {
  return request({
    url: '/plans',
    method: 'put',
    data
  });
}

/**
 * 删除开发计划
 * @param {Number} id - 开发计划ID
 * @returns {Promise}
 */
export function deletePlan(id) {
  return request({
    url: `/plans/${id}`,
    method: 'delete'
  });
} 