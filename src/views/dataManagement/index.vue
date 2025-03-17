<template>
  <div class="data-management-container">
    <!-- 搜索区域 -->
    <el-card class="search-card">
      <el-form :model="searchForm" :inline="true" class="search-form">
        <el-form-item label="客户名称">
          <el-input v-model="searchForm.name" placeholder="请输入客户名称" clearable />
        </el-form-item>
        <el-form-item label="联系人">
          <el-input v-model="searchForm.contact" placeholder="请输入联系人" clearable />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="searchForm.phone" placeholder="请输入联系电话" clearable />
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
        <el-button type="primary" @click="handleAdd">新增</el-button>
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
          <el-table-column prop="name" label="客户名称" min-width="180" show-overflow-tooltip />
          <el-table-column label="联系人" width="100" align="center">
            <template #default="scope">
              {{ scope.row.contact || '暂无' }}
            </template>
          </el-table-column>
          <el-table-column label="联系电话" width="120" align="center">
            <template #default="scope">
              {{ scope.row.phone || '暂无' }}
            </template>
          </el-table-column>
          <el-table-column prop="address" label="地址" min-width="200" show-overflow-tooltip />
          <el-table-column label="行业" width="100" align="center">
            <template #default="scope">
              {{ scope.row.industry || '暂无' }}
            </template>
          </el-table-column>
          <el-table-column label="创建时间" width="160" align="center">
            <template #default="scope">
              {{ formatDate(scope.row.createdAt) }}
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
      title="编辑客户信息"
      width="50%"
      :close-on-click-modal="false"
    >
      <el-form :model="editForm" label-width="100px" :rules="formRules" ref="editFormRef">
        <el-form-item label="客户名称" prop="name">
          <el-input v-model="editForm.name" placeholder="请输入客户名称" />
        </el-form-item>
        <el-form-item label="联系人" prop="contact">
          <el-input v-model="editForm.contact" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="editForm.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="地址" prop="address">
          <el-input v-model="editForm.address" placeholder="请输入地址" />
        </el-form-item>
        <el-form-item label="行业" prop="industry">
          <el-input v-model="editForm.industry" placeholder="请输入行业" />
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
      title="新增客户"
      width="50%"
      :close-on-click-modal="false"
    >
      <el-form :model="addForm" label-width="100px" :rules="formRules" ref="addFormRef">
        <el-form-item label="客户名称" prop="name">
          <el-input v-model="addForm.name" placeholder="请输入客户名称" />
        </el-form-item>
        <el-form-item label="联系人" prop="contact">
          <el-input v-model="addForm.contact" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="addForm.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="地址" prop="address">
          <el-input v-model="addForm.address" placeholder="请输入地址" />
        </el-form-item>
        <el-form-item label="行业" prop="industry">
          <el-input v-model="addForm.industry" placeholder="请输入行业" />
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
      <div>确定要删除【{{ deleteForm.name }}】吗？此操作不可恢复！</div>
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
  getCustomerList, 
  getCustomerById, 
  addCustomer, 
  updateCustomer, 
  deleteCustomer 
} from '@/api/customer';

// 搜索表单
const searchForm = ref({
  name: '',
  contact: '',
  phone: ''
});

// 分页相关
const currentPage = ref(1);
const pageSize = ref(10);
const loading = ref(false);
const total = ref(0);
const tableData = ref([]);

// 编辑相关
const editDialogVisible = ref(false);
const editFormRef = ref(null);
const editForm = ref({
  id: '',
  name: '',
  contact: '',
  phone: '',
  address: '',
  industry: ''
});

// 新增相关
const addDialogVisible = ref(false);
const addFormRef = ref(null);
const addForm = ref({
  name: '',
  contact: '',
  phone: '',
  address: '',
  industry: ''
});

// 删除相关
const deleteDialogVisible = ref(false);
const deleteForm = ref({
  id: '',
  name: ''
});

// 格式化日期函数
const formatDate = (dateStr) => {
  if (!dateStr) return '暂无';
  const date = new Date(dateStr);
  return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
};

