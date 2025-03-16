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
      <div class="data-table">
        <el-table :data="paginatedData" style="width: 100%" v-loading="loading">
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="name" label="客户名称" width="180" />
          <el-table-column prop="contact" label="联系人" width="120" />
          <el-table-column prop="phone" label="联系电话" width="150" />
          <el-table-column prop="address" label="地址" />
          <el-table-column prop="createTime" label="创建时间" width="180" />
          <el-table-column label="操作" width="180">
            <template #default>
              <el-button size="small" type="primary">编辑</el-button>
              <el-button size="small" type="danger">删除</el-button>
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
            :total="filteredData.length"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
            background
          />
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';

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

// 模拟数据 - 扩展为更多数据以展示分页效果
const allData = ref([
  {
    id: 1,
    name: '阿里巴巴科技有限公司',
    contact: '马云',
    phone: '13812345678',
    address: '杭州市余杭区文一西路969号',
    createTime: '2023-01-15 08:30:00'
  },
  {
    id: 2,
    name: '腾讯科技有限公司',
    contact: '马化腾',
    phone: '13987654321',
    address: '深圳市南山区高新科技园',
    createTime: '2023-02-20 14:20:00'
  },
  {
    id: 3,
    name: '百度在线网络技术有限公司',
    contact: '李彦宏',
    phone: '13567891234',
    address: '北京市海淀区上地十街10号',
    createTime: '2023-03-10 10:15:00'
  },
  {
    id: 4,
    name: '京东集团',
    contact: '刘强东',
    phone: '15898765432',
    address: '北京市朝阳区北辰西路8号',
    createTime: '2023-03-15 09:00:00'
  },
  {
    id: 5,
    name: '小米科技有限公司',
    contact: '雷军',
    phone: '13712345678',
    address: '北京市海淀区清河中街68号',
    createTime: '2023-03-20 16:45:00'
  },
  {
    id: 6,
    name: '华为技术有限公司',
    contact: '任正非',
    phone: '13812378945',
    address: '深圳市龙岗区坂田华为基地',
    createTime: '2023-03-25 11:30:00'
  },
  {
    id: 7,
    name: '网易有道公司',
    contact: '丁磊',
    phone: '13845678901',
    address: '杭州市滨江区网商路599号',
    createTime: '2023-04-05 08:30:00'
  },
  {
    id: 8,
    name: '字节跳动有限公司',
    contact: '张一鸣',
    phone: '13756781234',
    address: '北京市海淀区海淀大街8号',
    createTime: '2023-04-10 14:20:00'
  },
  {
    id: 9,
    name: '拼多多电子商务',
    contact: '黄峥',
    phone: '13609876543',
    address: '上海市长宁区娄山关路533号',
    createTime: '2023-04-15 10:15:00'
  },
  {
    id: 10,
    name: '美团网络有限公司',
    contact: '王兴',
    phone: '13587654321',
    address: '北京市朝阳区望京东路6号',
    createTime: '2023-04-20 09:00:00'
  },
  {
    id: 11,
    name: '滴滴出行科技有限公司',
    contact: '程维',
    phone: '13712378901',
    address: '北京市海淀区软件园二期',
    createTime: '2023-04-25 16:45:00'
  },
  {
    id: 12,
    name: '陆金所金融科技',
    contact: '计葵生',
    phone: '13898765432',
    address: '上海市浦东新区陆家嘴环路1000号',
    createTime: '2023-05-01 11:30:00'
  },
  {
    id: 13,
    name: '上海汽车集团',
    contact: '陈虹',
    phone: '13645678901',
    address: '上海市静安区威海路489号',
    createTime: '2023-05-05 08:30:00'
  },
  {
    id: 14,
    name: '中国石油天然气集团',
    contact: '王宜林',
    phone: '13756784321',
    address: '北京市东城区东直门北大街9号',
    createTime: '2023-05-10 14:20:00'
  }
]);

// 根据搜索条件筛选数据
const filteredData = computed(() => {
  const { name, contact, phone } = searchForm.value;
  return allData.value.filter(item => {
    const nameMatch = !name || item.name.includes(name);
    const contactMatch = !contact || item.contact.includes(contact);
    const phoneMatch = !phone || item.phone.includes(phone);
    return nameMatch && contactMatch && phoneMatch;
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

.data-table {
  margin-top: 20px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style> 