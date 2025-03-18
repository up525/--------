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
          :data="tableData" 
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
            <template #default="scope">
              <div class="action-buttons">
                <el-button size="small" type="primary" @click="handleEdit(scope.row)">编辑</el-button>
                <el-button size="small" type="success">跟踪</el-button>
                <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
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
            :total="total"
            background
          >
            <template #total>
              共 <strong>{{ total }}</strong> 条数据
            </template>
            <template #prev-text>上一页</template>
            <template #next-text>下一页</template>
            <template #sizes="{ size }">
              {{ size }}条/页
            </template>
            <template #jumper>
              前往<el-input v-model="currentPage" :min="1" :max="Math.ceil(total / pageSize)" />页
            </template>
          </el-pagination>
        </div>
      </div>
    </el-card>

    <!-- 新增/编辑计划对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑开发计划' : '新增开发计划'"
      width="50%"
      :close-on-click-modal="false"
    >
      <el-form :model="formData" :rules="formRules" ref="formRef" label-width="100px">
        <el-form-item label="计划标题" prop="title">
          <el-input v-model="formData.title" placeholder="请输入计划标题" />
        </el-form-item>
        <el-form-item label="客户" prop="clientId">
          <el-select v-model="formData.clientId" placeholder="请选择客户" filterable>
            <el-option 
              v-for="item in clientOptions" 
              :key="item.id" 
              :label="item.name" 
              :value="item.id" 
            />
          </el-select>
        </el-form-item>
        <el-form-item label="开始日期" prop="startDate">
          <el-date-picker
            v-model="formData.startDate"
            type="date"
            placeholder="请选择开始日期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item label="结束日期" prop="endDate">
          <el-date-picker
            v-model="formData.endDate"
            type="date"
            placeholder="请选择结束日期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="formData.status" placeholder="请选择状态">
            <el-option label="规划中" value="规划中" />
            <el-option label="进行中" value="进行中" />
            <el-option label="已完成" value="已完成" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input
            v-model="formData.remark"
            type="textarea"
            :rows="3"
            placeholder="请输入备注信息"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitForm">确定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 删除确认对话框 -->
    <el-dialog
      v-model="deleteDialogVisible"
      title="删除确认"
      width="30%"
    >
      <div>确定要删除【{{ deleteForm.title }}】计划吗？此操作不可恢复！</div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="deleteDialogVisible = false">取消</el-button>
          <el-button type="danger" @click="confirmDelete">确定删除</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { getPlanList, getPlanById, addPlan, updatePlan, deletePlan } from '@/api/plan';

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
const total = ref(0);
const tableData = ref([]);

// 客户选项
const clientOptions = ref([
  { id: 1, name: '阿里巴巴科技有限公司' },
  { id: 2, name: '腾讯科技有限公司' },
  { id: 3, name: '百度在线网络技术有限公司' },
  { id: 4, name: '京东集团' },
  { id: 5, name: '小米科技有限公司' },
  { id: 6, name: '华为技术有限公司' },
  { id: 7, name: '网易有道公司' },
  { id: 8, name: '字节跳动有限公司' },
  { id: 9, name: '拼多多电子商务' },
  { id: 10, name: '美团网络有限公司' }
]);

// 对话框相关
const dialogVisible = ref(false);
const isEdit = ref(false);
const formRef = ref(null);
const formData = ref({
  id: '',
  title: '',
  clientId: '',
  startDate: '',
  endDate: '',
  status: '规划中',
  remark: ''
});

// 表单验证规则
const formRules = {
  title: [
    { required: true, message: '请输入计划标题', trigger: 'blur' },
    { min: 2, max: 50, message: '长度在2到50个字符之间', trigger: 'blur' }
  ],
  clientId: [
    { required: true, message: '请选择客户', trigger: 'change' }
  ],
  startDate: [
    { required: true, message: '请选择开始日期', trigger: 'change' }
  ],
  endDate: [
    { required: true, message: '请选择结束日期', trigger: 'change' }
  ],
  status: [
    { required: true, message: '请选择状态', trigger: 'change' }
  ]
};

// 删除相关
const deleteDialogVisible = ref(false);
const deleteForm = ref({
  id: '',
  title: ''
});

// 获取状态对应的类型
const getStatusType = (status) => {
  switch (status) {
    case '规划中':
      return 'info';
    case '进行中':
      return 'primary';
    case '已完成':
      return 'success';
    default:
      return 'info';
  }
};

