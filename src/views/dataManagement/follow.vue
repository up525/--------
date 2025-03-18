<template>
  <div class="follow-management-container">
    <!-- 搜索区域 -->
    <el-card class="search-card">
      <el-form :model="searchForm" :inline="true" class="search-form">
        <el-form-item label="客户名称">
          <el-input v-model="searchForm.customerName" placeholder="请输入客户名称" clearable />
        </el-form-item>
        <el-form-item label="跟进类型">
          <el-select v-model="searchForm.followType" placeholder="请选择跟进类型" clearable>
            <el-option label="电话" value="电话" />
            <el-option label="邮件" value="邮件" />
            <el-option label="拜访" value="拜访" />
            <el-option label="会议" value="会议" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="跟进日期">
          <el-date-picker
            v-model="searchForm.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
    
    <el-card class="data-card">
      <!-- 添加新增按钮 -->
      <div class="operation-container">
        <el-button type="primary" @click="handleAdd">新增跟进记录</el-button>
      </div>
      
      <div class="data-table">
        <el-table 
          :data="tableData" 
          style="width: 100%" 
          v-loading="loading"
          border
          stripe
          highlight-current-row
          :header-cell-style="{backgroundColor: '#f5f7fa', color: '#606266', fontWeight: 'bold'}"
        >
          <el-table-column prop="id" label="ID" width="70" align="center" />
          <el-table-column prop="customerName" label="客户名称" min-width="150" show-overflow-tooltip />
          <el-table-column prop="userName" label="跟进人员" width="100" align="center" />
          <el-table-column prop="followType" label="跟进方式" width="100" align="center" />
          <el-table-column label="跟进时间" width="160" align="center">
            <template #default="scope">
              {{ formatDate(scope.row.followTime) }}
            </template>
          </el-table-column>
          <el-table-column prop="content" label="跟进内容" min-width="200" show-overflow-tooltip />
          <el-table-column prop="nextPlan" label="下次计划" min-width="150" show-overflow-tooltip />
          <el-table-column label="下次时间" width="160" align="center">
            <template #default="scope">
              {{ formatDate(scope.row.nextTime) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="150" fixed="right">
            <template #default="scope">
              <el-button size="small" type="primary" @click="handleEdit(scope.row)">编辑</el-button>
              <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
        
        <!-- 分页控件 -->
        <div class="pagination-container">
          <el-pagination
            v-model:current-page="currentPage"
            v-model:page-size="pageSize"
            :page-sizes="[10, 20, 50, 100]"
            layout="total, sizes, prev, pager, next, jumper"
            :total="total"
            background
          />
        </div>
      </div>
    </el-card>

    <!-- 编辑对话框 -->
    <el-dialog
      v-model="editDialogVisible"
      title="编辑跟进记录"
      width="50%"
      :close-on-click-modal="false"
    >
      <el-form :model="editForm" label-width="100px" :rules="formRules" ref="editFormRef">
        <el-form-item label="客户名称" prop="customerName">
          <el-input v-model="editForm.customerName" placeholder="请输入客户名称" disabled />
        </el-form-item>
        <el-form-item label="跟进方式" prop="followType">
          <el-select v-model="editForm.followType" placeholder="请选择跟进方式" style="width: 100%">
            <el-option label="电话" value="电话" />
            <el-option label="邮件" value="邮件" />
            <el-option label="拜访" value="拜访" />
            <el-option label="会议" value="会议" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="跟进时间" prop="followTime">
          <el-date-picker
            v-model="editForm.followTime"
            type="datetime"
            placeholder="选择日期时间"
            format="YYYY-MM-DD HH:mm:ss"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="跟进内容" prop="content">
          <el-input v-model="editForm.content" type="textarea" rows="4" placeholder="请输入跟进内容" />
        </el-form-item>
        <el-form-item label="下次计划" prop="nextPlan">
          <el-input v-model="editForm.nextPlan" type="textarea" rows="2" placeholder="请输入下次计划" />
        </el-form-item>
        <el-form-item label="下次时间" prop="nextTime">
          <el-date-picker
            v-model="editForm.nextTime"
            type="datetime"
            placeholder="选择日期时间"
            format="YYYY-MM-DD HH:mm:ss"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 100%"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="cancelEdit">取消</el-button>
          <el-button type="primary" @click="confirmEdit">修改</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 新增对话框 -->
    <el-dialog
      v-model="addDialogVisible"
      title="新增跟进记录"
      width="50%"
      :close-on-click-modal="false"
    >
      <el-form :model="addForm" label-width="100px" :rules="formRules" ref="addFormRef">
        <el-form-item label="客户" prop="customerId">
          <el-select v-model="addForm.customerId" placeholder="请选择客户" style="width: 100%">
            <el-option 
              v-for="item in customerOptions" 
              :key="item.id" 
              :label="item.name" 
              :value="item.id" 
            />
          </el-select>
        </el-form-item>
        <el-form-item label="跟进方式" prop="followType">
          <el-select v-model="addForm.followType" placeholder="请选择跟进方式" style="width: 100%">
            <el-option label="电话" value="电话" />
            <el-option label="邮件" value="邮件" />
            <el-option label="拜访" value="拜访" />
            <el-option label="会议" value="会议" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="跟进时间" prop="followTime">
          <el-date-picker
            v-model="addForm.followTime"
            type="datetime"
            placeholder="选择日期时间"
            format="YYYY-MM-DD HH:mm:ss"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="跟进内容" prop="content">
          <el-input v-model="addForm.content" type="textarea" rows="4" placeholder="请输入跟进内容" />
        </el-form-item>
        <el-form-item label="下次计划" prop="nextPlan">
          <el-input v-model="addForm.nextPlan" type="textarea" rows="2" placeholder="请输入下次计划" />
        </el-form-item>
        <el-form-item label="下次时间" prop="nextTime">
          <el-date-picker
            v-model="addForm.nextTime"
            type="datetime"
            placeholder="选择日期时间"
            format="YYYY-MM-DD HH:mm:ss"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 100%"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="cancelAdd">取消</el-button>
          <el-button type="primary" @click="confirmAdd">确定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 删除确认对话框 -->
    <el-dialog
      v-model="deleteDialogVisible"
      title="删除确认"
      width="30%"
    >
      <div>确定要删除该跟进记录吗？此操作不可恢复！</div>
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
import { ref, computed, onMounted, watch } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { 
  getFollowList, 
  getFollowById, 
  addFollow, 
  updateFollow, 
  deleteFollow 
} from '@/api/follow';
import { getCustomerList } from '@/api/customer';

// 搜索表单
const searchForm = ref({
  customerName: '',
  followType: '',
  dateRange: []
});

// 分页相关
const currentPage = ref(1);
const pageSize = ref(10);
const loading = ref(false);
const total = ref(0);
const tableData = ref([]);

// 客户选项
const customerOptions = ref([]);

// 编辑相关
const editDialogVisible = ref(false);
const editFormRef = ref(null);
const editForm = ref({
  id: '',
  customerName: '',
  followType: '',
  followTime: '',
  content: '',
  nextPlan: '',
  nextTime: ''
});

// 新增相关
const addDialogVisible = ref(false);
const addFormRef = ref(null);
const addForm = ref({
  customerId: '',
  followType: '',
  followTime: '',
  content: '',
  nextPlan: '',
  nextTime: ''
});

// 删除相关
const deleteDialogVisible = ref(false);
const deleteForm = ref({
  id: ''
});

// 格式化日期函数
const formatDate = (dateStr) => {
  if (!dateStr) return '暂无';
  const date = new Date(dateStr);
  return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
};

// 表单验证规则
const formRules = {
  customerId: [
    { required: true, message: '请选择客户', trigger: 'change' }
  ],
  followType: [
    { required: true, message: '请选择跟进方式', trigger: 'change' }
  ],
  followTime: [
    { required: true, message: '请选择跟进时间', trigger: 'change' }
  ],
  content: [
    { required: true, message: '请输入跟进内容', trigger: 'blur' }
  ]
};

// 获取客户跟进记录列表
const fetchFollowList = async () => {
  loading.value = true;
  try {
    const params = {
      page: currentPage.value,
      pageSize: pageSize.value
    };
    
    // 添加搜索条件
    if (searchForm.value.customerName) {
      params.customerName = searchForm.value.customerName;
    }
    if (searchForm.value.followType) {
      params.followType = searchForm.value.followType;
    }
    if (searchForm.value.dateRange && searchForm.value.dateRange.length === 2) {
      params.startDate = searchForm.value.dateRange[0];
      params.endDate = searchForm.value.dateRange[1];
    }
    
    console.log('请求参数:', params);
    const res = await getFollowList(params);
    console.log('获取跟进记录返回数据:', res);
    
    // 兼容不同的后端返回结构
    if (res.data) {
      if (Array.isArray(res.data)) {
        // 直接返回数组的情况
        tableData.value = res.data;
        total.value = res.data.length; // 如果没有返回总数，就用数组长度
      } else if (res.data.list) {
        // 返回{list, total}结构
        tableData.value = res.data.list;
        total.value = res.data.total || res.data.list.length;
      } else if (res.data.rows) {
        // 返回{rows, total}结构
        tableData.value = res.data.rows;
        total.value = res.data.total || res.data.rows.length;
      } else {
        // 其他情况，尝试使用res.data作为数据
        tableData.value = res.data;
        total.value = res.data.length;
      }
    } else {
      tableData.value = [];
      total.value = 0;
      console.error('返回数据格式异常:', res);
    }
  } catch (error) {
    console.error('获取客户跟进记录列表出错:', error);
    ElMessage.error('获取客户跟进记录列表失败，请稍后重试');
    tableData.value = [];
    total.value = 0;
  } finally {
    loading.value = false;
  }
};

// 获取客户列表（用于新增跟进记录时选择客户）
const fetchCustomerList = async () => {
  try {
    const res = await getCustomerList({ pageSize: 1000 });
    customerOptions.value = res.data.list;
  } catch (error) {
    console.error('获取客户列表出错:', error);
    ElMessage.error('获取客户列表失败，请稍后重试');
  }
};

// 查询操作
const handleSearch = () => {
  currentPage.value = 1; // 查询后跳转到第一页
  fetchFollowList();
};

// 重置搜索
const resetSearch = () => {
  searchForm.value = {
    customerName: '',
    followType: '',
    dateRange: []
  };
  handleSearch();
};

// 分页大小变化
const handleSizeChange = (size) => {
  pageSize.value = size;
  fetchFollowList();
};

// 页码变化
const handleCurrentChange = (page) => {
  currentPage.value = page;
  fetchFollowList();
};

// 处理新增操作
const handleAdd = () => {
  // 重置新增表单
  addForm.value = {
    customerId: '',
    followType: '',
    followTime: new Date().toISOString().slice(0, 19).replace('T', ' '),
    content: '',
    nextPlan: '',
    nextTime: ''
  };
  addDialogVisible.value = true;
};

// 取消新增
const cancelAdd = () => {
  addDialogVisible.value = false;
  // 重置表单
  if (addFormRef.value) {
    addFormRef.value.resetFields();
  }
};

// 确认新增
const confirmAdd = () => {
  if (addFormRef.value) {
    addFormRef.value.validate(async (valid) => {
      if (valid) {
        loading.value = true;
        try {
          await addFollow(addForm.value);
          
          ElMessage.success('添加成功');
          addDialogVisible.value = false;
          fetchFollowList(); // 重新加载列表
        } catch (error) {
          console.error('添加客户跟进记录出错:', error);
          ElMessage.error('添加客户跟进记录失败，请稍后重试');
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

// 处理编辑操作
const handleEdit = async (row) => {
  loading.value = true;
  try {
    console.log('获取跟进记录详情，ID:', row.id);
    // 确保传递的是数字ID而不是字符串模板
    const id = parseInt(row.id, 10);
    // 获取完整的跟进记录信息
    const res = await getFollowById(id);
    console.log('获取跟进记录详情返回:', res);
    // 设置编辑表单数据
    editForm.value = {
      id: res.data.id,
      customerName: res.data.customerName,
      followType: res.data.followType,
      followTime: res.data.followTime,
      content: res.data.content,
      nextPlan: res.data.nextPlan,
      nextTime: res.data.nextTime
    };
    editDialogVisible.value = true;
  } catch (error) {
    console.error('获取跟进记录详情出错:', error);
    ElMessage.error('获取跟进记录详情失败，请稍后重试');
  } finally {
    loading.value = false;
  }
};

// 取消编辑
const cancelEdit = () => {
  editDialogVisible.value = false;
  // 重置表单
  if (editFormRef.value) {
    editFormRef.value.resetFields();
  }
};

// 确认编辑
const confirmEdit = () => {
  if (editFormRef.value) {
    editFormRef.value.validate(async (valid) => {
      if (valid) {
        // 显示确认对话框
        ElMessageBox.confirm(
          '确认要修改该跟进记录吗？',
          '提示',
          {
            confirmButtonText: '确认',
            cancelButtonText: '取消',
            type: 'warning'
          }
        )
          .then(async () => {
            loading.value = true;
            try {
              await updateFollow(editForm.value);
              
              ElMessage.success('修改成功');
              editDialogVisible.value = false;
              fetchFollowList(); // 重新加载列表
            } catch (error) {
              console.error('修改跟进记录出错:', error);
              ElMessage.error('修改跟进记录失败，请稍后重试');
            } finally {
              loading.value = false;
            }
          })
          .catch(() => {
            // 取消修改
            ElMessage.info('已取消修改');
          });
      } else {
        ElMessage.warning('请完善表单信息');
        return false;
      }
    });
  }
};

// 处理删除操作
const handleDelete = (row) => {
  deleteForm.value = {
    id: row.id
  };
  deleteDialogVisible.value = true;
};

// 确认删除
const confirmDelete = async () => {
  loading.value = true;
  try {
    console.log('删除跟进记录，ID:', deleteForm.value.id);
    // 确保传递的是数字ID而不是字符串模板
    const id = parseInt(deleteForm.value.id, 10);
    await deleteFollow(id);
    
    ElMessage.success('删除成功');
    deleteDialogVisible.value = false;
    
    // 如果当前页只有一条数据且不是第一页，则删除后跳转到上一页
    if (tableData.value.length === 1 && currentPage.value > 1) {
      currentPage.value--;
    }
    
    fetchFollowList(); // 重新加载列表
  } catch (error) {
    console.error('删除跟进记录出错:', error);
    ElMessage.error('删除跟进记录失败，请稍后重试');
  } finally {
    loading.value = false;
    deleteDialogVisible.value = false;
  }
};

// 初始化
onMounted(() => {
  fetchFollowList();
  fetchCustomerList();
});

// 监听分页变化
watch(currentPage, (newVal) => {
  console.log('页码变化:', newVal);
  fetchFollowList();
});

watch(pageSize, (newVal) => {
  console.log('每页大小变化:', newVal);
  // 页大小变化时重置为第一页
  if (currentPage.value !== 1) {
    currentPage.value = 1;
  } else {
    fetchFollowList();
  }
});
</script>

<style scoped>
.follow-management-container {
  padding: 20px;
}

.search-card {
  margin-bottom: 20px;
}

.search-form {
  display: flex;
  flex-wrap: wrap;
}

.data-card {
  margin-top: 20px;
}

.operation-container {
  margin-bottom: 20px;
  display: flex;
  justify-content: flex-end;
}

.data-table {
  margin-top: 20px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

/* 美化表格样式 */
:deep(.el-table) {
  --el-table-border-color: #ebeef5;
  --el-table-border: 1px solid var(--el-table-border-color);
  border-radius: 4px;
  overflow: hidden;
}

:deep(.el-table th) {
  background-color: #f5f7fa !important;
}

:deep(.el-table--striped .el-table__body tr.el-table__row--striped td) {
  background-color: #fafafa;
}

:deep(.el-table .cell) {
  padding: 12px 8px;
}

:deep(.el-button--small) {
  padding: 6px 12px;
  font-size: 12px;
}
</style> 