// 表单验证规则 - 统一的验证规则用于新增和编辑
const formRules = {
  name: [
    { required: true, message: '请输入客户名称', trigger: 'blur' },
    { min: 2, max: 50, message: '长度在2到50个字符之间', trigger: 'blur' }
  ],
  contact: [
    { required: true, message: '请输入联系人', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入联系电话', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
  ]
};

// 获取客户列表数据
const fetchCustomerList = async () => {
  loading.value = true;
  try {
    const params = {
      page: currentPage.value,
      pageSize: pageSize.value
    };
    
    // 添加搜索条件
    if (searchForm.value.name) {
      params.name = searchForm.value.name;
    }
    if (searchForm.value.contact) {
      params.contact = searchForm.value.contact;
    }
    if (searchForm.value.phone) {
      params.phone = searchForm.value.phone;
    }
    
    const res = await getCustomerList(params);
    // 适配后端返回的数据结构
    tableData.value = res.data.list;
    total.value = res.data.total;
  } catch (error) {
    console.error('获取客户列表出错:', error);
    ElMessage.error('获取客户列表失败，请稍后重试');
  } finally {
    loading.value = false;
  }
};

// 查询操作
const handleSearch = () => {
  currentPage.value = 1; // 查询后跳转到第一页
  fetchCustomerList();
};

// 重置搜索
const resetSearch = () => {
  searchForm.value = {
    name: '',
    contact: '',
    phone: ''
  };
  handleSearch();
};

// 分页大小变化
const handleSizeChange = (size) => {
  pageSize.value = size;
  fetchCustomerList();
};

// 页码变化
const handleCurrentChange = (page) => {
  currentPage.value = page;
  fetchCustomerList();
};

// 处理新增操作
const handleAdd = () => {
  // 重置新增表单
  addForm.value = {
    name: '',
    contact: '',
    phone: '',
    address: '',
    industry: ''
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
          await addCustomer({
            name: addForm.value.name,
            contact: addForm.value.contact,
            phone: addForm.value.phone,
            address: addForm.value.address,
            industry: addForm.value.industry
          });
          
          ElMessage.success('添加成功');
          addDialogVisible.value = false;
          fetchCustomerList(); // 重新加载列表
        } catch (error) {
          console.error('添加客户出错:', error);
          ElMessage.error('添加客户失败，请稍后重试');
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
    // 获取完整的客户信息
    const res = await getCustomerById(row.id);
    // 设置编辑表单数据
    editForm.value = {
      id: res.data.id,
      name: res.data.name,
      contact: res.data.contact || '',
      phone: res.data.phone || '',
      address: res.data.address,
      industry: res.data.industry || ''
    };
    editDialogVisible.value = true;
  } catch (error) {
    console.error('获取客户详情出错:', error);
    ElMessage.error('获取客户详情失败，请稍后重试');
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
          '确认要修改该客户信息吗？',
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
              await updateCustomer({
                id: editForm.value.id,
                name: editForm.value.name,
                contact: editForm.value.contact,
                phone: editForm.value.phone,
                address: editForm.value.address,
                industry: editForm.value.industry
              });
              
              ElMessage.success('修改成功');
              editDialogVisible.value = false;
              fetchCustomerList(); // 重新加载列表
            } catch (error) {
              console.error('修改客户出错:', error);
              ElMessage.error('修改客户失败，请稍后重试');
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
    id: row.id,
    name: row.name
  };
  deleteDialogVisible.value = true;
};

// 确认删除
const confirmDelete = async () => {
  loading.value = true;
  try {
    await deleteCustomer(deleteForm.value.id);
    
    ElMessage.success('删除成功');
    deleteDialogVisible.value = false;
    
    // 如果当前页只有一条数据且不是第一页，则删除后跳转到上一页
    if (tableData.value.length === 1 && currentPage.value > 1) {
      currentPage.value--;
    }
    
    fetchCustomerList(); // 重新加载列表
  } catch (error) {
    console.error('删除客户出错:', error);
    ElMessage.error('删除客户失败，请稍后重试');
  } finally {
    loading.value = false;
    deleteDialogVisible.value = false;
  }
};

// 初始化
onMounted(() => {
  fetchCustomerList();
});
</script>

<style scoped>
.data-management-container {
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