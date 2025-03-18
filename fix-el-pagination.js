const fs = require('fs'); 
const filePath = 'src/views/dataManagement/follow.vue'; 
let content = fs.readFileSync(filePath, 'utf8'); 
content = content.replace(/v-model:current-page/g, ':current-page'); 
content = content.replace(/v-model:page-size/g, ':page-size'); 
fs.writeFileSync(filePath, content, 'utf8'); 
console.log('Element Plus 分页组件修复完成！'); 
