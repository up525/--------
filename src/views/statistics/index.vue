<template>
  <div class="statistics-container">
    <h1 class="page-title">销售统计分析</h1>
    
    <div class="charts-row">
      <el-card class="chart-card">
        <template #header>
          <div class="card-header">
            <span>销售业绩趋势</span>
            <el-radio-group v-model="salesTrendPeriod" size="small">
              <el-radio-button label="month">月度</el-radio-button>
              <el-radio-button label="quarter">季度</el-radio-button>
              <el-radio-button label="year">年度</el-radio-button>
            </el-radio-group>
          </div>
        </template>
        <div ref="salesTrendChart" class="chart"></div>
      </el-card>
      
      <el-card class="chart-card">
        <template #header>
          <div class="card-header">
            <span>客户分布</span>
          </div>
        </template>
        <div ref="customerDistributionChart" class="chart"></div>
      </el-card>
    </div>
    
    <div class="charts-row">
      <el-card class="chart-card">
        <template #header>
          <div class="card-header">
            <span>产品销售占比</span>
          </div>
        </template>
        <div ref="productSalesChart" class="chart"></div>
      </el-card>
      
      <el-card class="chart-card">
        <template #header>
          <div class="card-header">
            <span>销售渠道分析</span>
          </div>
        </template>
        <div ref="salesChannelChart" class="chart"></div>
      </el-card>
    </div>
    
    <div class="charts-row">
      <el-card class="chart-card full-width">
        <template #header>
          <div class="card-header">
            <span>销售人员业绩排名</span>
            <el-select v-model="performancePeriod" placeholder="选择时间段" size="small">
              <el-option label="本月" value="month"></el-option>
              <el-option label="本季度" value="quarter"></el-option>
              <el-option label="本年度" value="year"></el-option>
            </el-select>
          </div>
        </template>
        <div ref="salesPerformanceChart" class="chart"></div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue';
import * as echarts from 'echarts';

// 响应式数据
const salesTrendPeriod = ref('month');
const performancePeriod = ref('month');

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
    initSalesTrendChart();
    initCustomerDistributionChart();
    initProductSalesChart();
    initSalesChannelChart();
    initSalesPerformanceChart();
    
    // 监听窗口大小变化
    window.addEventListener('resize', handleResize);
  } catch (error) {
    console.error('图表初始化失败:', error);
    // 可以在这里添加错误提示或回退逻辑
  }
});

// 销售趋势图表
const initSalesTrendChart = () => {
  try {
    if (!salesTrendChart.value) {
      console.warn('销售趋势图表DOM元素未找到');
      return;
    }
    salesTrendInstance = echarts.init(salesTrendChart.value);
    
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
          data: salesTrendPeriod.value === 'month' 
            ? ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月']
            : salesTrendPeriod.value === 'quarter'
              ? ['第一季度', '第二季度', '第三季度', '第四季度']
              : ['2021年', '2022年', '2023年', '2024年']
        }
      ],
      yAxis: [
        {
          type: 'value',
          name: '销售额(万元)',
          splitLine: {
            show: true,
            lineStyle: {
              type: 'dashed'
            }
          }
        },
        {
          type: 'value',
          name: '增长率(%)',
          splitLine: {
            show: false
          },
          axisLabel: {
            formatter: '{value}%'
          }
        }
      ],
      series: [
        {
          name: '实际销售额',
          type: 'bar',
          barWidth: salesTrendPeriod.value === 'month' ? 10 : 20,
          data: [120, 132, 101, 134, 90, 230, 210, 182, 191, 234, 290, 330]
        },
        {
          name: '销售目标',
          type: 'bar',
          barWidth: salesTrendPeriod.value === 'month' ? 10 : 20,
          data: [100, 120, 110, 140, 95, 220, 200, 190, 200, 230, 280, 320]
        },
        {
          name: '同比增长率',
          type: 'line',
          smooth: true,
          yAxisIndex: 1,
          data: [20, 10, -8, -4, -5, 5, 5, -4, -4, 2, 4, 3]
        }
      ]
    };
    
    salesTrendInstance.setOption(option);
  } catch (error) {
    console.error('初始化销售趋势图表失败:', error);
  }
};

// 客户分布图表
const initCustomerDistributionChart = () => {
  try {
    if (!customerDistributionChart.value) {
      console.warn('客户分布图表DOM元素未找到');
      return;
    }
    customerDistributionInstance = echarts.init(customerDistributionChart.value);
    
    const option = {
      tooltip: {
        trigger: 'item',
        formatter: '{a} <br/>{b}: {c} ({d}%)'
      },
      legend: {
        orient: 'vertical',
        right: 10,
        top: 'center',
        data: ['华东地区', '华南地区', '华北地区', '华中地区', '西南地区', '西北地区', '东北地区']
      },
      series: [
        {
          name: '客户分布',
          type: 'pie',
          radius: ['40%', '70%'],
          center: ['40%', '50%'],
          avoidLabelOverlap: false,
          itemStyle: {
            borderRadius: 10,
            borderColor: '#fff',
            borderWidth: 2
          },
          label: {
            show: false,
            position: 'center'
          },
          emphasis: {
            label: {
              show: true,
              fontSize: 30,
              fontWeight: 'bold'
            }
          },
          labelLine: {
            show: false
          },
          data: [
            { value: 1048, name: '华东地区' },
            { value: 735, name: '华南地区' },
            { value: 580, name: '华北地区' },
            { value: 484, name: '华中地区' },
            { value: 300, name: '西南地区' },
            { value: 200, name: '西北地区' },
            { value: 150, name: '东北地区' }
          ]
        }
      ]
    };
    
    customerDistributionInstance.setOption(option);
  } catch (error) {
    console.error('初始化客户分布图表失败:', error);
  }
};

