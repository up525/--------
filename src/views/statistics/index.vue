<template>
  <div class="statistics-container">
    <h1 class="page-title">销售统计分析</h1>
    
    <div class="charts-row">
      <el-card class="chart-card">
        <template #header>
          <div class="card-header">
            <span>销售业绩趋势</span>
            <el-radio-group v-model="salesTrendPeriod" size="small" @change="fetchSalesTrend">
              <el-radio-button label="month">月度</el-radio-button>
              <el-radio-button label="quarter">季度</el-radio-button>
              <el-radio-button label="year">年度</el-radio-button>
            </el-radio-group>
          </div>
        </template>
        <div ref="salesTrendChart" class="chart" v-loading="loadingStatuses.salesTrend"></div>
      </el-card>
      
      <el-card class="chart-card">
        <template #header>
          <div class="card-header">
            <span>客户分布</span>
          </div>
        </template>
        <div ref="customerDistributionChart" class="chart" v-loading="loadingStatuses.customerDistribution"></div>
      </el-card>
    </div>
    
    <div class="charts-row">
      <el-card class="chart-card">
        <template #header>
          <div class="card-header">
            <span>产品销售占比</span>
          </div>
        </template>
        <div ref="productSalesChart" class="chart" v-loading="loadingStatuses.productSales"></div>
      </el-card>
      
      <el-card class="chart-card">
        <template #header>
          <div class="card-header">
            <span>销售渠道分析</span>
          </div>
        </template>
        <div ref="salesChannelChart" class="chart" v-loading="loadingStatuses.salesChannel"></div>
      </el-card>
    </div>
    
    <div class="charts-row">
      <el-card class="chart-card full-width">
        <template #header>
          <div class="card-header">
            <span>销售人员业绩排名</span>
            <el-select v-model="performancePeriod" placeholder="选择时间段" size="small" @change="fetchSalespersonPerformance">
              <el-option label="本月" value="month"></el-option>
              <el-option label="本季度" value="quarter"></el-option>
              <el-option label="本年度" value="year"></el-option>
            </el-select>
          </div>
        </template>
        <div ref="salesPerformanceChart" class="chart" v-loading="loadingStatuses.salesPerformance"></div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue';
import * as echarts from 'echarts';
import { ElMessage } from 'element-plus';
import { 
  getMonthlySalesStatistics, 
  getCustomerDistribution, 
  getProductSalesPercentage,
  getSalesChannelAnalysis,
  getSalespersonPerformance
} from '@/api/statistics';

// 响应式数据
const salesTrendPeriod = ref('month');
const performancePeriod = ref('month');

// 加载状态
const loadingStatuses = ref({
  salesTrend: false,
  customerDistribution: false,
  productSales: false,
  salesChannel: false,
  salesPerformance: false
});

// 图表引用
const salesTrendChart = ref(null);
const customerDistributionChart = ref(null);
const productSalesChart = ref(null);
const salesChannelChart = ref(null);
const salesPerformanceChart = ref(null);

// 图表实例
let salesTrendInstance = null;
let customerDistributionInstance = null;
let productSalesInstance = null;
let salesChannelInstance = null;
let salesPerformanceInstance = null;

// 监听窗口大小变化
const handleResize = () => {
  salesTrendInstance?.resize();
  customerDistributionInstance?.resize();
  productSalesInstance?.resize();
  salesChannelInstance?.resize();
  salesPerformanceInstance?.resize();
};

// 初始化图表
onMounted(() => {
  try {
    // 初始化所有图表
    initCharts();
    
    // 获取所有图表数据
    fetchAllChartData();
    
    // 监听窗口大小变化
    window.addEventListener('resize', handleResize);
  } catch (error) {
    console.error('图表初始化失败:', error);
    ElMessage.error('图表初始化失败，请刷新页面重试');
  }
});

// 初始化所有图表
const initCharts = () => {
  salesTrendInstance = echarts.init(salesTrendChart.value);
  customerDistributionInstance = echarts.init(customerDistributionChart.value);
  productSalesInstance = echarts.init(productSalesChart.value);
  salesChannelInstance = echarts.init(salesChannelChart.value);
  salesPerformanceInstance = echarts.init(salesPerformanceChart.value);
};

