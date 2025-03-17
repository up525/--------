import { createRouter, createWebHashHistory } from 'vue-router';
import MainLayout from '../layouts/MainLayout.vue';

const routes = [
  {
    path: '/',
    component: MainLayout,
    redirect: '/home',
    children: [
      {
        path: '/home',
        name: 'Home',
        component: () => import('../views/home/index.vue'),
        meta: { title: '首页' }
      },
      {
        path: '/data-management',
        name: 'DataManagement',
        component: () => import('../views/dataManagement/index.vue'),
        meta: { title: '资料管理' }
      },
      {
        path: '/customer-follow',
        name: 'CustomerFollow',
        component: () => import('../views/dataManagement/follow.vue'),
        meta: { title: '客户跟进' }
      },
      {
        path: '/development-plan/management',
        name: 'DevelopmentPlanManagement',
        component: () => import('../views/developmentPlan/management/index.vue'),
        meta: { title: '开发计划管理' }
      },
      {
        path: '/development-plan/tracking',
        name: 'DevelopmentPlanTracking',
        component: () => import('../views/developmentPlan/tracking/index.vue'),
        meta: { title: '开发计划的跟踪' }
      },
      {
        path: '/statistics',
        name: 'Statistics',
        component: () => import('../views/statistics/index.vue'),
        meta: { title: '图表统计' }
      }
    ]
  }
];

const router = createRouter({
  history: createWebHashHistory(),
  routes
});

export default router; 