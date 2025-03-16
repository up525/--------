<template>
  <div class="plan-management-container">    
    <!-- 搜索区域和按钮区域整合 -->
    <el-card class="search-area-card">
      <!-- 搜索表单 -->
      <div class="search-form-wrapper">
        <div class="search-header">
          <div class="form-items">
            <div class="form-item">
              <el-input v-model="searchForm.title" placeholder="请输入计划标题" clearable />
            </div>
            <div class="form-item">
              <el-input v-model="searchForm.client" placeholder="请输入客户名称" clearable />
            </div>
            <div class="form-item">
              <el-select v-model="searchForm.status" placeholder="请选择状态" clearable>
                <el-option label="规划中" value="规划中" />
                <el-option label="进行中" value="进行中" />
                <el-option label="已完成" value="已完成" />
              </el-select>
            </div>
            <div class="form-item date-range-item">
              <el-date-picker
                v-model="searchForm.dateRange"
                type="daterange"
                range-separator="至"
                start-placeholder="开始日期"
                end-placeholder="结束日期"
                format="YYYY-MM-DD"
                value-format="YYYY-MM-DD"
              />
            </div>
            <div class="search-btn-wrapper">
              <el-button class="search-btn" type="primary" @click="handleSearch">查询</el-button>
            </div>
          </div>
          <div class="action-btn-wrapper">
            <el-button type="primary" @click="handleAddPlan">新增计划</el-button>
          </div>
        </div>
      </div>
      
      <!-- 表格内容区域 -->
      <div class="table-content">
        <el-table 
          :data="paginatedData" 
          style="width: 100%" 
          v-loading="loading"
          border
          :header-cell-style="{ background: '#f5f7fa', color: '#606266', fontWeight: '500', textAlign: 'center' }"
          :cell-style="{ textAlign: 'center' }"
        >
          <el-table-column prop="id" label="ID" width="70" align="center" />
          <el-table-column prop="title" label="计划标题" min-width="150" align="center" />
          <el-table-column prop="client" label="客户" min-width="150" align="center" />
          <el-table-column prop="startDate" label="开始日期" width="120" align="center" />
          <el-table-column prop="endDate" label="结束日期" width="120" align="center" />
          <el-table-column prop="status" label="状态" width="100" align="center">
            <template #default="scope">
              <el-tag :type="getStatusType(scope.row.status)" size="small">{{ scope.row.status }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="210" align="center" fixed="right">
            <template #default>
              <div class="action-buttons">
                <el-button size="small" type="primary">编辑</el-button>
                <el-button size="small" type="success">跟踪</el-button>
                <el-button size="small" type="danger">删除</el-button>
              </div>
            </template>
          </el-table-column>
        </el-table>
        
        <!-- 分页控件 -->
        <div class="pagination-container">
          <el-pagination
            v-model:current-page="currentPage"
            v-model:page-size="pageSize"
            :page-sizes="[10, 20, 30, 50]"
            layout="total, sizes, prev, pager, next, jumper"
            :total="filteredData.length"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
            background
          >
            <template #total>
              共 <strong>{{ filteredData.length }}</strong> 条数据
            </template>
            <template #prev-text>上一页</template>
            <template #next-text>下一页</template>
            <template #sizes="{ size }">
              {{ size }}条/页
            </template>
            <template #jumper>
              前往<el-input v-model="currentPage" :min="1" :max="Math.ceil(filteredData.length / pageSize)" />页
            </template>
          </el-pagination>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';

// 搜索表单
const searchForm = ref({
  title: '',
  client: '',
  status: '',
  dateRange: []
});

// 分页相关
const currentPage = ref(1);
const pageSize = ref(10);
const loading = ref(false);

// 模拟数据 - 扩展为更多数据以展示分页效果
const allData = ref([
  {
    id: 1,
    title: '客户管理系统开发',
    client: '阿里巴巴科技有限公司',
    startDate: '2023-04-01',
    endDate: '2023-06-30',
    status: '进行中'
  },
  {
    id: 2,
    title: '电子商务平台升级',
    client: '腾讯科技有限公司',
    startDate: '2023-05-15',
    endDate: '2023-08-15',
    status: '规划中'
  },
  {
    id: 3,
    title: '搜索引擎优化',
    client: '百度在线网络技术有限公司',
    startDate: '2023-03-10',
    endDate: '2023-05-10',
    status: '已完成'
  },
  {
    id: 4,
    title: '移动应用开发',
    client: '京东集团',
    startDate: '2023-06-01',
    endDate: '2023-08-30',
    status: '规划中'
  },
  {
    id: 5,
    title: '智能家居控制系统',
    client: '小米科技有限公司',
    startDate: '2023-04-15',
    endDate: '2023-07-15',
    status: '进行中'
  },
  {
    id: 6,
    title: '5G网络优化',
    client: '华为技术有限公司',
    startDate: '2023-03-01',
    endDate: '2023-09-01',
    status: '进行中'
  },
  {
    id: 7,
    title: '在线教育平台',
    client: '网易有道公司',
    startDate: '2023-05-01',
    endDate: '2023-07-30',
    status: '进行中'
  },
  {
    id: 8,
    title: '短视频推荐算法',
    client: '字节跳动有限公司',
    startDate: '2023-02-15',
    endDate: '2023-05-15',
    status: '已完成'
  },
  {
    id: 9,
    title: '社区团购平台',
    client: '拼多多电子商务',
    startDate: '2023-04-10',
    endDate: '2023-06-10',
    status: '进行中'
  },
  {
    id: 10,
    title: '外卖配送系统升级',
    client: '美团网络有限公司',
    startDate: '2023-03-20',
    endDate: '2023-05-20',
    status: '已完成'
  },
  {
    id: 11,
    title: '网约车平台优化',
    client: '滴滴出行科技有限公司',
    startDate: '2023-06-15',
    endDate: '2023-09-15',
    status: '规划中'
  },
  {
    id: 12,
    title: '金融风控系统',
    client: '陆金所金融科技',
    startDate: '2023-05-10',
    endDate: '2023-11-10',
    status: '进行中'
  },
  {
    id: 13,
    title: '汽车销售管理系统',
    client: '上海汽车集团',
    startDate: '2023-07-01',
    endDate: '2023-10-01',
    status: '规划中'
  },
  {
    id: 14,
    title: '能源管理平台',
    client: '中国石油天然气集团',
    startDate: '2023-04-20',
    endDate: '2023-08-20',
    status: '进行中'
  },
  {
    id: 15,
    title: '医疗管理系统',
    client: '协和医院',
    startDate: '2023-03-15',
    endDate: '2023-06-15',
    status: '已完成'
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

// 根据搜索条件筛选数据
const filteredData = computed(() => {
  const { title, client, status, dateRange } = searchForm.value;
  return allData.value.filter(item => {
    // 标题和客户名称筛选
    const titleMatch = !title || item.title.includes(title);
    const clientMatch = !client || item.client.includes(client);
    const statusMatch = !status || item.status === status;
    
    // 日期范围筛选
    let dateMatch = true;
    if (dateRange && dateRange.length === 2) {
      const startDate = dateRange[0];
      const endDate = dateRange[1];
      
      // 判断项目的日期是否在选择的范围内
      // 项目开始日期在选择的开始日期之后，并且项目结束日期在选择的结束日期之前
      dateMatch = item.startDate >= startDate && item.endDate <= endDate;
    }
    
    return titleMatch && clientMatch && statusMatch && dateMatch;
  });
});

// 当前页数据
const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  return filteredData.value.slice(start, end);
});

// 查询操作
const handleSearch = () => {
  loading.value = true;
  setTimeout(() => {
    currentPage.value = 1; // 查询后跳转到第一页
    loading.value = false;
  }, 300);
};

// 新增计划
const handleAddPlan = () => {
  // 实现新增计划的逻辑
  console.log('新增计划');
};

// 分页大小变化
const handleSizeChange = (size) => {
  pageSize.value = size;
};

// 页码变化
const handleCurrentChange = (page) => {
  currentPage.value = page;
};

// 初始化
onMounted(() => {
  // 模拟加载数据
  loading.value = true;
  setTimeout(() => {
    loading.value = false;
  }, 500);
});
</script>

<style scoped>
.plan-management-container {
  padding: 20px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 60px);
}

.search-area-card {
  margin-bottom: 0;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
  border-radius: 4px;
  padding: 0;
}

/* 搜索表单样式 */
.search-form-wrapper {
  padding: 16px 16px 12px;
  border-bottom: 1px solid #ebeef5;
}

.search-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.form-items {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  flex: 1;
  align-items: flex-end;
}

.form-item {
  display: flex;
  flex-direction: column;
  min-width: 180px;
  flex: 1;
}

.date-range-item {
  min-width: 300px;
}

.form-item label {
  font-size: 14px;
  color: #606266;
  margin-bottom: 6px;
}

.search-btn-wrapper {
  display: flex;
  align-items: flex-end;
  margin-left: 8px;
}

.action-btn-wrapper {
  margin-left: 16px;
  display: flex;
  align-items: flex-end;
}

.search-btn {
  background-color: #409EFF;
  border-color: #409EFF;
  border-radius: 4px;
  height: 32px;
}

/* 表格区域 */
.table-content {
  padding: 16px;
}

.action-buttons {
  display: flex;
  justify-content: center;
  gap: 8px;
}

.pagination-container {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}

/* 优化表单元素样式 */
:deep(.el-card__body) {
  padding: 0;
}

:deep(.el-input__wrapper),
:deep(.el-select),
:deep(.el-date-editor.el-input) {
  width: 100%;
}

:deep(.el-table) {
  border: 1px solid #ebeef5;
}

:deep(.el-table th) {
  height: 45px;
}

:deep(.el-table--border th) {
  border-right: 1px solid #ebeef5;
}

:deep(.el-table--border td) {
  border-right: 1px solid #ebeef5;
}

:deep(.el-pagination) {
  font-weight: normal;
}

/* 自定义样式微调 */
:deep(.el-button+.el-button) {
  margin-left: 4px;
}

:deep(.el-input__inner) {
  font-size: 14px;
}

:deep(.el-table .cell) {
  padding: 0 8px;
}

:deep(.el-table--striped .el-table__body tr.el-table__row--striped td) {
  background-color: #fafafa;
}
</style> 