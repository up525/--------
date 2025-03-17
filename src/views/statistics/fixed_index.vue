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
    
    if (res && res.data) {
      const option = {
        tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b}: {c} ({d}%)'
        },
        legend: {
          orient: 'vertical',
          right: 10,
          top: 'center',
          data: res.data.regions || []
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
            data: res.data.data || []
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
    
    if (res && res.data) {
      const option = {
        tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b}: {c} ({d}%)'
        },
        legend: {
          orient: 'vertical',
          left: 10,
          top: 'center',
          data: res.data.products || []
        },
        series: [
          {
            name: '产品销售',
            type: 'pie',
            radius: '60%',
            center: ['60%', '50%'],
            data: res.data.data || [],
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
    
    if (res && res.data) {
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
          data: res.data.channels || []
        },
        series: [
          {
            name: '新客户',
            type: 'bar',
            data: res.data.newCustomers || []
          },
          {
            name: '老客户',
            type: 'bar',
            data: res.data.oldCustomers || []
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
    
    if (res && res.data) {
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
          data: res.data.salespeople || []
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
            data: res.data.salesAmount || []
          },
          {
            name: '销售总量',
            type: 'line',
            yAxisIndex: 1,
            data: res.data.salesCount || []
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
