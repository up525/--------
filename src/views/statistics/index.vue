<template>
  <div class="statistics-container">
    <h2 class="page-title">图表统计</h2>
    
    <div class="statistics-summary">
      <el-row :gutter="15">
        <el-col :span="6" v-for="(item, index) in summaryItems" :key="index">
          <div class="summary-card" :class="`summary-card-${index}`">
            <div class="summary-icon">
              <el-icon><component :is="item.icon" /></el-icon>
            </div>
            <div class="summary-content">
              <div class="summary-title">{{ item.title }}</div>
              <div class="summary-value">{{ item.value }}</div>
            </div>
          </div>
        </el-col>
      </el-row>
    </div>
    
    <el-card class="statistics-card">
      <el-tabs v-model="activeTab" type="border-card" class="full-height-tabs">
        <el-tab-pane label="客户统计" name="clients">
          <div class="chart-container">
            <div class="chart-header">
              <h3>客户增长趋势</h3>
              <div class="chart-actions">
                <el-radio-group v-model="clientsTimeRange" size="small">
                  <el-radio-button label="week">本周</el-radio-button>
                  <el-radio-button label="month">本月</el-radio-button>
                  <el-radio-button label="year">全年</el-radio-button>
                </el-radio-group>
              </div>
            </div>
            <div class="chart-placeholder">
              <el-empty description="此处将显示客户统计图表">
                <el-button type="primary">模拟生成数据</el-button>
              </el-empty>
            </div>
          </div>
        </el-tab-pane>
        
        <el-tab-pane label="计划进度" name="plans">
          <div class="chart-container">
            <div class="chart-header">
              <h3>计划完成情况</h3>
              <div class="chart-actions">
                <el-select v-model="selectedProject" placeholder="选择项目" size="small">
                  <el-option label="全部项目" value="" />
                  <el-option label="客户管理系统开发" value="project1" />
                  <el-option label="电子商务平台升级" value="project2" />
                  <el-option label="搜索引擎优化" value="project3" />
                </el-select>
              </div>
            </div>
            <div class="chart-placeholder">
              <el-empty description="此处将显示计划进度图表">
                <el-button type="primary">模拟生成数据</el-button>
              </el-empty>
            </div>
          </div>
        </el-tab-pane>
        
        <el-tab-pane label="收入分析" name="revenue">
          <div class="chart-container">
            <div class="chart-header">
              <h3>收入分布分析</h3>
              <div class="chart-actions">
                <el-date-picker
                  v-model="dateRange"
                  type="daterange"
                  range-separator="至"
                  start-placeholder="开始日期"
                  end-placeholder="结束日期"
                  size="small"
                />
              </div>
            </div>
            <div class="chart-placeholder">
              <el-empty description="此处将显示收入分析图表">
                <el-button type="primary">模拟生成数据</el-button>
              </el-empty>
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { 
  User, 
  Bicycle, 
  ChatLineRound, 
  Money 
} from '@element-plus/icons-vue';

const activeTab = ref('clients');
const clientsTimeRange = ref('month');
const selectedProject = ref('');
const dateRange = ref([]);

// 统计概要数据
const summaryItems = ref([
  {
    title: '总客户数',
    value: '128',
    icon: 'User'
  },
  {
    title: '进行中项目',
    value: '12',
    icon: 'Bicycle'
  },
  {
    title: '本月新增客户',
    value: '28',
    icon: 'ChatLineRound'
  },
  {
    title: '总收入',
    value: '￥1,589,340',
    icon: 'Money'
  }
]);
</script>

<style scoped>
.statistics-container {
  padding: 10px 15px;
  height: 100%;
  display: flex;
  flex-direction: column;
  width: 100%;
  box-sizing: border-box;
}

.page-title {
  margin-top: 0;
  margin-bottom: 15px;
  color: #1976d2;
}

.statistics-summary {
  margin-bottom: 15px;
  width: 100%;
}

.summary-card {
  height: 100px;
  border-radius: 8px;
  padding: 15px;
  display: flex;
  align-items: center;
  color: white;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transition: all 0.3s;
}

.summary-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.15);
}

.summary-card-0 {
  background: linear-gradient(135deg, #42b983 0%, #33a06f 100%);
}

.summary-card-1 {
  background: linear-gradient(135deg, #5c6bc0 0%, #3949ab 100%);
}

.summary-card-2 {
  background: linear-gradient(135deg, #26c6da 0%, #00acc1 100%);
}

.summary-card-3 {
  background: linear-gradient(135deg, #ec407a 0%, #d81b60 100%);
}

.summary-icon {
  font-size: 40px;
  margin-right: 15px;
}

.summary-content {
  display: flex;
  flex-direction: column;
}

.summary-title {
  font-size: 14px;
  opacity: 0.9;
}

.summary-value {
  font-size: 26px;
  font-weight: bold;
  margin-top: 5px;
}

.statistics-card {
  flex: 1;
  margin-bottom: 15px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  border-radius: 8px;
  width: 100%;
}

.full-height-tabs {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.full-height-tabs :deep(.el-tabs__content) {
  flex: 1;
  overflow: auto;
}

.full-height-tabs :deep(.el-tab-pane) {
  height: 100%;
}

.chart-container {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
  padding: 0 5px;
}

.chart-header h3 {
  margin: 0;
  color: #1976d2;
}

.chart-placeholder {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  border: 1px dashed #ccc;
  border-radius: 4px;
  padding: 15px;
  min-height: 400px;
}

.el-row {
  width: 100%;
  margin-left: 0 !important;
  margin-right: 0 !important;
}
</style> 