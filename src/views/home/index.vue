<template>
  <div class="home-container">
    <!-- 欢迎横幅 -->
    <div class="welcome-banner">
      <div class="banner-content">
        <h1 class="system-title">欢迎使用客户销售管理系统</h1>
        <p class="system-subtitle">高效管理客户关系，提升销售业绩</p>
      </div>
      <div class="system-time">{{ currentDate }}</div>
    </div>

    <!-- 核心功能区 -->
    <div class="feature-section">
      <el-row :gutter="20">
        <el-col :span="6" v-for="(feature, index) in featureCards" :key="index">
          <div class="feature-card" @click="navigateTo(feature.route)">
            <div class="feature-icon">
              <el-icon><component :is="feature.icon" /></el-icon>
            </div>
            <div class="feature-content">
              <h3 class="feature-title">{{ feature.title }}</h3>
              <p class="feature-desc">{{ feature.description }}</p>
            </div>
          </div>
        </el-col>
      </el-row>
    </div>

    <!-- 数据概览 -->
    <div class="data-overview">
      <h2 class="section-title">数据概览</h2>
      <el-row :gutter="20">
        <el-col :span="6" v-for="(stat, index) in statistics" :key="index">
          <div class="stat-panel" v-loading="stat.loading">
            <div class="stat-header">
              <span class="stat-label">{{ stat.label }}</span>
              <el-icon><component :is="stat.icon" /></el-icon>
            </div>
            <div class="stat-value">{{ stat.value }}</div>
            <div class="stat-footer">
              <span :class="['trend', stat.trend > 0 ? 'up' : (stat.trend < 0 ? 'down' : 'flat')]">
                {{ stat.trend > 0 ? '+' : '' }}{{ stat.trend }}%
              </span>
              <span class="period">较上月</span>
            </div>
          </div>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { ElMessage } from 'element-plus';
import { 
  User, 
  Goods,
  Money,
  ShoppingCart,
  DataAnalysis,
  Setting,
  TrendCharts,
  UserFilled,
  MessageBox
} from '@element-plus/icons-vue';
import { 
  getDashboardStatistics
} from '@/api/dashboard';

const router = useRouter();
const currentDate = ref('');

// 更新时间
onMounted(() => {
  updateDateTime();
  setInterval(updateDateTime, 1000);
  
  // 获取首页数据
  fetchDashboardData();
});

const updateDateTime = () => {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  const hours = String(now.getHours()).padStart(2, '0');
  const minutes = String(now.getMinutes()).padStart(2, '0');
  const seconds = String(now.getSeconds()).padStart(2, '0');
  
  currentDate.value = `${year}年${month}月${day}日 ${hours}:${minutes}:${seconds}`;
};

// 页面导航
const navigateTo = (route) => {
  router.push(route);
};

// 功能卡片数据
const featureCards = ref([
  {
    title: '客户管理',
    description: '管理客户资料、联系历史及跟进计划',
    icon: 'User',
    route: '/data-management'
  },
  {
    title: '销售订单',
    description: '创建和管理销售订单、查看订单状态',
    icon: 'ShoppingCart',
    route: '/development-plan/management'
  },
  {
    title: '产品目录',
    description: '浏览产品目录、查看产品详情与价格',
    icon: 'Goods',
    route: '/development-plan/tracking'
  },
  {
    title: '销售分析',
    description: '查看销售数据、客户分布与业绩报表',
    icon: 'DataAnalysis',
    route: '/statistics'
  }
]);

// 统计数据
const statistics = ref([
  {
    label: '客户总数',
    value: '0',
    icon: 'User',
    trend: 0,
    loading: false
  },
  {
    label: '本月销售额',
    value: '¥0',
    icon: 'Money',
    trend: 0,
    loading: false
  },
  {
    label: '订单数量',
    value: '0',
    icon: 'ShoppingCart',
    trend: 0,
    loading: false
  },
  {
    label: '新增客户',
    value: '0',
    icon: 'UserFilled',
    trend: 0,
    loading: false
  }
]);

