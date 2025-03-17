import request from '@/utils/request';

/**
 * 处理BLOB或JSON字符串响应
 * @param {Object} response - API响应数据
 * @returns {Object} 处理后的数据
 */
export function processResponse(response) {
  console.log('处理API响应:', response);
  
  // 如果响应已经是标准格式，直接返回
  if (response.code === 1 && response.data) {
    return response;
  }
  
  try {
    // 如果data是字符串，尝试解析为JSON
    if (typeof response.data === 'string') {
      try {
        response.data = JSON.parse(response.data);
        console.log('字符串响应已解析为JSON对象');
      } catch (e) {
        console.warn('响应不是有效的JSON字符串:', e);
      }
    }
    
    // 处理BLOB数据
    if (response.data) {
      // 检查是否有BLOB类型的字段
      for (const key in response.data) {
        if (typeof response.data[key] === 'object' && response.data[key] !== null) {
          // 检查是否是BLOB对象
          if (
            response.data[key].data instanceof Array || 
            response.data[key] instanceof Uint8Array || 
            response.data[key] instanceof ArrayBuffer
          ) {
            console.log(`检测到BLOB字段: ${key}`);
            try {
              // 尝试将BLOB转换为字符串
              const blob = response.data[key];
              let text;
              
              if (blob instanceof Uint8Array) {
                text = new TextDecoder().decode(blob);
              } else if (blob.data instanceof Array) {
                text = new TextDecoder().decode(new Uint8Array(blob.data));
              } else {
                text = JSON.stringify(blob);
              }
              
              // 尝试解析为JSON
              try {
                response.data[key] = JSON.parse(text);
                console.log(`成功解析${key}字段为JSON对象`);
              } catch (e) {
                console.warn(`${key}字段内容不是有效的JSON:`, e);
                response.data[key] = text;
              }
            } catch (e) {
              console.error(`处理${key}字段BLOB数据失败:`, e);
            }
          }
        }
      }
    }
    
    return response;
  } catch (e) {
    console.error('处理响应数据出错:', e);
    return response;
  }
}

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
    params,
    responseType: 'json',
    timeout: 30000
  }).then(response => processResponse(response));
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
    params,
    responseType: 'json',
    timeout: 30000
  }).then(response => processResponse(response));
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
    params,
    responseType: 'json',
    timeout: 30000
  }).then(response => processResponse(response));
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
    params,
    responseType: 'json',
    timeout: 30000
  }).then(response => {
    const processedResponse = processResponse(response);
    console.log('处理后的销售渠道分析数据:', processedResponse);
    
    // 特殊处理渠道分析数据
    if (processedResponse.data) {
      try {
        // 检查是否有channels, newCustomers, returningCustomers字段
        if (processedResponse.data.channels && 
            typeof processedResponse.data.channels === 'string') {
          try {
            processedResponse.data.channels = JSON.parse(processedResponse.data.channels);
          } catch (e) {
            console.warn('解析channels字段失败:', e);
          }
        }
        
        if (processedResponse.data.newCustomers && 
            typeof processedResponse.data.newCustomers === 'string') {
          try {
            processedResponse.data.newCustomers = JSON.parse(processedResponse.data.newCustomers);
          } catch (e) {
            console.warn('解析newCustomers字段失败:', e);
          }
        }
        
        if (processedResponse.data.returningCustomers || processedResponse.data.oldCustomers) {
          const oldCustomersField = processedResponse.data.returningCustomers || 
                                   processedResponse.data.oldCustomers;
          
          if (typeof oldCustomersField === 'string') {
            try {
              processedResponse.data.oldCustomers = JSON.parse(oldCustomersField);
            } catch (e) {
              console.warn('解析oldCustomers字段失败:', e);
            }
          } else {
            processedResponse.data.oldCustomers = oldCustomersField;
          }
        }
      } catch (e) {
        console.error('处理销售渠道数据特殊字段失败:', e);
      }
    }
    
    return processedResponse;
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
    params,
    responseType: 'json',
    timeout: 30000
  }).then(response => {
    const processedResponse = processResponse(response);
    console.log('处理后的销售人员业绩排名数据:', processedResponse);
    
    // 特殊处理销售人员业绩数据
    if (processedResponse.data && Array.isArray(processedResponse.data)) {
      // 转换成图表需要的格式
      const salespeople = [];
      const salesAmount = [];
      const salesCount = [];
      
      processedResponse.data.forEach(item => {
        // 解析销售人员名称
        salespeople.push(item.name);
        
        // 解析销售金额和数量
        if (item.value) {
          let valueObj = item.value;
          
          // 如果value是字符串，尝试解析为JSON
          if (typeof valueObj === 'string') {
            try {
              valueObj = JSON.parse(valueObj);
            } catch (e) {
              console.warn('解析value字段失败:', e);
              valueObj = { amount: 0, count: 0 };
            }
          }
          
          salesAmount.push(valueObj.amount || 0);
          salesCount.push(valueObj.count || 0);
        } else {
          salesAmount.push(0);
          salesCount.push(0);
        }
      });
      
      // 替换为格式化后的数据
      processedResponse.data = {
        salespeople,
        salesAmount,
        salesCount
      };
    }
    
    return processedResponse;
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
    data,
    timeout: 30000
  }).then(response => processResponse(response));
} 