// 产品销售占比图表
const initProductSalesChart = () => {
  try {
    if (!productSalesChart.value) {
      console.warn('产品销售占比图表DOM元素未找到');
      return;
    }
    productSalesInstance = echarts.init(productSalesChart.value);
    
    const option = {
      tooltip: {
        trigger: 'item',
        formatter: '{a} <br/>{b}: {c} ({d}%)'
      },
      legend: {
        bottom: 0,
        left: 'center',
        data: ['产品A', '产品B', '产品C', '产品D', '产品E', '其他产品']
      },
      series: [
        {
          name: '产品销售占比',
          type: 'pie',
          radius: '70%',
          center: ['50%', '40%'],
          data: [
            { value: 335, name: '产品A' },
            { value: 310, name: '产品B' },
            { value: 234, name: '产品C' },
            { value: 135, name: '产品D' },
            { value: 154, name: '产品E' },
            { value: 90, name: '其他产品' }
          ],
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
  } catch (error) {
    console.error('初始化产品销售占比图表失败:', error);
  }
};

// 销售渠道分析图表
const initSalesChannelChart = () => {
  try {
    if (!salesChannelChart.value) {
      console.warn('销售渠道分析图表DOM元素未找到');
      return;
    }
    salesChannelInstance = echarts.init(salesChannelChart.value);
    
    const option = {
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        }
      },
      legend: {
        bottom: 0,
        data: ['新客户', '老客户']
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '12%',
        top: '5%',
        containLabel: true
      },
      xAxis: {
        type: 'value',
        boundaryGap: [0, 0.01]
      },
      yAxis: {
        type: 'category',
        data: ['线下门店', '电话销售', '网站', '微信小程序', '合作伙伴']
      },
      series: [
        {
          name: '新客户',
          type: 'bar',
          data: [150, 120, 280, 200, 90]
        },
        {
          name: '老客户',
          type: 'bar',
          data: [80, 200, 150, 120, 180]
        }
      ]
    };
    
    salesChannelInstance.setOption(option);
  } catch (error) {
    console.error('初始化销售渠道分析图表失败:', error);
  }
};

// 销售人员业绩排名图表
const initSalesPerformanceChart = () => {
  try {
    if (!salesPerformanceChart.value) {
      console.warn('销售人员业绩排名图表DOM元素未找到');
      return;
    }
    salesPerformanceInstance = echarts.init(salesPerformanceChart.value);
    
    const option = {
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        }
      },
      legend: {
        data: ['销售额', '销售数量'],
        right: 10,
        top: 0
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: ['张三', '李四', '王五', '赵六', '钱七', '孙八', '周九', '吴十', '郑十一', '王十二'],
        axisLabel: {
          interval: 0,
          rotate: 30
        }
      },
      yAxis: [
        {
          type: 'value',
          name: '销售额(万元)',
          splitLine: {
            show: true,
            lineStyle: {
              type: 'dashed'
            }
          }
        },
        {
          type: 'value',
          name: '销售数量(台)',
          splitLine: {
            show: false
          }
        }
      ],
      series: [
        {
          name: '销售额',
          type: 'bar',
          data: [120, 115, 100, 95, 90, 85, 80, 75, 70, 65]
        },
        {
          name: '销售数量',
          type: 'line',
          yAxisIndex: 1,
          data: [80, 75, 68, 60, 55, 50, 45, 40, 35, 30]
        }
      ]
    };
    
    salesPerformanceInstance.setOption(option);
  } catch (error) {
    console.error('初始化销售人员业绩排名图表失败:', error);
  }
};

// 监听销售趋势时间周期变化
watch(salesTrendPeriod, () => {
  try {
    initSalesTrendChart();
  } catch (error) {
    console.error('更新销售趋势图表失败:', error);
  }
});

// 监听销售人员业绩时间周期变化
watch(performancePeriod, () => {
  try {
    // 这里可以根据选择的时间段更新数据
    // 为了演示，这里只是重新初始化图表
    initSalesPerformanceChart();
  } catch (error) {
    console.error('更新销售人员业绩图表失败:', error);
  }
});

// 在组件卸载时移除事件监听
onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
  salesTrendInstance?.dispose();
  customerDistributionInstance?.dispose();
  productSalesInstance?.dispose();
  salesChannelInstance?.dispose();
  salesPerformanceInstance?.dispose();
});
</script>

<style scoped>
.statistics-container {
  padding: 20px;
  height: 100%;
  overflow-y: auto;
  background-color: #f5f7fa;
}

.page-title {
  font-size: 24px;
  font-weight: bold;
  margin-bottom: 20px;
  color: #333;
  text-align: center;
}

.charts-row {
  display: flex;
  margin-bottom: 20px;
  gap: 20px;
}

.chart-card {
  flex: 1;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.3s;
}

.chart-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #303133;
  font-weight: bold;
}

.chart {
  height: 350px;
  width: 100%;
}

.full-width {
  width: 100%;
}

@media screen and (max-width: 1200px) {
  .charts-row {
    flex-direction: column;
  }
  
  .chart-card {
    margin-bottom: 20px;
  }
}
</style>