// 获取所有图表数据
const fetchAllChartData = () => {
  fetchSalesTrend();
  fetchCustomerDistribution();
  fetchProductSales();
  fetchSalesChannel();
  fetchSalespersonPerformance();
};

// 清理工作
onUnmounted(() => {
  // 销毁图表实例以防内存泄漏
  salesTrendInstance?.dispose();
  customerDistributionInstance?.dispose();
  productSalesInstance?.dispose();
  salesChannelInstance?.dispose();
  salesPerformanceInstance?.dispose();
  
  // 移除事件监听
  window.removeEventListener('resize', handleResize);
});

// 销售趋势图表
const fetchSalesTrend = async () => {
  loadingStatuses.value.salesTrend = true;
  try {
    const params = {
      period: salesTrendPeriod.value
    };
    const res = await getMonthlySalesStatistics(params);
    
    if (res && res.data) {
      const option = {
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'shadow'
          }
        },
        legend: {
          data: ['实际销售额', '销售目标', '同比增长率'],
          bottom: 0
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '12%',
          top: '5%',
          containLabel: true
        },
        xAxis: [
          {
            type: 'category',
            data: res.data.xAxis || []
          }
        ],
        yAxis: [
          {
            type: 'value',
            name: '金额',
            axisLabel: {
              formatter: '{value} 万'
            }
          },
          {
            type: 'value',
            name: '增长率',
            axisLabel: {
              formatter: '{value} %'
            }
          }
        ],
        series: [
          {
            name: '实际销售额',
            type: 'bar',
            data: res.data.actualSales || []
          },
          {
            name: '销售目标',
            type: 'bar',
            data: res.data.targetSales || []
          },
          {
            name: '同比增长率',
            type: 'line',
            yAxisIndex: 1,
            data: res.data.growthRate || []
          }
        ]
      };
      
      salesTrendInstance.setOption(option);
    }
  } catch (error) {
    console.error('获取销售趋势数据失败:', error);
    ElMessage.error('获取销售趋势数据失败，请稍后重试');
  } finally {
    loadingStatuses.value.salesTrend = false;
  }
};

// 客户分布图表
const fetchCustomerDistribution = async () => {
  loadingStatuses.value.customerDistribution = true;
  try {
    const res = await getCustomerDistribution();
    console.log('客户分布数据:', res.data);
    
    if (res && res.data) {
      // 安全解析数据
      let regionsData = [];
      let pieData = [];
      
      // 尝试从不同可能的数据结构中提取数据
      if (Array.isArray(res.data)) {
        // 如果是数组格式，直接使用
        regionsData = res.data.map(item => item.name || '未知区域');
        pieData = res.data.map(item => ({
          name: item.name || '未知区域',
          value: typeof item.value === 'number' ? item.value : parseInt(item.value) || 0
        }));
      } else if (res.data.data && Array.isArray(res.data.data)) {
        // 标准格式
        regionsData = res.data.regions || res.data.data.map(item => item.name || '未知区域');
        pieData = res.data.data;
      } else if (res.data.regions && Array.isArray(res.data.regions)) {
        // 使用regions和data字段
        regionsData = res.data.regions;
        pieData = res.data.data || regionsData.map((region, index) => ({
          name: region,
          value: (res.data.values && res.data.values[index]) || 0
        }));
      } else {
        // 尝试从对象中构建数据
        regionsData = Object.keys(res.data).filter(key => key !== 'code' && key !== 'message');
        pieData = regionsData.map(key => ({
          name: key,
          value: typeof res.data[key] === 'number' ? res.data[key] : 0
        }));
      }
      
      const option = {
        tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b}: {c} ({d}%)'
        },
        legend: {
          orient: 'vertical',
          right: 10,
          top: 'center',
          data: regionsData
        },
        series: [
          {
            name: '客户分布',
            type: 'pie',
            radius: ['50%', '70%'],
            avoidLabelOverlap: false,
            emphasis: {
              label: {
                show: true,
                fontSize: '16',
                fontWeight: 'bold'
              }
            },
            labelLine: {
              show: true
            },
            data: pieData
          }
        ]
      };
      
      customerDistributionInstance.setOption(option);
    }
  } catch (error) {
    console.error('获取客户分布数据失败:', error);
    ElMessage.error('获取客户分布数据失败，请稍后重试');
  } finally {
    loadingStatuses.value.customerDistribution = false;
  }
};

