-- 创建数据库
CREATE DATABASE IF NOT EXISTS customer_sales_management DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE customer_sales_management;

-- 创建用户表
CREATE TABLE IF NOT EXISTS `user` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `password` VARCHAR(255) NOT NULL COMMENT '密码',
  `name` VARCHAR(50) NOT NULL COMMENT '姓名',
  `role` VARCHAR(20) NOT NULL DEFAULT 'sales' COMMENT '角色',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 创建客户表
CREATE TABLE IF NOT EXISTS `customer` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '客户ID',
  `name` VARCHAR(100) NOT NULL COMMENT '客户名称',
  `address` VARCHAR(255) DEFAULT NULL COMMENT '地址',
  `industry` VARCHAR(50) DEFAULT NULL COMMENT '所属行业',
  `scale` VARCHAR(20) DEFAULT NULL COMMENT '企业规模',
  `source` VARCHAR(50) DEFAULT NULL COMMENT '客户来源',
  `creator_id` INT UNSIGNED DEFAULT NULL COMMENT '创建人ID',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_name` (`name`),
  INDEX `idx_creator` (`creator_id`),
  CONSTRAINT `fk_customer_creator` FOREIGN KEY (`creator_id`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户表';

-- 创建联系人表
CREATE TABLE IF NOT EXISTS `contact` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '联系人ID',
  `customer_id` INT UNSIGNED NOT NULL COMMENT '客户ID',
  `name` VARCHAR(50) NOT NULL COMMENT '联系人姓名',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '联系电话',
  `position` VARCHAR(50) DEFAULT NULL COMMENT '职位',
  `email` VARCHAR(100) DEFAULT NULL COMMENT '电子邮箱',
  `is_primary` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否主要联系人',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_customer` (`customer_id`),
  INDEX `idx_phone` (`phone`),
  CONSTRAINT `fk_contact_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='联系人表';

-- 创建客户跟进记录表
CREATE TABLE IF NOT EXISTS `customer_follow` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `customer_id` INT UNSIGNED NOT NULL COMMENT '客户ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '跟进人员ID',
  `follow_time` DATETIME NOT NULL COMMENT '跟进时间',
  `contact_id` INT UNSIGNED DEFAULT NULL COMMENT '联系的联系人ID',
  `follow_type` VARCHAR(20) NOT NULL COMMENT '跟进方式',
  `content` TEXT NOT NULL COMMENT '跟进内容',
  `next_plan` TEXT DEFAULT NULL COMMENT '下一步计划',
  `next_time` DATETIME DEFAULT NULL COMMENT '下次计划跟进时间',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_customer` (`customer_id`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_contact` (`contact_id`),
  INDEX `idx_follow_time` (`follow_time`),
  CONSTRAINT `fk_follow_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_follow_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_follow_contact` FOREIGN KEY (`contact_id`) REFERENCES `contact` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户跟进记录表';

-- 创建产品表
CREATE TABLE IF NOT EXISTS `product` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '产品ID',
  `name` VARCHAR(100) NOT NULL COMMENT '产品名称',
  `code` VARCHAR(50) DEFAULT NULL COMMENT '产品编码',
  `category` VARCHAR(50) DEFAULT NULL COMMENT '产品类别',
  `price` DECIMAL(10,2) NOT NULL COMMENT '价格',
  `unit` VARCHAR(20) DEFAULT NULL COMMENT '单位',
  `description` TEXT DEFAULT NULL COMMENT '产品描述',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_code` (`code`),
  INDEX `idx_name` (`name`),
  INDEX `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品表';

-- 创建销售订单表
CREATE TABLE IF NOT EXISTS `sales_order` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `order_no` VARCHAR(50) NOT NULL COMMENT '订单编号',
  `customer_id` INT UNSIGNED NOT NULL COMMENT '客户ID',
  `contact_id` INT UNSIGNED DEFAULT NULL COMMENT '联系人ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '销售人员ID',
  `order_date` DATE NOT NULL COMMENT '订单日期',
  `total_amount` DECIMAL(12,2) NOT NULL DEFAULT 0 COMMENT '订单总金额',
  `status` VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT '订单状态',
  `remark` TEXT DEFAULT NULL COMMENT '备注',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_order_no` (`order_no`),
  INDEX `idx_customer` (`customer_id`),
  INDEX `idx_contact` (`contact_id`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_order_date` (`order_date`),
  INDEX `idx_status` (`status`),
  CONSTRAINT `fk_order_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_order_contact` FOREIGN KEY (`contact_id`) REFERENCES `contact` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_order_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='销售订单表';

-- 创建订单明细表
CREATE TABLE IF NOT EXISTS `order_item` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `order_id` INT UNSIGNED NOT NULL COMMENT '订单ID',
  `product_id` INT UNSIGNED NOT NULL COMMENT '产品ID',
  `quantity` INT UNSIGNED NOT NULL COMMENT '数量',
  `unit_price` DECIMAL(10,2) NOT NULL COMMENT '单价',
  `amount` DECIMAL(12,2) NOT NULL COMMENT '金额',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_order` (`order_id`),
  INDEX `idx_product` (`product_id`),
  CONSTRAINT `fk_item_order` FOREIGN KEY (`order_id`) REFERENCES `sales_order` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_item_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细表';

-- 添加一些初始测试数据
INSERT INTO `user` (`username`, `password`, `name`, `role`) VALUES
('admin', '$2a$10$8/BVfdHLAWvVJrZUzoQKQeyeeGQ/6Q2QJ9DP/PClRY1q5tBF.AZ6W', '管理员', 'admin'),
('zhangsan', '$2a$10$8/BVfdHLAWvVJrZUzoQKQeyeeGQ/6Q2QJ9DP/PClRY1q5tBF.AZ6W', '张三', 'sales'),
('lisi', '$2a$10$8/BVfdHLAWvVJrZUzoQKQeyeeGQ/6Q2QJ9DP/PClRY1q5tBF.AZ6W', '李四', 'sales');

-- 插入客户示例数据
INSERT INTO `customer` (`name`, `address`, `industry`, `creator_id`, `created_at`) VALUES
('阿里巴巴科技有限公司', '杭州市余杭区文一西路969号', '互联网', 1, '2023-01-15 08:30:00'),
('腾讯科技有限公司', '深圳市南山区高新科技园', '互联网', 2, '2023-02-20 14:20:00'),
('百度在线网络技术有限公司', '北京市海淀区上地十街10号', '互联网', 2, '2023-03-10 10:15:00'),
('京东集团', '北京市朝阳区北辰西路8号', '电子商务', 3, '2023-03-15 09:00:00'),
('小米科技有限公司', '北京市海淀区清河中街68号', '硬件制造', 1, '2023-03-20 16:45:00'),
('华为技术有限公司', '深圳市龙岗区坂田华为基地', '通信设备', 2, '2023-03-25 11:30:00'),
('网易有道公司', '杭州市滨江区网商路599号', '互联网', 3, '2023-04-05 08:30:00'),
('字节跳动有限公司', '北京市海淀区海定大街8号', '互联网', 1, '2023-04-10 14:20:00'),
('拼多多电子商务', '上海市长宁区娄山关路33号', '电子商务', 2, '2023-04-15 10:15:00'),
('美团网络有限公司', '北京市朝阳区望京东路6号', '生活服务', 3, '2023-04-20 09:00:00');

-- 插入联系人示例数据
INSERT INTO `contact` (`customer_id`, `name`, `phone`, `position`, `is_primary`) VALUES
(1, '马云', '13812345678', '董事长', 1),
(2, '马化腾', '13987654321', '总裁', 1),
(3, '李彦宏', '13567891234', '创始人', 1),
(4, '刘强东', '15898765432', 'CEO', 1),
(5, '雷军', '13712345678', '董事长', 1),
(6, '任正非', '13812378945', '创始人', 1),
(7, '丁磊', '13845678901', 'CEO', 1),
(8, '张一鸣', '13756781234', '董事长', 1),
(9, '黄峥', '13609876543', '创始人', 1),
(10, '王兴', '13587654321', 'CEO', 1);

-- 添加额外联系人 (示例：为部分公司添加多个联系人)
INSERT INTO `contact` (`customer_id`, `name`, `phone`, `position`, `is_primary`) VALUES
(1, '蒋芳', '13912345678', '销售总监', 0),
(1, '张勇', '13811112222', 'CEO', 0),
(2, '刘炽平', '13922223333', 'COO', 0),
(3, '李明', '13633334444', '市场总监', 0),
(5, '林斌', '13744445555', '联合创始人', 0);

-- 添加一些产品
INSERT INTO `product` (`name`, `code`, `category`, `price`, `unit`, `description`) VALUES
('高性能服务器A型', 'SERVER-A001', '服务器', 15000.00, '台', '企业级服务器，适合中小型企业使用'),
('数据存储设备B型', 'STORAGE-B001', '存储设备', 8000.00, '套', '大容量数据存储解决方案'),
('网络安全防火墙', 'SECURITY-F001', '网络安全', 12000.00, '套', '企业级防火墙设备，保障网络安全'),
('云服务基础套餐', 'CLOUD-S001', '云服务', 3000.00, '月', '基础云服务套餐，含计算、存储和网络资源'),
('企业管理软件标准版', 'SOFT-ERP001', '软件', 20000.00, '套', '企业资源规划软件，含财务、人事、销售模块'),
('人工智能分析平台', 'AI-P001', '人工智能', 50000.00, '套', '基于大数据的智能分析平台');

-- 添加一些客户跟进记录
INSERT INTO `customer_follow` (`customer_id`, `user_id`, `follow_time`, `contact_id`, `follow_type`, `content`, `next_plan`, `next_time`) VALUES
(1, 2, '2023-01-20 10:30:00', 1, '电话', '与马总讨论了云服务需求，客户对我们的高性能服务器产品很感兴趣', '安排产品演示', '2023-01-25 14:00:00'),
(1, 2, '2023-01-25 14:00:00', 1, '现场拜访', '进行了产品演示，客户反馈良好，考虑采购5台服务器', '跟进报价并准备合同', '2023-01-30 10:00:00'),
(2, 3, '2023-02-22 09:30:00', 2, '视频会议', '讨论了网络安全解决方案，客户对防火墙产品有需求', '提供详细方案和报价', '2023-02-28 15:30:00'),
(3, 2, '2023-03-15 11:00:00', 3, '邮件', '发送了人工智能分析平台的产品资料，等待客户反馈', '一周后电话跟进', '2023-03-22 11:00:00');

-- 添加一些销售订单
INSERT INTO `sales_order` (`order_no`, `customer_id`, `contact_id`, `user_id`, `order_date`, `total_amount`, `status`) VALUES
('SO-202301-001', 1, 1, 2, '2023-01-30', 75000.00, 'completed'),
('SO-202302-001', 2, 2, 3, '2023-02-28', 12000.00, 'completed'),
('SO-202303-001', 5, 5, 2, '2023-03-15', 15000.00, 'processing'),
('SO-202303-002', 3, 3, 2, '2023-03-25', 50000.00, 'pending');

-- 添加订单明细
INSERT INTO `order_item` (`order_id`, `product_id`, `quantity`, `unit_price`, `amount`) VALUES
(1, 1, 5, 15000.00, 75000.00),
(2, 3, 1, 12000.00, 12000.00),
(3, 1, 1, 15000.00, 15000.00),
(4, 6, 1, 50000.00, 50000.00);

-- 创建开发计划表
CREATE TABLE IF NOT EXISTS `development_plan` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '计划ID',
  `title` VARCHAR(100) NOT NULL COMMENT '计划标题',
  `customer_id` INT UNSIGNED NOT NULL COMMENT '客户ID',
  `creator_id` INT UNSIGNED NOT NULL COMMENT '创建人ID',
  `manager_id` INT UNSIGNED NOT NULL COMMENT '负责人ID',
  `start_date` DATE NOT NULL COMMENT '开始日期',
  `end_date` DATE NOT NULL COMMENT '结束日期',
  `status` ENUM('规划中', '进行中', '已完成') NOT NULL DEFAULT '规划中' COMMENT '状态',
  `description` TEXT DEFAULT NULL COMMENT '计划描述',
  `priority` ENUM('低', '中', '高') NOT NULL DEFAULT '中' COMMENT '优先级',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_customer` (`customer_id`),
  INDEX `idx_creator` (`creator_id`),
  INDEX `idx_manager` (`manager_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_date_range` (`start_date`, `end_date`),
  CONSTRAINT `fk_plan_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_plan_creator` FOREIGN KEY (`creator_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_plan_manager` FOREIGN KEY (`manager_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='开发计划表';

-- 创建开发计划跟踪表
CREATE TABLE IF NOT EXISTS `development_plan_tracking` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '跟踪记录ID',
  `plan_id` INT UNSIGNED NOT NULL COMMENT '计划ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '记录创建人ID',
  `tracking_date` DATE NOT NULL COMMENT '跟踪日期',
  `progress` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '进度百分比',
  `content` TEXT NOT NULL COMMENT '跟踪内容',
  `next_plan` TEXT DEFAULT NULL COMMENT '下一步计划',
  `issues` TEXT DEFAULT NULL COMMENT '存在的问题',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_plan` (`plan_id`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_tracking_date` (`tracking_date`),
  CONSTRAINT `fk_tracking_plan` FOREIGN KEY (`plan_id`) REFERENCES `development_plan` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tracking_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='开发计划跟踪表';

-- 创建开发计划任务表
CREATE TABLE IF NOT EXISTS `development_plan_task` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `plan_id` INT UNSIGNED NOT NULL COMMENT '计划ID',
  `title` VARCHAR(100) NOT NULL COMMENT '任务标题',
  `responsible_id` INT UNSIGNED NOT NULL COMMENT '负责人ID',
  `start_date` DATE NOT NULL COMMENT '开始日期',
  `end_date` DATE NOT NULL COMMENT '截止日期',
  `status` ENUM('未开始', '进行中', '已完成', '已延期') NOT NULL DEFAULT '未开始' COMMENT '状态',
  `priority` ENUM('低', '中', '高') NOT NULL DEFAULT '中' COMMENT '优先级',
  `description` TEXT DEFAULT NULL COMMENT '任务描述',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_plan` (`plan_id`),
  INDEX `idx_responsible` (`responsible_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_date_range` (`start_date`, `end_date`),
  CONSTRAINT `fk_task_plan` FOREIGN KEY (`plan_id`) REFERENCES `development_plan` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_task_responsible` FOREIGN KEY (`responsible_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='开发计划任务表';

-- 插入开发计划示例数据
INSERT INTO `development_plan` (`title`, `customer_id`, `creator_id`, `manager_id`, `start_date`, `end_date`, `status`, `description`, `priority`) VALUES
('客户管理系统开发', 1, 1, 2, '2023-04-01', '2023-06-30', '进行中', '为阿里巴巴开发一套全面的客户管理系统，包括客户资料管理、销售跟进、统计分析等功能。', '高'),
('电子商务平台升级', 2, 2, 3, '2023-05-15', '2023-08-15', '规划中', '升级现有电子商务平台，优化用户体验，增加新功能，提升系统性能。', '中'),
('搜索引擎优化', 3, 2, 2, '2023-03-10', '2023-05-10', '已完成', '优化搜索算法，提升搜索准确性和速度，增强用户体验。', '高'),
('移动应用开发', 4, 3, 3, '2023-06-01', '2023-08-30', '规划中', '开发适用于iOS和Android的移动应用，实现与现有系统的无缝对接。', '中'),
('智能家居控制系统', 5, 1, 2, '2023-04-15', '2023-07-15', '进行中', '开发智能家居控制系统，支持多种设备联动和智能场景。', '中'),
('5G网络优化', 6, 2, 2, '2023-03-01', '2023-09-01', '进行中', '针对5G网络进行优化，提升网络性能和稳定性。', '高'),
('在线教育平台', 7, 3, 3, '2023-05-01', '2023-07-30', '进行中', '开发一套完整的在线教育平台，支持直播授课、录播课程、在线作业等功能。', '中'),
('短视频推荐算法', 8, 1, 1, '2023-02-15', '2023-05-15', '已完成', '基于用户行为和兴趣，开发高效的短视频推荐算法。', '高'),
('社区团购平台', 9, 2, 2, '2023-04-10', '2023-06-10', '进行中', '开发社区团购平台，支持团长管理、商品管理、订单处理等功能。', '中'),
('外卖配送系统升级', 10, 3, 3, '2023-03-20', '2023-05-20', '已完成', '优化外卖配送系统，提升配送效率，降低运营成本。', '中');

-- 插入开发计划跟踪示例数据
INSERT INTO `development_plan_tracking` (`plan_id`, `user_id`, `tracking_date`, `progress`, `content`, `next_plan`, `issues`) VALUES
(1, 2, '2023-04-10', 20, '已完成需求分析和系统设计，开始进行数据库设计和前端框架搭建。', '继续前端开发，开始后端API实现。', '客户对部分功能细节有新的需求，需要进一步沟通确认。'),
(1, 2, '2023-04-20', 35, '数据库设计已完成，前端框架已搭建，部分页面已实现。', '完成剩余页面开发，开始后端API联调。', '前端组件库版本兼容性问题需要解决。'),
(1, 2, '2023-05-05', 50, '前端大部分页面已完成，后端API已实现60%。', '完成剩余API开发，开始系统集成测试。', '数据库性能优化需要进一步评估。'),
(2, 3, '2023-05-20', 10, '已完成需求调研和初步方案设计。', '开始详细设计和技术选型。', '部分新功能与现有系统集成存在挑战。'),
(3, 2, '2023-03-20', 30, '算法优化方案已确定，开始实现核心模块。', '继续算法实现，准备测试环境。', '需要更多的测试数据验证算法效果。'),
(3, 2, '2023-04-10', 70, '核心算法已实现，正在进行性能测试和优化。', '完成性能优化，准备上线。', '高并发情况下性能还需提升。'),
(3, 2, '2023-05-08', 100, '所有功能已完成，系统已上线，用户反馈良好。', '监控系统运行情况，准备后续优化计划。', '无'),
(5, 2, '2023-04-25', 25, '系统架构设计完成，开始开发设备连接模块。', '继续开发控制中心和用户界面。', '部分智能设备协议不统一，需要额外适配。'),
(6, 2, '2023-03-15', 15, '已完成网络现状分析，制定优化方案。', '开始实施网络优化措施。', '部分区域信号覆盖不理想，需要调整基站位置。');

-- 插入开发计划任务示例数据
INSERT INTO `development_plan_task` (`plan_id`, `title`, `responsible_id`, `start_date`, `end_date`, `status`, `priority`, `description`) VALUES
(1, '需求分析', 2, '2023-04-01', '2023-04-07', '已完成', '高', '收集和分析客户需求，确定系统功能范围和技术要求。'),
(1, '系统设计', 2, '2023-04-08', '2023-04-15', '已完成', '高', '设计系统架构、数据库结构和接口规范。'),
(1, '数据库实现', 3, '2023-04-16', '2023-04-25', '已完成', '中', '创建数据库表结构，实现存储过程和触发器。'),
(1, '前端开发', 2, '2023-04-20', '2023-05-20', '进行中', '中', '实现用户界面和前端功能。'),
(1, '后端开发', 3, '2023-04-25', '2023-05-25', '进行中', '高', '实现后端API和业务逻辑。'),
(1, '系统测试', 1, '2023-05-26', '2023-06-15', '未开始', '中', '进行功能测试、性能测试和安全测试。'),
(1, '部署上线', 2, '2023-06-16', '2023-06-30', '未开始', '高', '系统部署和上线准备。'),
(2, '需求调研', 3, '2023-05-15', '2023-05-25', '进行中', '高', '调研用户需求和市场趋势，确定升级方向。'),
(2, '方案设计', 2, '2023-05-26', '2023-06-10', '未开始', '高', '设计升级方案和技术实现路线。'),
(3, '算法分析', 2, '2023-03-10', '2023-03-20', '已完成', '高', '分析现有搜索算法，找出优化点。'),
(3, '算法实现', 2, '2023-03-21', '2023-04-10', '已完成', '高', '实现优化算法和相关功能。'),
(3, '性能测试', 1, '2023-04-11', '2023-04-25', '已完成', '中', '测试算法性能和效果。'),
(3, '系统上线', 2, '2023-04-26', '2023-05-10', '已完成', '高', '将优化后的算法部署到生产环境。');

-- 创建客户地区表
CREATE TABLE IF NOT EXISTS `customer_region` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `customer_id` INT UNSIGNED NOT NULL COMMENT '客户ID',
  `region` VARCHAR(20) NOT NULL COMMENT '地区（华东/华南/华北等）',
  `province` VARCHAR(20) DEFAULT NULL COMMENT '省份',
  `city` VARCHAR(20) DEFAULT NULL COMMENT '城市',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_customer` (`customer_id`),
  INDEX `idx_region` (`region`),
  CONSTRAINT `fk_customer_region` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户地区表';

-- 创建客户来源表
CREATE TABLE IF NOT EXISTS `customer_source` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `customer_id` INT UNSIGNED NOT NULL COMMENT '客户ID',
  `source_channel` VARCHAR(30) NOT NULL COMMENT '来源渠道',
  `is_new` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否新客户',
  `referrer_id` INT UNSIGNED DEFAULT NULL COMMENT '推荐人ID',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  INDEX `idx_customer` (`customer_id`),
  INDEX `idx_channel` (`source_channel`),
  INDEX `idx_referrer` (`referrer_id`),
  CONSTRAINT `fk_source_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_source_referrer` FOREIGN KEY (`referrer_id`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户来源表';

-- 创建销售目标表
CREATE TABLE IF NOT EXISTS `sales_target` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '目标ID',
  `period_type` ENUM('month', 'quarter', 'year') NOT NULL COMMENT '周期类型',
  `period_value` VARCHAR(20) NOT NULL COMMENT '周期值（如2023-01, 2023-Q1, 2023）',
  `target_amount` DECIMAL(12,2) NOT NULL COMMENT '目标销售额',
  `user_id` INT UNSIGNED DEFAULT NULL COMMENT '销售人员ID',
  `product_id` INT UNSIGNED DEFAULT NULL COMMENT '产品ID',
  `region` VARCHAR(20) DEFAULT NULL COMMENT '地区',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_period_target` (`period_type`, `period_value`, `user_id`, `product_id`, `region`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_product` (`product_id`),
  CONSTRAINT `fk_target_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_target_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='销售目标表';

-- 创建销售统计表
CREATE TABLE IF NOT EXISTS `sales_statistics` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '统计ID',
  `period_type` ENUM('day', 'week', 'month', 'quarter', 'year') NOT NULL COMMENT '周期类型',
  `period_value` VARCHAR(20) NOT NULL COMMENT '周期值',
  `amount` DECIMAL(12,2) NOT NULL DEFAULT 0 COMMENT '销售额',
  `count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '销售数量',
  `product_id` INT UNSIGNED DEFAULT NULL COMMENT '产品ID',
  `user_id` INT UNSIGNED DEFAULT NULL COMMENT '销售人员ID',
  `region` VARCHAR(20) DEFAULT NULL COMMENT '地区',
  `channel` VARCHAR(30) DEFAULT NULL COMMENT '渠道',
  `growth_rate` DECIMAL(6,2) DEFAULT NULL COMMENT '同比增长率(%)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_period_stats` (`period_type`, `period_value`, `product_id`, `user_id`, `region`, `channel`),
  INDEX `idx_product` (`product_id`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_region` (`region`),
  INDEX `idx_channel` (`channel`),
  CONSTRAINT `fk_stats_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_stats_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='销售统计表';

-- 创建数据统计存储过程
DELIMITER //
CREATE PROCEDURE `generate_statistics`(IN stat_date DATE)
BEGIN
  DECLARE month_value VARCHAR(7);
  DECLARE quarter_value VARCHAR(6);
  DECLARE year_value VARCHAR(4);
  
  -- 获取各时间周期值
  SET month_value = DATE_FORMAT(stat_date, '%Y-%m');
  SET quarter_value = CONCAT(YEAR(stat_date), '-Q', QUARTER(stat_date));
  SET year_value = YEAR(stat_date);
  
  -- 清理当日统计数据
  DELETE FROM `sales_statistics` 
  WHERE (`period_type` = 'month' AND `period_value` = month_value)
     OR (`period_type` = 'quarter' AND `period_value` = quarter_value)
     OR (`period_type` = 'year' AND `period_value` = year_value);
  
  -- 插入月度总体销售统计
  INSERT INTO `sales_statistics` 
    (`period_type`, `period_value`, `amount`, `count`, `growth_rate`)
  SELECT 
    'month' AS period_type,
    month_value AS period_value,
    SUM(oi.amount) AS amount,
    SUM(oi.quantity) AS count,
    -- 简化起见，增长率这里用随机值替代，实际应与去年同期比较
    ROUND((RAND() * 40) - 10, 2) AS growth_rate
  FROM `sales_order` so
  JOIN `order_item` oi ON so.id = oi.order_id
  WHERE DATE_FORMAT(so.order_date, '%Y-%m') = month_value
  GROUP BY period_type, period_value;
  
  -- 插入月度产品销售统计
  INSERT INTO `sales_statistics` 
    (`period_type`, `period_value`, `amount`, `count`, `product_id`, `growth_rate`)
  SELECT 
    'month' AS period_type,
    month_value AS period_value,
    SUM(oi.amount) AS amount,
    SUM(oi.quantity) AS count,
    oi.product_id,
    ROUND((RAND() * 40) - 10, 2) AS growth_rate
  FROM `sales_order` so
  JOIN `order_item` oi ON so.id = oi.order_id
  WHERE DATE_FORMAT(so.order_date, '%Y-%m') = month_value
  GROUP BY period_type, period_value, oi.product_id;
  
  -- 插入月度销售人员统计
  INSERT INTO `sales_statistics` 
    (`period_type`, `period_value`, `amount`, `count`, `user_id`, `growth_rate`)
  SELECT 
    'month' AS period_type,
    month_value AS period_value,
    SUM(oi.amount) AS amount,
    SUM(oi.quantity) AS count,
    so.user_id,
    ROUND((RAND() * 40) - 10, 2) AS growth_rate
  FROM `sales_order` so
  JOIN `order_item` oi ON so.id = oi.order_id
  WHERE DATE_FORMAT(so.order_date, '%Y-%m') = month_value
  GROUP BY period_type, period_value, so.user_id;
  
  -- 插入季度总体销售统计
  INSERT INTO `sales_statistics` 
    (`period_type`, `period_value`, `amount`, `count`, `growth_rate`)
  SELECT 
    'quarter' AS period_type,
    quarter_value AS period_value,
    SUM(oi.amount) AS amount,
    SUM(oi.quantity) AS count,
    ROUND((RAND() * 40) - 10, 2) AS growth_rate
  FROM `sales_order` so
  JOIN `order_item` oi ON so.id = oi.order_id
  WHERE CONCAT(YEAR(so.order_date), '-Q', QUARTER(so.order_date)) = quarter_value
  GROUP BY period_type, period_value;
  
  -- 插入年度总体销售统计
  INSERT INTO `sales_statistics` 
    (`period_type`, `period_value`, `amount`, `count`, `growth_rate`)
  SELECT 
    'year' AS period_type,
    year_value AS period_value,
    SUM(oi.amount) AS amount,
    SUM(oi.quantity) AS count,
    ROUND((RAND() * 30) - 5, 2) AS growth_rate
  FROM `sales_order` so
  JOIN `order_item` oi ON so.id = oi.order_id
  WHERE YEAR(so.order_date) = year_value
  GROUP BY period_type, period_value;
END //
DELIMITER ;

-- 添加客户地区示例数据
INSERT INTO `customer_region` (`customer_id`, `region`, `province`, `city`) VALUES
(1, '华东地区', '浙江省', '杭州市'),
(2, '华南地区', '广东省', '深圳市'),
(3, '华北地区', '北京市', '北京市'),
(4, '华北地区', '北京市', '北京市'),
(5, '华北地区', '北京市', '北京市'),
(6, '华南地区', '广东省', '深圳市'),
(7, '华东地区', '浙江省', '杭州市'),
(8, '华北地区', '北京市', '北京市'),
(9, '华东地区', '上海市', '上海市'),
(10, '华北地区', '北京市', '北京市');

-- 添加客户来源数据
INSERT INTO `customer_source` (`customer_id`, `source_channel`, `is_new`, `referrer_id`) VALUES
(1, '线下门店', 0, NULL),
(2, '网站', 0, NULL),
(3, '电话销售', 0, 2),
(4, '网站', 0, NULL),
(5, '微信小程序', 0, NULL),
(6, '合作伙伴', 0, 3),
(7, '电话销售', 0, 2),
(8, '微信小程序', 1, NULL),
(9, '线下门店', 1, NULL),
(10, '网站', 1, NULL);

-- 添加销售目标数据
INSERT INTO `sales_target` (`period_type`, `period_value`, `target_amount`, `user_id`, `product_id`, `region`) VALUES
-- 月度总体目标
('month', '2023-01', 100000.00, NULL, NULL, NULL),
('month', '2023-02', 120000.00, NULL, NULL, NULL),
('month', '2023-03', 110000.00, NULL, NULL, NULL),
('month', '2023-04', 140000.00, NULL, NULL, NULL),
('month', '2023-05', 95000.00, NULL, NULL, NULL),
('month', '2023-06', 220000.00, NULL, NULL, NULL),
('month', '2023-07', 200000.00, NULL, NULL, NULL),
('month', '2023-08', 190000.00, NULL, NULL, NULL),
('month', '2023-09', 200000.00, NULL, NULL, NULL),
('month', '2023-10', 230000.00, NULL, NULL, NULL),
('month', '2023-11', 280000.00, NULL, NULL, NULL),
('month', '2023-12', 320000.00, NULL, NULL, NULL),

-- 季度总体目标
('quarter', '2023-Q1', 330000.00, NULL, NULL, NULL),
('quarter', '2023-Q2', 455000.00, NULL, NULL, NULL),
('quarter', '2023-Q3', 590000.00, NULL, NULL, NULL),
('quarter', '2023-Q4', 830000.00, NULL, NULL, NULL),

-- 年度总体目标
('year', '2023', 2205000.00, NULL, NULL, NULL),

-- 销售人员月度目标
('month', '2023-01', 50000.00, 2, NULL, NULL),
('month', '2023-01', 40000.00, 3, NULL, NULL),
('month', '2023-02', 60000.00, 2, NULL, NULL),
('month', '2023-02', 50000.00, 3, NULL, NULL);

-- 添加销售统计示例数据
INSERT INTO `sales_statistics` (`period_type`, `period_value`, `amount`, `count`, `product_id`, `user_id`, `region`, `channel`, `growth_rate`) VALUES
-- 月度总体销售统计
('month', '2023-01', 120000.00, 42, NULL, NULL, NULL, NULL, 20.00),
('month', '2023-02', 132000.00, 45, NULL, NULL, NULL, NULL, 10.00),
('month', '2023-03', 101000.00, 36, NULL, NULL, NULL, NULL, -8.18),
('month', '2023-04', 134000.00, 48, NULL, NULL, NULL, NULL, -4.29),
('month', '2023-05', 90000.00, 33, NULL, NULL, NULL, NULL, -5.26),
('month', '2023-06', 230000.00, 75, NULL, NULL, NULL, NULL, 4.55),
('month', '2023-07', 210000.00, 64, NULL, NULL, NULL, NULL, 5.00),
('month', '2023-08', 182000.00, 59, NULL, NULL, NULL, NULL, -4.21),
('month', '2023-09', 191000.00, 62, NULL, NULL, NULL, NULL, -4.50),
('month', '2023-10', 234000.00, 73, NULL, NULL, NULL, NULL, 1.74),
('month', '2023-11', 290000.00, 89, NULL, NULL, NULL, NULL, 3.57),
('month', '2023-12', 330000.00, 102, NULL, NULL, NULL, NULL, 3.13),

-- 季度总体销售统计
('quarter', '2023-Q1', 353000.00, 123, NULL, NULL, NULL, NULL, 6.97),
('quarter', '2023-Q2', 454000.00, 156, NULL, NULL, NULL, NULL, -0.22),
('quarter', '2023-Q3', 583000.00, 185, NULL, NULL, NULL, NULL, -1.19),
('quarter', '2023-Q4', 854000.00, 264, NULL, NULL, NULL, NULL, 2.89),

-- 年度总体销售统计
('year', '2023', 2244000.00, 728, NULL, NULL, NULL, NULL, 1.77),

-- 产品月度销售统计（2023年12月）
('month', '2023-12', 112000.00, 8, 1, NULL, NULL, NULL, 12.00),
('month', '2023-12', 64000.00, 8, 2, NULL, NULL, NULL, 6.67),
('month', '2023-12', 36000.00, 3, 3, NULL, NULL, NULL, -10.00),
('month', '2023-12', 45000.00, 15, 4, NULL, NULL, NULL, 15.38),
('month', '2023-12', 40000.00, 2, 5, NULL, NULL, NULL, -11.11),
('month', '2023-12', 33000.00, 1, 6, NULL, NULL, NULL, 10.00),

-- 地区月度销售统计（2023年12月）
('month', '2023-12', 132000.00, 45, NULL, NULL, '华东地区', NULL, 10.00),
('month', '2023-12', 75000.00, 23, NULL, NULL, '华南地区', NULL, 7.14),
('month', '2023-12', 66000.00, 20, NULL, NULL, '华北地区', NULL, -5.71),
('month', '2023-12', 24000.00, 6, NULL, NULL, '华中地区', NULL, 4.35),
('month', '2023-12', 15000.00, 4, NULL, NULL, '西南地区', NULL, 15.38),
('month', '2023-12', 12000.00, 3, NULL, NULL, '西北地区', NULL, -7.69),
('month', '2023-12', 6000.00, 1, NULL, NULL, '东北地区', NULL, 0.00),

-- 渠道月度销售统计（2023年12月）
('month', '2023-12', 75000.00, 25, NULL, NULL, NULL, '线下门店', 7.14),
('month', '2023-12', 66000.00, 21, NULL, NULL, NULL, '电话销售', -4.35),
('month', '2023-12', 89000.00, 30, NULL, NULL, NULL, '网站', 11.25),
('month', '2023-12', 66000.00, 18, NULL, NULL, NULL, '微信小程序', 10.00),
('month', '2023-12', 34000.00, 8, NULL, NULL, NULL, '合作伙伴', -8.11),

-- 销售人员月度销售统计（2023年12月）
('month', '2023-12', 120000.00, 40, NULL, 2, NULL, NULL, 4.35),
('month', '2023-12', 115000.00, 38, NULL, 3, NULL, NULL, 2.68),
('month', '2023-12', 95000.00, 24, NULL, 1, NULL, NULL, -2.06);

-- 创建视图：月度销售统计视图
CREATE OR REPLACE VIEW `monthly_sales_view` AS
SELECT 
  s.period_value AS month,
  s.amount AS actual_amount,
  t.target_amount,
  s.growth_rate,
  s.count AS sales_count
FROM 
  `sales_statistics` s
LEFT JOIN 
  `sales_target` t ON s.period_type = t.period_type AND s.period_value = t.period_value
WHERE 
  s.period_type = 'month'
  AND s.product_id IS NULL
  AND s.user_id IS NULL
  AND s.region IS NULL
  AND s.channel IS NULL
  AND t.product_id IS NULL
  AND t.user_id IS NULL
  AND t.region IS NULL
ORDER BY 
  s.period_value;

-- 创建视图：客户分布视图
CREATE OR REPLACE VIEW `customer_distribution_view` AS
SELECT 
  region,
  COUNT(*) AS customer_count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM `customer_region`), 2) AS percentage
FROM 
  `customer_region`
GROUP BY 
  region
ORDER BY 
  customer_count DESC;

-- 创建视图：产品销售占比视图
CREATE OR REPLACE VIEW `product_sales_percentage_view` AS
SELECT 
  p.name AS product_name,
  s.amount,
  ROUND(s.amount * 100.0 / t.total_amount, 2) AS percentage
FROM 
  `sales_statistics` s
JOIN 
  `product` p ON s.product_id = p.id
JOIN 
  (SELECT period_type, period_value, SUM(amount) AS total_amount 
   FROM `sales_statistics` 
   WHERE product_id IS NULL AND period_type = 'month' 
   GROUP BY period_type, period_value) t 
ON s.period_type = t.period_type AND s.period_value = t.period_value
WHERE 
  s.period_type = 'month'
  AND s.product_id IS NOT NULL
  AND s.user_id IS NULL
  AND s.region IS NULL
  AND s.channel IS NULL
  AND s.period_value = (SELECT MAX(period_value) FROM `sales_statistics` WHERE period_type = 'month')
ORDER BY 
  s.amount DESC;

-- 创建视图：销售渠道分析视图
CREATE OR REPLACE VIEW `sales_channel_view` AS
SELECT 
  channel,
  SUM(CASE WHEN cs.is_new = 1 THEN 1 ELSE 0 END) AS new_customers,
  SUM(CASE WHEN cs.is_new = 0 THEN 1 ELSE 0 END) AS old_customers
FROM 
  `customer_source` cs
GROUP BY 
  channel
ORDER BY 
  channel;

-- 创建视图：销售人员业绩排名视图
CREATE OR REPLACE VIEW `salesperson_performance_view` AS
SELECT 
  u.name AS salesperson_name,
  s.amount,
  s.count AS sales_count
FROM 
  `sales_statistics` s
JOIN 
  `user` u ON s.user_id = u.id
WHERE 
  s.period_type = 'month'
  AND s.product_id IS NULL
  AND s.user_id IS NOT NULL
  AND s.region IS NULL
  AND s.channel IS NULL
  AND s.period_value = (SELECT MAX(period_value) FROM `sales_statistics` WHERE period_type = 'month')
ORDER BY 
  s.amount DESC; 