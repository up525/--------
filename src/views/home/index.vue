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
          <div class="stat-panel">
            <div class="stat-header">
              <span class="stat-label">{{ stat.label }}</span>
              <el-icon><component :is="stat.icon" /></el-icon>
            </div>
            <div class="stat-value">{{ stat.value }}</div>
            <div class="stat-footer">
              <span :class="['trend', stat.trend > 0 ? 'up' : 'down']">
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

const router = useRouter();
const currentDate = ref('');

// 更新时间
onMounted(() => {
  updateDateTime();
  setInterval(updateDateTime, 1000);
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
    value: '1,286',
    icon: 'User',
    trend: 15
  },
  {
    label: '本月销售额',
    value: '¥268,546',
    icon: 'Money',
    trend: 23
  },
  {
    label: '订单数量',
    value: '356',
    icon: 'ShoppingCart',
    trend: -5
  },
  {
    label: '新增客户',
    value: '86',
    icon: 'UserFilled',
    trend: 12
  }
]);
</script>

<style scoped>
.home-container {
  padding: 20px;
  min-height: 100%;
  width: 100%;
  max-width: 100%;
  overflow-x: hidden;
  background-color: #f5f7fa;
}

/* 欢迎横幅 */
.welcome-banner {
  background: linear-gradient(135deg, #1890ff, #0050b3);
  border-radius: 8px;
  padding: 30px;
  color: white;
  margin-bottom: 30px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 4px 12px rgba(24, 144, 255, 0.2);
}

.system-title {
  font-size: 28px;
  margin: 0 0 8px 0;
  font-weight: 600;
}

.system-subtitle {
  font-size: 16px;
  margin: 0;
  opacity: 0.9;
}

.system-time {
  font-size: 16px;
  padding: 10px 16px;
  background-color: rgba(255, 255, 255, 0.2);
  border-radius: 4px;
}

/* 功能卡片 */
.feature-section {
  margin-bottom: 30px;
  width: 100%;
}

.feature-card {
  background-color: white;
  border-radius: 8px;
  padding: 24px;
  height: 180px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
  display: flex;
  flex-direction: column;
  cursor: pointer;
  position: relative;
  overflow: hidden;
}

.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.feature-card:before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 6px;
  height: 100%;
  background: #1890ff;
}

.feature-icon {
  color: #1890ff;
  font-size: 32px;
  margin-bottom: 20px;
}

.feature-title {
  font-size: 18px;
  font-weight: 600;
  margin: 0 0 10px 0;
  color: #333;
}

.feature-desc {
  font-size: 14px;
  color: #666;
  line-height: 1.5;
  margin: 0;
}

/* 数据概览 */
.data-overview {
  width: 100%;
}

.section-title {
  font-size: 18px;
  font-weight: 600;
  margin: 0 0 20px 0;
  color: #333;
  padding-left: 10px;
  border-left: 4px solid #1890ff;
}

.stat-panel {
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.stat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.stat-label {
  font-size: 14px;
  color: #666;
}

.stat-header .el-icon {
  color: #1890ff;
  font-size: 18px;
}

.stat-value {
  font-size: 24px;
  font-weight: 600;
  color: #333;
  margin-bottom: 15px;
}

.stat-footer {
  display: flex;
  align-items: center;
  font-size: 12px;
}

.trend {
  margin-right: 5px;
  font-weight: 500;
}

.trend.up {
  color: #52c41a;
}

.trend.down {
  color: #f5222d;
}

.period {
  color: #999;
}

@media screen and (max-width: 1200px) {
  .home-container {
    min-width: 1020px;
  }
}
</style> 