// 产品销售占比图表
const fetchProductSales = async () => {
  loadingStatuses.value.productSales = true;
  try {
    const res = await getProductSalesPercentage();
    console.log('产品销售占比数据:', res.data);
    
    if (res && res.data) {
      // 安全解析数据
      let productsData = [];
      let pieData = [];
      
      // 尝试从不同可能的数据结构中提取数据
      if (Array.isArray(res.data)) {
        // 如果是数组格式，直接使用
        productsData = res.data.map(item => item.name || '未知产品');
        pieData = res.data.map(item => ({
          name: item.name || '未知产品',
          value: typeof item.value === 'number' ? item.value : parseFloat(item.value) || 0
        }));
      } else if (res.data.data && Array.isArray(res.data.data)) {
        // 标准格式
        productsData = res.data.products || res.data.data.map(item => item.name || '未知产品');
        pieData = res.data.data;
      } else if (res.data.products && Array.isArray(res.data.products)) {
        // 使用products和values字段
        productsData = res.data.products;
        pieData = res.data.data || productsData.map((product, index) => ({
          name: product,
          value: (res.data.values && res.data.values[index]) || 0
        }));
      } else {
        // 尝试从对象中构建数据
        productsData = Object.keys(res.data).filter(key => key !== 'code' && key !== 'message');
        pieData = productsData.map(key => ({
          name: key,
          value: typeof res.data[key] === 'number' ? res.data[key] : 0
        }));
      }
      
      const option = {
        tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b}: {c} ({d}%)'
        },
        legend: {
          orient: 'vertical',
          left: 10,
          top: 'center',
          data: productsData
        },
        series: [
          {
            name: '产品销售',
            type: 'pie',
            radius: '60%',
            center: ['60%', '50%'],
            data: pieData,
            emphasis: {
              itemStyle: {
                shadowBlur: 10,
                shadowOffsetX: 0,
                shadowColor: 'rgba(0, 0, 0, 0.5)'
              }
            }
          }
        ]
      };
      
      productSalesInstance.setOption(option);
    }
  } catch (error) {
    console.error('获取产品销售占比数据失败:', error);
    ElMessage.error('获取产品销售占比数据失败，请稍后重试');
  } finally {
    loadingStatuses.value.productSales = false;
  }
};

// 销售渠道分析图表
const fetchSalesChannel = async () => {
  loadingStatuses.value.salesChannel = true;
  try {
    const res = await getSalesChannelAnalysis();
    console.log('销售渠道分析数据:', res.data);
    
    if (res && res.data) {
      // 安全处理数据
      let channels = [];
      let newCustomers = [];
      let oldCustomers = [];
      
      // 检查并解析渠道数据
      if (res.data.channels) {
        if (Array.isArray(res.data.channels)) {
          channels = res.data.channels;
        } else if (typeof res.data.channels === 'string') {
          // 尝试解析JSON字符串
          try {
            channels = JSON.parse(res.data.channels);
          } catch (e) {
            console.warn('解析channels失败:', e);
            channels = ['未知渠道'];
          }
        }
      }
      
      // 检查并解析新客户数据
      if (res.data.newCustomers) {
        if (Array.isArray(res.data.newCustomers)) {
          newCustomers = res.data.newCustomers;
        } else if (typeof res.data.newCustomers === 'string') {
          // 尝试解析JSON字符串
          try {
            newCustomers = JSON.parse(res.data.newCustomers);
          } catch (e) {
            console.warn('解析newCustomers失败:', e);
            newCustomers = [0];
          }
        }
      }
      
      // 检查并解析老客户数据（可能是returningCustomers或oldCustomers）
      const oldCustomersField = res.data.returningCustomers || res.data.oldCustomers;
      if (oldCustomersField) {
        if (Array.isArray(oldCustomersField)) {
          oldCustomers = oldCustomersField;
        } else if (typeof oldCustomersField === 'string') {
          // 尝试解析JSON字符串
          try {
            oldCustomers = JSON.parse(oldCustomersField);
          } catch (e) {
            console.warn('解析oldCustomers失败:', e);
            oldCustomers = [0];
          }
        }
      }
      
      // 确保数据长度一致
      const maxLength = Math.max(channels.length, newCustomers.length, oldCustomers.length);
      
      // 填充缺失数据
      if (channels.length < maxLength) {
        for (let i = channels.length; i < maxLength; i++) {
          channels.push(`渠道${i+1}`);
        }
      }
      
      if (newCustomers.length < maxLength) {
        newCustomers = newCustomers.concat(Array(maxLength - newCustomers.length).fill(0));
      }
      
      if (oldCustomers.length < maxLength) {
        oldCustomers = oldCustomers.concat(Array(maxLength - oldCustomers.length).fill(0));
      }
      
      const option = {
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'shadow'
          }
        },
        legend: {
          data: ['新客户', '老客户']
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          containLabel: true
        },
        xAxis: {
          type: 'value',
          boundaryGap: [0, 0.01]
        },
        yAxis: {
          type: 'category',
          data: channels
        },
        series: [
          {
            name: '新客户',
            type: 'bar',
            data: newCustomers
          },
          {
            name: '老客户',
            type: 'bar',
            data: oldCustomers
          }
        ]
      };
      
      salesChannelInstance.setOption(option);
    }
  } catch (error) {
    console.error('获取销售渠道分析数据失败:', error);
    ElMessage.error('获取销售渠道分析数据失败，请稍后重试');
  } finally {
    loadingStatuses.value.salesChannel = false;
  }
};

