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
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
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
import { ref, computed, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { 
  getFollowList, 
  getFollowById, 
  addFollow, 
  updateFollow, 
  deleteFollow 
} from '@/api/follow';
import { getCustomerList } from '@/api/customer';
import { parseBlobContent, formatObjectWithBlobs, formatListWithBlobs } from '@/utils/blob-parser';

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
    
    console.log('开始获取客户跟进列表...');
    const res = await getFollowList(params);
    console.log('获取客户跟进列表成功, 响应码:', res.code);
    
    // 确保响应数据结构正确
    if (!res || typeof res !== 'object') {
      console.error('响应数据异常:', res);
      ElMessage.error('获取数据格式异常');
      tableData.value = [];
      total.value = 0;
      return;
    }
    
    // 确保data.list存在
    if (!res.data) {
      console.warn('响应中没有data字段');
      res.data = { list: [], total: 0 };
    } else if (!res.data.list && Array.isArray(res.data)) {
      // 如果data是数组而不是{list, total}结构
      console.warn('数据结构为数组，进行适配');
      res.data = { list: res.data, total: res.data.length };
    } else if (!res.data.list) {
      console.warn('数据中没有list字段');
      res.data.list = [];
      res.data.total = 0;
    }
    
    console.log('获取到跟进记录条数:', res.data.list.length);
    
    // 使用工具函数处理整个列表的BLOB字段
    if (res.data.list && res.data.list.length > 0) {
      try {
        console.log('开始处理跟进记录数据...');
        // 使用工具函数处理整个列表
        const processedList = formatListWithBlobs(res.data.list, ['content', 'nextPlan']);
        
        // 确保所有必要的字段都存在
        tableData.value = processedList.map((item, index) => {
          // 添加默认值，确保表格正常显示
          return {
            ...item,
            id: item.id || index + 1,
            customerName: item.customerName || '未知客户',
            userName: item.userName || '未知用户',
            followType: item.followType || '未知类型',
            followTime: item.followTime || new Date().toISOString().slice(0, 19).replace('T', ' '),
            nextTime: item.nextTime || '',
            content: item.content || '',
            nextPlan: item.nextPlan || ''
          };
        });
        
        console.log('数据处理完成，表格数据条数:', tableData.value.length);
      } catch (error) {
        console.error('处理数据时出错:', error);
        // 发生错误时，尝试简单处理
        tableData.value = res.data.list.map((item, index) => ({
          id: item.id || index + 1,
          customerName: item.customerName || '未知客户',
          userName: item.userName || '未知用户',
          followType: item.followType || '未知类型',
          followTime: item.followTime || '',
          content: typeof item.content === 'object' ? '数据解析中...' : (item.content || ''),
          nextPlan: typeof item.nextPlan === 'object' ? '数据解析中...' : (item.nextPlan || ''),
          nextTime: item.nextTime || ''
        }));
      }
    } else {
      console.log('无跟进记录数据');
      tableData.value = [];
    }
    
    total.value = res.data.total || 0;
    console.log('设置总记录数:', total.value);
  } catch (error) {
    console.error('获取客户跟进记录列表出错:', error);
    console.log('错误详情:', error.message, error.stack);
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
    console.log('开始获取客户列表...');
    const res = await getCustomerList({ pageSize: 1000 });
    
    // 确保响应数据结构正确
    if (!res || !res.data || !res.data.list) {
      console.error('客户列表响应异常:', res);
      ElMessage.error('获取客户列表格式异常');
      customerOptions.value = [];
      return;
    }
    
    customerOptions.value = res.data.list;
    console.log('获取客户列表成功，条数:', customerOptions.value.length);
  } catch (error) {
    console.error('获取客户列表出错:', error);
    ElMessage.error('获取客户列表失败，请稍后重试');
    customerOptions.value = [];
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
  console.log('开始编辑记录, ID:', row.id);
  loading.value = true;
  try {
    // 获取完整的跟进记录信息
    const res = await getFollowById(row.id);
    console.log('获取详情成功, 响应码:', res.code);
    
    // 确保响应数据结构正确
    if (!res || !res.data) {
      console.error('获取详情响应异常:', res);
      ElMessage.error('获取详情数据异常');
      return;
    }
    
    // 使用BLOB解析工具处理详情数据
    const processedData = formatObjectWithBlobs(res.data);
    
    // 设置编辑表单数据
    editForm.value = {
      id: processedData.id,
      customerName: processedData.customerName || '未知客户',
      followType: processedData.followType || '未知类型',
      followTime: processedData.followTime || new Date().toISOString().slice(0, 19).replace('T', ' '),
      content: processedData.content,
      nextPlan: processedData.nextPlan,
      nextTime: processedData.nextTime || ''
    };
    
    console.log('编辑表单数据设置完成:', {
      id: editForm.value.id,
      customerName: editForm.value.customerName,
      followType: editForm.value.followType
    });
    
    editDialogVisible.value = true;
  } catch (error) {
    console.error('获取跟进记录详情出错:', error);
    console.log('错误详情:', error.message, error.stack);
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
    await deleteFollow(deleteForm.value.id);
    
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
  console.log('客户跟进模块初始化...');
  fetchFollowList();
  fetchCustomerList();
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