<template>
  <div class="plan-tracking-container">
    <el-card class="tracking-card">
      <div class="tracking-filter">
        <el-form :inline="true" :model="filterForm" class="filter-form">
          <el-form-item label="计划标题">
            <el-input v-model="filterForm.title" placeholder="请输入计划标题" />
          </el-form-item>
          <el-form-item label="客户">
            <el-select v-model="filterForm.client" placeholder="请选择客户">
              <el-option label="全部" value="" />
              <el-option label="阿里巴巴科技有限公司" value="阿里巴巴科技有限公司" />
              <el-option label="腾讯科技有限公司" value="腾讯科技有限公司" />
              <el-option label="百度在线网络技术有限公司" value="百度在线网络技术有限公司" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary">查询</el-button>
            <el-button type="success">重置</el-button>
          </el-form-item>
        </el-form>
      </div>
      
      <div class="tracking-progress">
        <el-row :gutter="20">
          <el-col :span="8" v-for="item in trackingData" :key="item.id">
            <el-card class="progress-card">
              <template #header>
                <div class="progress-header">
                  <span>{{ item.title }}</span>
                  <el-tag :type="getStatusType(item.status)">{{ item.status }}</el-tag>
                </div>
              </template>
              <div class="progress-info">
                <p><strong>客户：</strong>{{ item.client }}</p>
                <p><strong>时间：</strong>{{ item.startDate }} 至 {{ item.endDate }}</p>
                <p><strong>进度：</strong></p>
                <el-progress :percentage="item.progress" :status="getProgressStatus(item.progress)" />
                <div class="progress-actions">
                  <el-button type="primary" size="small">更新进度</el-button>
                  <el-button type="info" size="small">查看详情</el-button>
                </div>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref } from 'vue';

// 过滤表单
const filterForm = ref({
  title: '',
  client: ''
});

// 模拟数据
const trackingData = ref([
  {
    id: 1,
    title: '客户管理系统开发',
    client: '阿里巴巴科技有限公司',
    startDate: '2023-04-01',
    endDate: '2023-06-30',
    status: '进行中',
    progress: 45
  },
  {
    id: 2,
    title: '电子商务平台升级',
    client: '腾讯科技有限公司',
    startDate: '2023-05-15',
    endDate: '2023-08-15',
    status: '规划中',
    progress: 15
  },
  {
    id: 3,
    title: '搜索引擎优化',
    client: '百度在线网络技术有限公司',
    startDate: '2023-03-10',
    endDate: '2023-05-10',
    status: '已完成',
    progress: 100
  }
]);

// 根据状态返回标签类型
const getStatusType = (status) => {
  switch (status) {
    case '规划中':
      return 'info';
    case '进行中':
      return 'primary';
    case '已完成':
      return 'success';
    default:
      return '';
  }
};

// 根据进度返回进度条状态
const getProgressStatus = (progress) => {
  if (progress >= 100) {
    return 'success';
  } else if (progress >= 80) {
    return 'warning';
  } else {
    return '';
  }
};
</script>

<style scoped>
.plan-tracking-container {
  padding: 20px;
}

.tracking-card {
  margin-top: 20px;
}

.tracking-filter {
  margin-bottom: 20px;
}

.tracking-progress {
  margin-top: 20px;
}

.progress-card {
  margin-bottom: 20px;
}

.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.progress-info {
  padding: 10px 0;
}

.progress-actions {
  margin-top: 15px;
  display: flex;
  justify-content: space-between;
}
</style> 