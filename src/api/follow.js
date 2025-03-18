import request from '@/utils/request'; 
 
// �ͻ��������API 
 
export function getFollowList(params) { return request({ url: '/customer-follows/list', method: 'get', params }); } 
 
export function getFollowById(id) { return request({ url: `/customer-follows/${id}`, method: 'get' }); } 
 
export function addFollow(data) { return request({ url: '/customer-follows', method: 'post', data }); } 
 
export function updateFollow(data) { return request({ url: '/customer-follows', method: 'put', data }); } 
 
export function deleteFollow(id) { return request({ url: `/customer-follows/${id}`, method: 'delete' }); } 
