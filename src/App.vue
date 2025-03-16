<script setup>
// 无需引入组件
</script>

<template>
  <router-view />
</template>

<style>
html, body {
  margin: 0;
  padding: 0;
  height: 100%;
  width: 100%;
  font-family: 'Microsoft YaHei', sans-serif;
  background-color: #f0f2f5;
  color: #333;
  overflow-x: hidden;
  min-width: 100%;
  max-width: 100%;
}

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

#app {
  height: 100vh;
  width: 100%;
  min-width: 100%;
  max-width: 100%;
  margin: 0;
  padding: 0;
  overflow-x: hidden;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
}

/* 全局覆盖element-plus的某些样式 */
.el-card {
  --el-card-padding: 16px;
  border-radius: 4px;
  overflow: visible;
  transition: all 0.3s;
  border: none;
}

.el-card__header {
  padding: 16px;
  border-bottom: 1px solid #ebeef5;
  background-color: #fafbfc;
}

.el-button {
  --el-button-hover-text-color: #1890ff;
  --el-button-hover-border-color: #1890ff;
  --el-button-hover-bg-color: rgba(24, 144, 255, 0.1);
}

.el-button--primary {
  --el-button-bg-color: #1890ff;
  --el-button-border-color: #1890ff;
  --el-button-hover-bg-color: #40a9ff;
  --el-button-hover-border-color: #40a9ff;
}

.el-row {
  margin-left: 0 !important;
  margin-right: 0 !important;
  width: 100%;
}

.el-col {
  padding-left: 8px !important;
  padding-right: 8px !important;
}

.el-menu-item.is-active {
  background-color: #e6f7ff !important;
}

.el-menu-item:hover {
  background-color: #f5f5f5 !important;
}

.el-menu {
  border-right: none !important;
}

::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

::-webkit-scrollbar-thumb {
  background: #ccc;
  border-radius: 3px;
}

::-webkit-scrollbar-thumb:hover {
  background: #bbb;
}

@media screen and (max-width: 1200px) {
  html, body, #app {
    min-width: 1200px;
  }
}
</style>
