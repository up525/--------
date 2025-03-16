<template>
  <div class="layout-container">
    <!-- 顶部标题栏 -->
    <div class="header">
      <div class="title">客户销售管理系统</div>
      <div class="user-info">
        <a href="javascript:;" class="logout">退出登录【张三】</a>
      </div>
    </div>
    
    <div class="main-container">
      <!-- 左侧侧边栏 -->
      <div class="sidebar">
        <el-menu
          :default-active="activeIndex"
          class="menu"
          background-color="#f5f7fa"
          text-color="#333"
          active-text-color="#1890ff"
          :router="true"
        >
          <el-menu-item index="/home">
            <el-icon><HomeFilled /></el-icon>
            <span>首页</span>
          </el-menu-item>

          <el-menu-item index="/data-management">
            <el-icon><Folder /></el-icon>
            <span>资料管理</span>
          </el-menu-item>

          <el-sub-menu index="/development-plan">
            <template #title>
              <el-icon><Calendar /></el-icon>
              <span>开发计划</span>
            </template>
            <el-menu-item index="/development-plan/management">
              <el-icon><SetUp /></el-icon>
              <span>开发计划管理</span>
            </el-menu-item>
            <el-menu-item index="/development-plan/tracking">
              <el-icon><Timer /></el-icon>
              <span>开发计划的跟踪</span>
            </el-menu-item>
          </el-sub-menu>

          <el-menu-item index="/statistics">
            <el-icon><PieChart /></el-icon>
            <span>图表统计</span>
          </el-menu-item>
        </el-menu>
      </div>
      
      <!-- 右侧内容区域 -->
      <div class="content">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { 
  HomeFilled, 
  Folder, 
  Calendar, 
  SetUp, 
  Timer, 
  PieChart 
} from '@element-plus/icons-vue';

const activeIndex = ref('/home');
</script>

<style scoped>
.layout-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  width: 100%;
  min-width: 100%;
  max-width: 100%;
  overflow: hidden;
  background-color: #f0f2f5;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 60px;
  padding: 0 16px;
  background-color: #409EFF;
  color: white;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
  z-index: 10;
  width: 100%;
  min-width: 100%;
  max-width: 100%;
  position: relative;
}

.title {
  font-family: 楷体;
  font-size: 30px;
  font-weight: bold;
  text-align: left;
}

.logout {
  color: white;
  text-decoration: none;
}

.logout:hover {
  text-decoration: underline;
}

.main-container {
  display: flex;
  flex: 1;
  overflow: hidden;
  width: 100%;
  min-width: 100%;
  max-width: 100%;
  position: relative;
}

.sidebar {
  width: 180px;
  min-width: 180px;
  max-width: 180px;
  background-color: #f5f7fa;
  height: 100%;
  overflow-y: auto;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  z-index: 5;
  border-right: 1px solid #ebeef5;
  position: relative;
}

.menu {
  border-right: none;
  height: 100%;
  width: 100%;
}

.content {
  flex: 1;
  overflow: auto;
  background-color: #f0f2f5;
  display: flex;
  flex-direction: column;
  width: calc(100% - 180px);
  max-width: calc(100% - 180px);
  padding: 0;
  position: relative;
}

@media screen and (max-width: 1200px) {
  .layout-container {
    min-width: 1200px;
  }
  
  .header {
    min-width: 1200px;
  }
  
  .main-container {
    min-width: 1200px;
  }
}
</style> 