// 销售人员业绩排名图表
const fetchSalespersonPerformance = async () => {
  loadingStatuses.value.salesPerformance = true;
  try {
    const params = {
      period: performancePeriod.value
    };
    const res = await getSalespersonPerformance(params);
    console.log('销售人员业绩排名数据:', res.data);
    
    if (res && res.data) {
      // 安全处理数据
      let salespeople = [];
      let salesAmount = [];
      let salesCount = [];
      
      // 检查返回数据的格式
      if (res.data.salespeople && Array.isArray(res.data.salespeople)) {
        // 已经是需要的格式
        salespeople = res.data.salespeople;
        salesAmount = res.data.salesAmount || [];
        salesCount = res.data.salesCount || [];
      } else if (Array.isArray(res.data)) {
        // 需要手动处理数组数据
        salespeople = res.data.map(item => item.name || '未知');
        
        // 处理销售额和销售量
        res.data.forEach(item => {
          if (item.value) {
            if (typeof item.value === 'object') {
              salesAmount.push(item.value.amount || 0);
              salesCount.push(item.value.count || 0);
            } else if (typeof item.value === 'string') {
              try {
                const value = JSON.parse(item.value);
                salesAmount.push(value.amount || 0);
                salesCount.push(value.count || 0);
              } catch (e) {
                console.warn('解析sales value失败:', e);
                salesAmount.push(0);
                salesCount.push(0);
              }
            } else {
              salesAmount.push(0);
              salesCount.push(0);
            }
          } else {
            salesAmount.push(0);
            salesCount.push(0);
          }
        });
      }
      
      const option = {
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'shadow'
          }
        },
        legend: {
          data: ['销售额', '销售总量']
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          containLabel: true
        },
        xAxis: {
          type: 'category',
          data: salespeople
        },
        yAxis: [
          {
            type: 'value',
            name: '销售额',
            axisLabel: {
              formatter: '{value} 万'
            }
          },
          {
            type: 'value',
            name: '销售总量',
            axisLabel: {
              formatter: '{value}'
            }
          }
        ],
        series: [
          {
            name: '销售额',
            type: 'bar',
            data: salesAmount
          },
          {
            name: '销售总量',
            type: 'line',
            yAxisIndex: 1,
            data: salesCount
          }
        ]
      };
      
      salesPerformanceInstance.setOption(option);
    }
  } catch (error) {
    console.error('获取销售人员业绩排名数据失败:', error);
    ElMessage.error('获取销售人员业绩排名数据失败，请稍后重试');
  } finally {
    loadingStatuses.value.salesPerformance = false;
  }
};
</script>

<style scoped>
.statistics-container {
  padding: 20px;
}

.page-title {
  margin-bottom: 20px;
  font-size: 24px;
  font-weight: 600;
  color: #303133;
}

.charts-row {
  display: flex;
  margin-bottom: 20px;
  gap: 20px;
}

.chart-card {
  flex: 1;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.chart-card.full-width {
  width: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chart {
  height: 300px;
  width: 100%;
}

@media (max-width: 768px) {
  .charts-row {
    flex-direction: column;
  }
  
  .chart-card {
    margin-bottom: 20px;
  }
}
</style>