// 获取开发计划列表
const fetchPlanList = async () => {
  loading.value = true;
  try {
    const params = {
      page: currentPage.value,
      pageSize: pageSize.value
    };
    
    // 添加搜索条件
    if (searchForm.value.title) {
      params.title = searchForm.value.title;
    }
    if (searchForm.value.client) {
      params.client = searchForm.value.client;
    }
    if (searchForm.value.status) {
      params.status = searchForm.value.status;
    }
    if (searchForm.value.dateRange && searchForm.value.dateRange.length === 2) {
      params.startDate = searchForm.value.dateRange[0];
      params.endDate = searchForm.value.dateRange[1];
    }
    
    const res = await getPlanList(params);
    tableData.value = res.data.rows;
    total.value = res.data.total;
  } catch (error) {
    console.error('获取开发计划列表出错:', error);
    ElMessage.error('获取开发计划列表失败，请稍后重试');
  } finally {
    loading.value = false;
  }
};

// 查询操作
const handleSearch = () => {
  currentPage.value = 1; // 查询后跳转到第一页
  fetchPlanList();
};

// 处理新增计划
const handleAddPlan = () => {
  isEdit.value = false;
  formData.value = {
    id: '',
    title: '',
    clientId: '',
    startDate: '',
    endDate: '',
    status: '规划中',
    remark: ''
  };
  dialogVisible.value = true;
};

// 处理编辑计划
const handleEdit = async (row) => {
  isEdit.value = true;
  loading.value = true;
  try {
    const res = await getPlanById(row.id);
    formData.value = {
      id: res.data.id,
      title: res.data.title,
      clientId: res.data.clientId,
      startDate: res.data.startDate,
      endDate: res.data.endDate,
      status: res.data.status,
      remark: res.data.remark || ''
    };
    dialogVisible.value = true;
  } catch (error) {
    console.error('获取计划详情出错:', error);
    ElMessage.error('获取计划详情失败，请稍后重试');
  } finally {
    loading.value = false;
  }
};

// 提交表单
const submitForm = () => {
  if (formRef.value) {
    formRef.value.validate(async (valid) => {
      if (valid) {
        loading.value = true;
        try {
          if (isEdit.value) {
            // 更新计划
            await updatePlan(formData.value);
            ElMessage.success('更新计划成功');
          } else {
            // 添加计划
            await addPlan(formData.value);
            ElMessage.success('添加计划成功');
          }
          dialogVisible.value = false;
          fetchPlanList(); // 重新加载列表
        } catch (error) {
          console.error(isEdit.value ? '更新计划出错:' : '添加计划出错:', error);
          ElMessage.error(isEdit.value ? '更新计划失败，请稍后重试' : '添加计划失败，请稍后重试');
        } finally {
          loading.value = false;
        }
      } else {
        ElMessage.warning('请完善表单信息');
        return false;
      }
    });
  }
};

// 处理删除计划
const handleDelete = (row) => {
  deleteForm.value = {
    id: row.id,
    title: row.title
  };
  deleteDialogVisible.value = true;
};

// 确认删除
const confirmDelete = async () => {
  loading.value = true;
  try {
    await deletePlan(deleteForm.value.id);
    ElMessage.success('删除计划成功');
    deleteDialogVisible.value = false;
    
    // 如果当前页只有一条数据且不是第一页，则删除后跳转到上一页
    if (tableData.value.length === 1 && currentPage.value > 1) {
      currentPage.value--;
    }
    
    fetchPlanList(); // 重新加载列表
  } catch (error) {
    console.error('删除计划出错:', error);
    ElMessage.error('删除计划失败，请稍后重试');
  } finally {
    loading.value = false;
    deleteDialogVisible.value = false;
  }
};

// 初始化
onMounted(() => {
  fetchPlanList();
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
  gap: 12px;
  flex: 1;
}

.form-item {
  width: 200px;
}

.date-range-item {
  width: 320px;
}

.search-btn-wrapper {
  display: flex;
  align-items: center;
  margin-left: 8px;
}

.search-btn {
  margin-left: 8px;
}

.action-btn-wrapper {
  margin-left: 20px;
}

/* 表格内容区域样式 */
.table-content {
  padding: 16px;
}

.action-buttons {
  display: flex;
  justify-content: center;
  gap: 8px;
}

/* 分页容器样式 */
.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

/* 对话框样式 */
.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style> 