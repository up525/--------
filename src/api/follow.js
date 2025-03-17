import request from '@/utils/request';

// 客户跟进相关API

/**
 * 获取客户跟进列表
 * @param {Object} params - 查询参数
 * @returns {Promise}
 */
export function getFollowList(params) {
  console.log('客户跟进列表请求参数:', params);
  return request({
    url: '/customer-follows/list',
    method: 'get',
    params,
    // 添加超时时间，确保有足够时间处理BLOB数据
    timeout: 30000,
    // 添加序列化配置，确保能处理二进制数据
    responseType: 'json'
  }).then(response => {
    console.log('客户跟进列表响应状态:', response.code);
    try {
      // 尝试记录响应主体，但避免记录大型BLOB数据
      const logData = { ...response };
      if (logData.data && logData.data.list) {
        logData.data.list = logData.data.list.map(item => {
          const itemCopy = { ...item };
          if (itemCopy.content) itemCopy.content = '<<BLOB数据>>';
          if (itemCopy.nextPlan) itemCopy.nextPlan = '<<BLOB数据>>';
          return itemCopy;
        });
      }
      console.log('客户跟进列表响应(过滤BLOB):', logData);
    } catch (e) {
      console.error('记录响应时出错:', e);
    }
    
    // 确保返回的数据符合预期格式
    if (!response.data) {
      response.data = { list: [], total: 0 };
    } else if (!response.data.list) {
      response.data = { 
        list: Array.isArray(response.data) ? response.data : [], 
        total: response.data.total || 0 
      };
    }
    
    return response;
  }).catch(error => {
    console.error('客户跟进列表请求失败:', error);
    throw error;
  });
}

/**
 * 根据ID获取客户跟进详情
 * @param {Number} id - 跟进记录ID
 * @returns {Promise}
 */
export function getFollowById(id) {
  console.log('获取跟进详情, ID:', id);
  return request({
    url: `/customer-follows/${id}`,
    method: 'get',
    // 添加超时时间，确保有足够时间处理BLOB数据
    timeout: 30000,
    // 添加序列化配置，确保能处理二进制数据
    responseType: 'json'
  }).then(response => {
    console.log('跟进详情响应状态:', response.code);
    try {
      // 尝试记录响应主体，但避免记录大型BLOB数据
      const logData = { ...response };
      if (logData.data) {
        if (logData.data.content) logData.data.content = '<<BLOB数据>>';
        if (logData.data.nextPlan) logData.data.nextPlan = '<<BLOB数据>>';
      }
      console.log('跟进详情响应(过滤BLOB):', logData);
    } catch (e) {
      console.error('记录响应时出错:', e);
    }
    return response;
  }).catch(error => {
    console.error('获取跟进详情失败:', error);
    throw error;
  });
}

/**
 * 添加客户跟进记录
 * @param {Object} data - 跟进记录数据
 * @returns {Promise}
 */
export function addFollow(data) {
  console.log('添加跟进记录数据:', data);
  return request({
    url: '/customer-follows',
    method: 'post',
    data
  }).then(response => {
    console.log('添加跟进记录响应:', response);
    return response;
  }).catch(error => {
    console.error('添加跟进记录失败:', error);
    throw error;
  });
}

/**
 * 修改客户跟进记录
 * @param {Object} data - 跟进记录数据
 * @returns {Promise}
 */
export function updateFollow(data) {
  console.log('更新跟进记录数据:', data);
  return request({
    url: '/customer-follows',
    method: 'put',
    data
  }).then(response => {
    console.log('更新跟进记录响应:', response);
    return response;
  }).catch(error => {
    console.error('更新跟进记录失败:', error);
    throw error;
  });
}

/**
 * 删除客户跟进记录
 * @param {Number} id - 跟进记录ID
 * @returns {Promise}
 */
export function deleteFollow(id) {
  console.log('删除跟进记录, ID:', id);
  return request({
    url: `/customer-follows/${id}`,
    method: 'delete'
  }).then(response => {
    console.log('删除跟进记录响应:', response);
    return response;
  }).catch(error => {
    console.error('删除跟进记录失败:', error);
    throw error;
  });
} 