// 获取首页数据
const fetchDashboardData = async () => {
  try {
    // 所有面板设置为加载中
    statistics.value.forEach(stat => stat.loading = true);
    
    const res = await getDashboardStatistics();
    console.log('Dashboard API返回数据:', res);
    
    if (res && res.data) {
      // 解析响应字段，处理多种可能的数据格式
      const parseValueAndTrend = (data, fieldName, defaultValue = 0) => {
        console.log(`解析字段 ${fieldName}:`, data[fieldName]);
        try {
          const fieldData = data[fieldName];
          const trendField = `${fieldName}Trend`;
          let value = defaultValue;
          let trend = 0;
          
          if (fieldData === undefined || fieldData === null) {
            console.warn(`${fieldName} 字段不存在或为空`);
          } else if (typeof fieldData === 'object') {
            // 如果是对象，尝试获取value和trend属性
            value = fieldData.value !== undefined ? fieldData.value : 
                   fieldData.count !== undefined ? fieldData.count : defaultValue;
            trend = fieldData.trend !== undefined ? fieldData.trend : data[trendField] || 0;
          } else if (typeof fieldData === 'string') {
            // 如果是字符串，尝试解析为JSON
            try {
              const parsedValue = JSON.parse(fieldData);
              if (typeof parsedValue === 'object') {
                value = parsedValue.value !== undefined ? parsedValue.value : 
                       parsedValue.count !== undefined ? parsedValue.count : defaultValue;
                trend = parsedValue.trend !== undefined ? parsedValue.trend : data[trendField] || 0;
              } else {
                value = parsedValue || defaultValue;
                trend = data[trendField] || 0;
              }
            } catch (e) {
              // 如果不是JSON，直接使用字符串值
              console.warn(`解析${fieldName}字符串为JSON失败:`, e);
              value = isNaN(Number(fieldData)) ? defaultValue : Number(fieldData);
              trend = data[trendField] || 0;
            }
          } else {
            // 数字或其他类型，直接使用
            value = fieldData;
            trend = data[trendField] || 0;
          }
          
          return { value, trend };
        } catch (e) {
          console.error(`处理${fieldName}时出错:`, e);
          return { value: defaultValue, trend: 0 };
        }
      };
      
      // 客户总数
      try {
        const customerData = parseValueAndTrend(res.data, 'customerCount');
        statistics.value[0].value = formatNumber(customerData.value);
        statistics.value[0].trend = customerData.trend;
        console.log('处理后的客户总数:', statistics.value[0]);
      } catch (e) {
        console.error('处理客户总数数据出错:', e);
        statistics.value[0].value = '0';
        statistics.value[0].trend = 0;
      }
      
      // 本月销售额
      try {
        const salesData = parseValueAndTrend(res.data, 'monthlySales');
        statistics.value[1].value = `¥${formatNumber(salesData.value)}`;
        statistics.value[1].trend = salesData.trend;
        console.log('处理后的月销售额:', statistics.value[1]);
      } catch (e) {
        console.error('处理销售额数据出错:', e);
        statistics.value[1].value = '¥0';
        statistics.value[1].trend = 0;
      }
      
      // 订单数量
      try {
        const orderData = parseValueAndTrend(res.data, 'orderCount');
        statistics.value[2].value = formatNumber(orderData.value);
        statistics.value[2].trend = orderData.trend;
        console.log('处理后的订单数量:', statistics.value[2]);
      } catch (e) {
        console.error('处理订单数量数据出错:', e);
        statistics.value[2].value = '0';
        statistics.value[2].trend = 0;
      }
      
      // 新增客户
      try {
        const newCustomerData = parseValueAndTrend(res.data, 'newCustomerCount');
        statistics.value[3].value = formatNumber(newCustomerData.value);
        statistics.value[3].trend = newCustomerData.trend;
        console.log('处理后的新增客户:', statistics.value[3]);
      } catch (e) {
        console.error('处理新增客户数据出错:', e);
        statistics.value[3].value = '0';
        statistics.value[3].trend = 0;
      }
    }
  } catch (error) {
    console.error('获取首页数据失败:', error);
    ElMessage.error('获取首页数据失败，请刷新页面重试');
  } finally {
    // 取消所有面板的加载状态
    statistics.value.forEach(stat => stat.loading = false);
  }
};

// 格式化数字
const formatNumber = (num) => {
  if (num === undefined || num === null) return '0';
  
  // 确保num是数字
  const value = typeof num === 'string' ? parseFloat(num) : num;
  if (isNaN(value)) return '0';
  
  return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
};
</script>

<style scoped>
.home-container {
  padding: 20px;
  height: 100%;
  overflow-y: auto;
  min-height: calc(100vh - 60px);
  background-color: #f5f7fa;
}

.welcome-banner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  background: linear-gradient(to right, #1890ff, #36cbcb);
  color: white;
  border-radius: 4px;
  margin-bottom: 24px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.system-title {
  font-size: 24px;
  font-weight: bold;
  margin: 0;
}

.system-subtitle {
  font-size: 16px;
  margin: 8px 0 0;
  opacity: 0.9;
}

.system-time {
  font-size: 16px;
  font-weight: 500;
}

.feature-section {
  margin-bottom: 24px;
}

.feature-card {
  display: flex;
  align-items: center;
  padding: 20px;
  background-color: white;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  cursor: pointer;
  transition: all 0.3s;
  height: 100%;
}

.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
}

.feature-icon {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 50px;
  height: 50px;
  background-color: #ecf5ff;
  border-radius: 8px;
  margin-right: 16px;
  color: #409eff;
  font-size: 24px;
}

.feature-title {
  font-size: 18px;
  margin: 0 0 5px;
  color: #303133;
}

.feature-desc {
  margin: 0;
  color: #606266;
  font-size: 14px;
}

.section-title {
  font-size: 20px;
  font-weight: 600;
  margin-bottom: 16px;
  color: #303133;
}

.data-overview {
  margin-bottom: 24px;
}

.stat-panel {
  background-color: white;
  padding: 20px;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  min-height: 130px;
}

.stat-header {
  display: flex;
  justify-content: space-between;
  color: #606266;
  margin-bottom: 16px;
  font-size: 14px;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 8px;
}

.stat-footer {
  display: flex;
  align-items: center;
  font-size: 12px;
}

.trend {
  display: inline-block;
  padding: 2px 5px;
  border-radius: 4px;
  margin-right: 5px;
}

.up {
  color: #67c23a;
  background-color: rgba(103, 194, 58, 0.1);
}

.down {
  color: #f56c6c;
  background-color: rgba(245, 108, 108, 0.1);
}

.flat {
  color: #909399;
  background-color: rgba(144, 147, 153, 0.1);
}

.period {
  color: #909399;
}
</style> 