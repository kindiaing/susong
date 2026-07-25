-- ========================================================
-- 本地速送服务平台（含生鲜配送）数据库初始化脚本
-- 对应文档：docs/03_DB_数据库设计&数据字典.md
-- 数据库：MySQL 8.0
-- 字符集：utf8mb4
-- 排序规则：utf8mb4_unicode_ci
-- 默认数据：角色、超级管理员账号、系统配置
-- 超级管理员：seeding / seeding@ihopeso.cn / 15690631151 / Password
-- 密码使用 bcrypt 加密
-- ========================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `susong` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `susong`;

-- 清除旧表（反向顺序）
DROP TABLE IF EXISTS `wechat_users`;
DROP TABLE IF EXISTS `login_logs`;
DROP TABLE IF EXISTS `audit_logs`;
DROP TABLE IF EXISTS `operation_logs`;
DROP TABLE IF EXISTS `promotions`;
DROP TABLE IF EXISTS `banners`;
DROP TABLE IF EXISTS `system_configs`;
DROP TABLE IF EXISTS `correction_authorizations`;
DROP TABLE IF EXISTS `invoices`;
DROP TABLE IF EXISTS `receivables`;
DROP TABLE IF EXISTS `supplier_settlement_items`;
DROP TABLE IF EXISTS `supplier_settlements`;
DROP TABLE IF EXISTS `recharges`;
DROP TABLE IF EXISTS `merchant_accounts`;
DROP TABLE IF EXISTS `discrepancies`;
DROP TABLE IF EXISTS `temperatures`;
DROP TABLE IF EXISTS `signatures`;
DROP TABLE IF EXISTS `delivery_tracks`;
DROP TABLE IF EXISTS `delivery_task_orders`;
DROP TABLE IF EXISTS `delivery_tasks`;
DROP TABLE IF EXISTS `picking_task_items`;
DROP TABLE IF EXISTS `picking_tasks`;
DROP TABLE IF EXISTS `inventory_logs`;
DROP TABLE IF EXISTS `inventory`;
DROP TABLE IF EXISTS `warehouses`;
DROP TABLE IF EXISTS `repurchase_template_items`;
DROP TABLE IF EXISTS `repurchase_templates`;
DROP TABLE IF EXISTS `frequently_bought`;
DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `cart_items`;
DROP TABLE IF EXISTS `carts`;
DROP TABLE IF EXISTS `purchase_order_items`;
DROP TABLE IF EXISTS `purchase_orders`;
DROP TABLE IF EXISTS `purchase_items`;
DROP TABLE IF EXISTS `keywords`;
DROP TABLE IF EXISTS `product_tags`;
DROP TABLE IF EXISTS `tags`;
DROP TABLE IF EXISTS `merchant_sku_visibility`;
DROP TABLE IF EXISTS `skus`;
DROP TABLE IF EXISTS `product_images`;
DROP TABLE IF EXISTS `products`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `driver_vehicles`;
DROP TABLE IF EXISTS `vehicles`;
DROP TABLE IF EXISTS `drivers`;
DROP TABLE IF EXISTS `merchants`;
DROP TABLE IF EXISTS `delivery_routes`;
DROP TABLE IF EXISTS `suppliers`;
DROP TABLE IF EXISTS `personal_access_tokens`;
DROP TABLE IF EXISTS `password_reset_tokens`;
DROP TABLE IF EXISTS `role_has_permissions`;
DROP TABLE IF EXISTS `model_has_permissions`;
DROP TABLE IF EXISTS `model_has_roles`;
DROP TABLE IF EXISTS `permissions`;
DROP TABLE IF EXISTS `roles`;
DROP TABLE IF EXISTS `users`;

-- ========================================================
-- 1. 用户与权限模块
-- ========================================================

-- 用户表：系统管理员、运营、财务、拣货员、司机等内部账号
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(255) NOT NULL COMMENT 'bcrypt加密密码',
  `name` varchar(50) NOT NULL COMMENT '姓名',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：0禁用，1启用',
  `last_login_at` timestamp NULL DEFAULT NULL COMMENT '最后登录时间',
  `email_verified_at` timestamp NULL DEFAULT NULL COMMENT '邮箱验证时间',
  `remember_token` varchar(100) DEFAULT NULL COMMENT '记住我令牌',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '软删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_phone` (`phone`),
  UNIQUE KEY `uk_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 角色表
CREATE TABLE `roles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(50) NOT NULL COMMENT '角色标识',
  `guard_name` varchar(50) NOT NULL DEFAULT 'web' COMMENT '守卫名称',
  `display_name` varchar(50) NOT NULL COMMENT '角色显示名称',
  `description` varchar(255) DEFAULT NULL COMMENT '描述',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name_guard` (`name`, `guard_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色表';

-- 权限表
CREATE TABLE `permissions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(50) NOT NULL COMMENT '权限标识',
  `guard_name` varchar(50) NOT NULL DEFAULT 'web' COMMENT '守卫名称',
  `display_name` varchar(50) NOT NULL COMMENT '权限显示名称',
  `type` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '类型：1菜单，2按钮，3接口',
  `parent_id` bigint unsigned NOT NULL DEFAULT 0 COMMENT '父级权限ID',
  `route` varchar(100) DEFAULT NULL COMMENT '路由/接口标识',
  `sort` int unsigned NOT NULL DEFAULT 0 COMMENT '排序',
  `icon` varchar(50) DEFAULT NULL COMMENT '菜单图标',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name_guard` (`name`, `guard_name`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='权限表';

-- 用户角色关联表
CREATE TABLE `model_has_roles` (
  `role_id` bigint unsigned NOT NULL COMMENT '角色ID',
  `model_type` varchar(255) NOT NULL COMMENT '模型类型',
  `model_id` bigint unsigned NOT NULL COMMENT '模型ID',
  PRIMARY KEY (`role_id`, `model_id`, `model_type`),
  KEY `idx_model` (`model_id`, `model_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户角色关联表';

-- 用户权限关联表
CREATE TABLE `model_has_permissions` (
  `permission_id` bigint unsigned NOT NULL COMMENT '权限ID',
  `model_type` varchar(255) NOT NULL COMMENT '模型类型',
  `model_id` bigint unsigned NOT NULL COMMENT '模型ID',
  PRIMARY KEY (`permission_id`, `model_id`, `model_type`),
  KEY `idx_model` (`model_id`, `model_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户权限关联表';

-- 角色权限关联表
CREATE TABLE `role_has_permissions` (
  `permission_id` bigint unsigned NOT NULL COMMENT '权限ID',
  `role_id` bigint unsigned NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`permission_id`, `role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色权限关联表';

-- 密码重置令牌
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL COMMENT '邮箱',
  `token` varchar(255) NOT NULL COMMENT '令牌',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='密码重置令牌';

-- Sanctum Token 表
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tokenable_type` varchar(255) NOT NULL COMMENT '模型类型',
  `tokenable_id` bigint unsigned NOT NULL COMMENT '模型ID',
  `name` varchar(255) NOT NULL COMMENT 'Token名称',
  `token` varchar(64) NOT NULL COMMENT 'Token值',
  `abilities` text DEFAULT NULL COMMENT '能力列表',
  `last_used_at` timestamp NULL DEFAULT NULL COMMENT '最后使用时间',
  `expires_at` timestamp NULL DEFAULT NULL COMMENT '过期时间',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_token` (`token`),
  KEY `idx_tokenable` (`tokenable_id`, `tokenable_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Sanctum Token表';

-- 初始化角色
INSERT INTO `roles` (`id`, `name`, `guard_name`, `display_name`, `description`, `created_at`, `updated_at`) VALUES
(1, 'super_admin', 'web', '超级管理员', '全部功能、系统配置、账号管理', NOW(), NOW()),
(2, 'operator', 'web', '运营管理员', '商品、订单、商家、供应商管理', NOW(), NOW()),
(3, 'finance', 'web', '财务人员', '应收、结算、发票、审计', NOW(), NOW()),
(4, 'picker', 'web', '拣货员', '拣货任务、称重改价', NOW(), NOW()),
(5, 'driver', 'web', '配送司机', '配送任务、轨迹、签收', NOW(), NOW()),
(6, 'merchant', 'web', '商家', '小程序商家端', NOW(), NOW());

-- 初始化超级管理员
INSERT INTO `users` (`id`, `username`, `password`, `name`, `phone`, `email`, `status`, `created_at`, `updated_at`) VALUES
(1, 'seeding', '$2y$10$eiqOe/9qaCP3Yi9GY.y4QO5LaEqGvvFZ3JATv0ymb44uSVOeum8ja', '系统管理员', '15690631151', 'seeding@ihopeso.cn', 1, NOW(), NOW());

-- 绑定超级管理员角色
INSERT INTO `model_has_roles` (`role_id`, `model_type`, `model_id`) VALUES
(1, 'App\\Models\\User', 1);

-- ========================================================
-- 2. 组织主体模块
-- ========================================================

-- 供应商表
CREATE TABLE `suppliers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) NOT NULL COMMENT '供应商名称',
  `contact_name` varchar(50) DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `address` varchar(255) DEFAULT NULL COMMENT '地址',
  `bank_name` varchar(100) DEFAULT NULL COMMENT '开户行',
  `bank_account` varchar(50) DEFAULT NULL COMMENT '银行账号',
  `settlement_cycle` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '结算周期：1周结，2月结',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：0禁用，1启用',
  `remark` text DEFAULT NULL COMMENT '备注',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '软删除时间',
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='供应商表';

-- 配送线路表
CREATE TABLE `delivery_routes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(50) NOT NULL COMMENT '线路名称',
  `description` varchar(255) DEFAULT NULL COMMENT '描述',
  `sort` int unsigned NOT NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '软删除时间',
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='配送线路表';

-- 商家表
CREATE TABLE `merchants` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint unsigned DEFAULT NULL COMMENT '关联登录用户ID',
  `name` varchar(100) NOT NULL COMMENT '商家名称',
  `contact_name` varchar(50) DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `address` varchar(255) DEFAULT NULL COMMENT '默认配送地址',
  `delivery_route_id` bigint unsigned DEFAULT NULL COMMENT '所属配送线路ID',
  `delivery_sort` int unsigned NOT NULL DEFAULT 0 COMMENT '配送顺序',
  `min_order_amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '起送价',
  `settlement_type` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '结算方式：1现结，2账期，3预付款',
  `credit_limit` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '信用额度',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：0禁用，1启用',
  `remark` text DEFAULT NULL COMMENT '备注',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '软删除时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_delivery_route_id` (`delivery_route_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商家表';

-- 司机表
CREATE TABLE `drivers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint unsigned DEFAULT NULL COMMENT '关联登录用户ID',
  `name` varchar(50) NOT NULL COMMENT '姓名',
  `phone` varchar(20) NOT NULL COMMENT '手机号',
  `id_card` varchar(18) DEFAULT NULL COMMENT '身份证号',
  `online_status` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '在线状态：0离线，1在线',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：0禁用，1启用',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '软删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='司机表';

-- 车辆表
CREATE TABLE `vehicles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `plate_number` varchar(20) NOT NULL COMMENT '车牌号',
  `vehicle_type` varchar(50) DEFAULT NULL COMMENT '车辆类型',
  `is_cold_chain` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '是否冷链：0否，1是',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：0禁用，1启用',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '软删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_plate_number` (`plate_number`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='车辆表';

-- 司机车辆绑定表
CREATE TABLE `driver_vehicles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `driver_id` bigint unsigned NOT NULL COMMENT '司机ID',
  `vehicle_id` bigint unsigned NOT NULL COMMENT '车辆ID',
  `is_default` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '是否默认车辆：0否，1是',
  `bound_at` timestamp NULL DEFAULT NULL COMMENT '绑定时间',
  `unbound_at` timestamp NULL DEFAULT NULL COMMENT '解绑时间',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_driver_id` (`driver_id`),
  KEY `idx_vehicle_id` (`vehicle_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='司机车辆绑定表';

-- ========================================================
-- 3. 商品管理模块
-- ========================================================

-- 商品分类表
CREATE TABLE `categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `parent_id` bigint unsigned NOT NULL DEFAULT 0 COMMENT '父级分类ID，0为根节点',
  `name` varchar(50) NOT NULL COMMENT '分类名称',
  `icon` varchar(255) DEFAULT NULL COMMENT '图标',
  `sort` int unsigned NOT NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：0禁用，1启用',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '软删除时间',
  PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品分类表';

-- 商品表
CREATE TABLE `products` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `category_id` bigint unsigned NOT NULL COMMENT '分类ID',
  `supplier_id` bigint unsigned DEFAULT NULL COMMENT '默认供应商ID',
  `name` varchar(100) NOT NULL COMMENT '商品名称',
  `cover` varchar(255) DEFAULT NULL COMMENT '封面图',
  `unit` varchar(20) NOT NULL COMMENT '单位：斤/箱/份等',
  `is_weight_priced` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '是否称重改价：0否，1是',
  `stock_warning_value` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '库存预警值',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：0下架，1上架',
  `description` text DEFAULT NULL COMMENT '商品详情',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '软删除时间',
  PRIMARY KEY (`id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_supplier_id` (`supplier_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品表';

-- 商品图片表
CREATE TABLE `product_images` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `product_id` bigint unsigned NOT NULL COMMENT '商品ID',
  `image_url` varchar(255) NOT NULL COMMENT '图片地址',
  `sort` int unsigned NOT NULL DEFAULT 0 COMMENT '排序',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品图片表';

-- SKU规格表
CREATE TABLE `skus` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `product_id` bigint unsigned NOT NULL COMMENT '商品ID',
  `sku_code` varchar(50) NOT NULL COMMENT 'SKU编码',
  `specs` json DEFAULT NULL COMMENT '规格属性',
  `purchase_price` decimal(15, 4) NOT NULL DEFAULT 0.0000 COMMENT '采购参考价',
  `wholesale_price` decimal(15, 4) NOT NULL DEFAULT 0.0000 COMMENT '批发销售价',
  `cost_price` decimal(15, 4) NOT NULL DEFAULT 0.0000 COMMENT '财务成本价',
  `stock` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '当前库存冗余字段',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：0禁用，1启用',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '软删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sku_code` (`sku_code`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SKU规格表';

-- 商家SKU可见性表
CREATE TABLE `merchant_sku_visibility` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `merchant_id` bigint unsigned NOT NULL COMMENT '商家ID',
  `sku_id` bigint unsigned NOT NULL COMMENT 'SKU ID',
  `is_visible` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '是否可见：0否，1是',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_merchant_sku` (`merchant_id`, `sku_id`),
  KEY `idx_sku_id` (`sku_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商家SKU可见性表';

-- 标签词库表
CREATE TABLE `tags` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(50) NOT NULL COMMENT '标签名称',
  `sort` int unsigned NOT NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='标签词库表';

-- 商品标签关联表
CREATE TABLE `product_tags` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `product_id` bigint unsigned NOT NULL COMMENT '商品ID',
  `tag_id` bigint unsigned NOT NULL COMMENT '标签ID',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_product_tag` (`product_id`, `tag_id`),
  KEY `idx_tag_id` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品标签关联表';

-- 搜索关键词表
CREATE TABLE `keywords` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `keyword` varchar(50) NOT NULL COMMENT '关键词',
  `product_id` bigint unsigned DEFAULT NULL COMMENT '关联商品ID',
  `search_count` int unsigned NOT NULL DEFAULT 0 COMMENT '搜索次数',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_keyword` (`keyword`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='搜索关键词表';


-- ========================================================
-- 4. 平台统采模块
-- ========================================================

-- 待采清单表
CREATE TABLE `purchase_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `sku_id` bigint unsigned NOT NULL COMMENT 'SKU ID',
  `quantity` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '待采数量',
  `source_type` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '来源：1订单汇总，2手工添加',
  `source_id` bigint unsigned DEFAULT NULL COMMENT '来源业务ID',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：1待生成采购单，2已生成采购单',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='待采清单表';

-- 采购单表
CREATE TABLE `purchase_orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_no` varchar(50) NOT NULL COMMENT '采购单号',
  `supplier_id` bigint unsigned NOT NULL COMMENT '供应商ID',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：1待接单，2备货中，3已发货，4已入库，5完成，9取消',
  `total_amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '总金额',
  `actual_amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '实际入库金额',
  `remark` text DEFAULT NULL COMMENT '备注',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '软删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_supplier_id` (`supplier_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='采购单表';

-- 采购单明细表
CREATE TABLE `purchase_order_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `purchase_order_id` bigint unsigned NOT NULL COMMENT '采购单ID',
  `sku_id` bigint unsigned NOT NULL COMMENT 'SKU ID',
  `quantity` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '采购数量',
  `price` decimal(15, 4) NOT NULL DEFAULT 0.0000 COMMENT '采购单价',
  `actual_quantity` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '实际入库数量',
  `actual_price` decimal(15, 4) NOT NULL DEFAULT 0.0000 COMMENT '实际入库单价',
  `amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '金额',
  `actual_amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '实际金额',
  `discrepancy_reason` varchar(255) DEFAULT NULL COMMENT '入库差异原因',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_purchase_order_id` (`purchase_order_id`),
  KEY `idx_sku_id` (`sku_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='采购单明细表';

-- ========================================================
-- 5. 客户直采模块
-- ========================================================

-- 购物车表
CREATE TABLE `carts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `merchant_id` bigint unsigned NOT NULL COMMENT '商家ID',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='购物车表';

-- 购物车明细表
CREATE TABLE `cart_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `cart_id` bigint unsigned NOT NULL COMMENT '购物车ID',
  `sku_id` bigint unsigned NOT NULL COMMENT 'SKU ID',
  `quantity` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '数量',
  `price` decimal(15, 4) NOT NULL DEFAULT 0.0000 COMMENT '加入时单价',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_cart_id` (`cart_id`),
  KEY `idx_sku_id` (`sku_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='购物车明细表';

-- 订单表
CREATE TABLE `orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_no` varchar(50) NOT NULL COMMENT '订单号',
  `merchant_id` bigint unsigned NOT NULL COMMENT '商家ID',
  `delivery_route_id` bigint unsigned DEFAULT NULL COMMENT '配送线路ID',
  `batch` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '配送批次：1上午，2下午',
  `delivery_address` varchar(255) DEFAULT NULL COMMENT '配送地址',
  `contact_name` varchar(50) DEFAULT NULL COMMENT '收货联系人',
  `contact_phone` varchar(20) DEFAULT NULL COMMENT '收货电话',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：1待拣货，2拣货中，3配送中，4已签收，5已锁定，9已取消',
  `total_amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '原始订单金额',
  `adjusted_amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '调整后金额',
  `final_amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '最终结算金额',
  `payment_status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '支付状态：1未支付，2已支付，3账期',
  `settlement_type` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '结算方式：1现结，2账期，3预付款',
  `is_locked` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '是否锁定：0否，1是',
  `remark` text DEFAULT NULL COMMENT '备注',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '软删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_status` (`status`),
  KEY `idx_batch` (`batch`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';

-- 订单明细表
CREATE TABLE `order_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id` bigint unsigned NOT NULL COMMENT '订单ID',
  `sku_id` bigint unsigned NOT NULL COMMENT 'SKU ID',
  `product_name` varchar(100) NOT NULL COMMENT '商品名称快照',
  `sku_specs` json DEFAULT NULL COMMENT '规格快照',
  `quantity` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '下单数量',
  `price` decimal(15, 4) NOT NULL DEFAULT 0.0000 COMMENT '下单单价',
  `actual_quantity` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '实际称重数量',
  `actual_price` decimal(15, 4) NOT NULL DEFAULT 0.0000 COMMENT '实际称重单价',
  `subtotal` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '小计金额',
  `actual_subtotal` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '实际小计金额',
  `discrepancy_amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '差异金额',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：1正常，2待审核，3已调整',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_sku_id` (`sku_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单明细表';

-- 常购清单表
CREATE TABLE `frequently_bought` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `merchant_id` bigint unsigned NOT NULL COMMENT '商家ID',
  `sku_id` bigint unsigned NOT NULL COMMENT 'SKU ID',
  `buy_count` int unsigned NOT NULL DEFAULT 0 COMMENT '购买次数',
  `last_buy_at` timestamp NULL DEFAULT NULL COMMENT '最近购买时间',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_merchant_sku` (`merchant_id`, `sku_id`),
  KEY `idx_sku_id` (`sku_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='常购清单表';

-- 复购模板表
CREATE TABLE `repurchase_templates` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `merchant_id` bigint unsigned NOT NULL COMMENT '商家ID',
  `name` varchar(50) NOT NULL COMMENT '模板名称',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='复购模板表';

-- 复购模板明细表
CREATE TABLE `repurchase_template_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `template_id` bigint unsigned NOT NULL COMMENT '模板ID',
  `sku_id` bigint unsigned NOT NULL COMMENT 'SKU ID',
  `quantity` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '数量',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_template_id` (`template_id`),
  KEY `idx_sku_id` (`sku_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='复购模板明细表';

-- ========================================================
-- 6. 库存管理模块
-- ========================================================

-- 仓库表
CREATE TABLE `warehouses` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(50) NOT NULL COMMENT '仓库名称',
  `type` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '类型：1总仓，2前置仓',
  `is_cold_chain` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '是否冷链：0否，1是',
  `address` varchar(255) DEFAULT NULL COMMENT '地址',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '软删除时间',
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='仓库表';

-- 实时库存表
CREATE TABLE `inventory` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `warehouse_id` bigint unsigned NOT NULL COMMENT '仓库ID',
  `sku_id` bigint unsigned NOT NULL COMMENT 'SKU ID',
  `total_stock` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '总库存',
  `locked_stock` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '锁定库存',
  `available_stock` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '可用库存',
  `batch_no` varchar(50) DEFAULT NULL COMMENT '入库批次号',
  `expiry_date` date DEFAULT NULL COMMENT '效期',
  `warning_value` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '预警值',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_warehouse_sku_batch` (`warehouse_id`, `sku_id`, `batch_no`),
  KEY `idx_sku_id` (`sku_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='实时库存表';

-- 库存变动日志表
CREATE TABLE `inventory_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `warehouse_id` bigint unsigned NOT NULL COMMENT '仓库ID',
  `sku_id` bigint unsigned NOT NULL COMMENT 'SKU ID',
  `type` tinyint unsigned NOT NULL COMMENT '变动类型：1入库，2出库，3调拨，4报损，5报溢，6调整',
  `quantity` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '变动数量，正增负减',
  `before_stock` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '变动前库存',
  `after_stock` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '变动后库存',
  `reason` varchar(255) DEFAULT NULL COMMENT '变动原因',
  `operator_id` bigint unsigned DEFAULT NULL COMMENT '操作人ID',
  `source_type` varchar(50) DEFAULT NULL COMMENT '业务来源类型',
  `source_id` bigint unsigned DEFAULT NULL COMMENT '业务来源ID',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_warehouse_id` (`warehouse_id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_type` (`type`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='库存变动日志表';

-- ========================================================
-- 7. 拣货管理模块
-- ========================================================

-- 拣货任务表
CREATE TABLE `picking_tasks` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `task_no` varchar(50) NOT NULL COMMENT '任务编号',
  `warehouse_id` bigint unsigned NOT NULL COMMENT '仓库ID',
  `picker_id` bigint unsigned DEFAULT NULL COMMENT '拣货员ID',
  `batch` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '配送批次：1上午，2下午',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：1待分配，2拣货中，3已完成',
  `started_at` timestamp NULL DEFAULT NULL COMMENT '开始时间',
  `completed_at` timestamp NULL DEFAULT NULL COMMENT '完成时间',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_task_no` (`task_no`),
  KEY `idx_warehouse_id` (`warehouse_id`),
  KEY `idx_picker_id` (`picker_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='拣货任务表';

-- 拣货任务明细表
CREATE TABLE `picking_task_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `picking_task_id` bigint unsigned NOT NULL COMMENT '拣货任务ID',
  `order_id` bigint unsigned NOT NULL COMMENT '订单ID',
  `order_item_id` bigint unsigned NOT NULL COMMENT '订单明细ID',
  `sku_id` bigint unsigned NOT NULL COMMENT 'SKU ID',
  `required_quantity` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '需求数量',
  `picked_quantity` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '实际拣货数量',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：1待拣货，2已拣货，3差异',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_picking_task_id` (`picking_task_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_sku_id` (`sku_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='拣货任务明细表';

-- ========================================================
-- 8. 物流配送模块
-- ========================================================

-- 配送任务表
CREATE TABLE `delivery_tasks` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `task_no` varchar(50) NOT NULL COMMENT '任务编号',
  `delivery_route_id` bigint unsigned NOT NULL COMMENT '线路ID',
  `driver_id` bigint unsigned DEFAULT NULL COMMENT '司机ID',
  `vehicle_id` bigint unsigned DEFAULT NULL COMMENT '车辆ID',
  `batch` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '配送批次：1上午，2下午',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：1待配送，2配送中，3任务完成',
  `planned_at` timestamp NULL DEFAULT NULL COMMENT '计划配送时间',
  `started_at` timestamp NULL DEFAULT NULL COMMENT '开始时间',
  `completed_at` timestamp NULL DEFAULT NULL COMMENT '完成时间',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_task_no` (`task_no`),
  KEY `idx_route_id` (`delivery_route_id`),
  KEY `idx_driver_id` (`driver_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='配送任务表';

-- 配送任务订单关联表
CREATE TABLE `delivery_task_orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `delivery_task_id` bigint unsigned NOT NULL COMMENT '配送任务ID',
  `order_id` bigint unsigned NOT NULL COMMENT '订单ID',
  `delivery_sort` int unsigned NOT NULL DEFAULT 0 COMMENT '配送顺序',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：1待配送，2已送达',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_delivery_task_id` (`delivery_task_id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='配送任务订单关联表';

-- 配送轨迹表
CREATE TABLE `delivery_tracks` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `delivery_task_id` bigint unsigned NOT NULL COMMENT '配送任务ID',
  `driver_id` bigint unsigned NOT NULL COMMENT '司机ID',
  `latitude` decimal(10, 7) NOT NULL DEFAULT 0.0000000 COMMENT '纬度',
  `longitude` decimal(10, 7) NOT NULL DEFAULT 0.0000000 COMMENT '经度',
  `location_desc` varchar(255) DEFAULT NULL COMMENT '位置描述',
  `reported_at` timestamp NULL DEFAULT NULL COMMENT '上报时间',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_delivery_task_id` (`delivery_task_id`),
  KEY `idx_driver_id` (`driver_id`),
  KEY `idx_reported_at` (`reported_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='配送轨迹表';

-- 签收存证表
CREATE TABLE `signatures` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id` bigint unsigned NOT NULL COMMENT '订单ID',
  `delivery_task_id` bigint unsigned NOT NULL COMMENT '配送任务ID',
  `type` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '类型：1拍照签收，2电子签名，3质检照片',
  `image_url` varchar(255) DEFAULT NULL COMMENT '图片/签名文件地址',
  `signer_name` varchar(50) DEFAULT NULL COMMENT '签收人',
  `signed_at` timestamp NULL DEFAULT NULL COMMENT '签收时间',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_delivery_task_id` (`delivery_task_id`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='签收存证表';

-- 冷链温度记录表
CREATE TABLE `temperatures` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `delivery_task_id` bigint unsigned NOT NULL COMMENT '配送任务ID',
  `temperature` decimal(5, 2) NOT NULL DEFAULT 0.00 COMMENT '温度值',
  `recorded_at` timestamp NULL DEFAULT NULL COMMENT '记录时间',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_delivery_task_id` (`delivery_task_id`),
  KEY `idx_recorded_at` (`recorded_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='冷链温度记录表';


-- ========================================================
-- 9. 差异处理模块
-- ========================================================

-- 差异单表
CREATE TABLE `discrepancies` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `discrepancy_no` varchar(50) NOT NULL COMMENT '差异单号',
  `order_id` bigint unsigned NOT NULL COMMENT '关联订单ID',
  `order_item_id` bigint unsigned DEFAULT NULL COMMENT '关联订单明细ID',
  `stage` tinyint unsigned NOT NULL COMMENT '差异环节：1拣货，2配送，3实收',
  `type` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '差异类型：1少收，2拒收，3残次，4其他',
  `expected_quantity` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '预期数量',
  `actual_quantity` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '实际数量',
  `quantity_diff` decimal(15, 3) NOT NULL DEFAULT 0.000 COMMENT '数量差异',
  `amount_diff` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '金额差异',
  `reason` varchar(255) DEFAULT NULL COMMENT '差异原因',
  `evidence_urls` json DEFAULT NULL COMMENT '凭证图片数组',
  `responsible_party` tinyint unsigned DEFAULT NULL COMMENT '责任方：1供应商，2平台，3司机，4商家',
  `decision` tinyint unsigned DEFAULT NULL COMMENT '处理决策：1补货，2退款，3扣款，4报损，5不计',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：1待处理，2处理中，3已处理，4已关闭',
  `handler_id` bigint unsigned DEFAULT NULL COMMENT '处理人ID',
  `handled_at` timestamp NULL DEFAULT NULL COMMENT '处理时间',
  `is_amount_adjusted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '是否已调整金额',
  `remark` text DEFAULT NULL COMMENT '备注',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '软删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_discrepancy_no` (`discrepancy_no`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_order_item_id` (`order_item_id`),
  KEY `idx_stage` (`stage`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='差异单表';

-- ========================================================
-- 10. 财务对账模块
-- ========================================================

-- 商家账户表
CREATE TABLE `merchant_accounts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `merchant_id` bigint unsigned NOT NULL COMMENT '商家ID',
  `balance` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '账户余额',
  `total_recharge` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '总充值',
  `total_consumption` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '总消费',
  `credit_limit` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '信用额度',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商家账户表';

-- 充值记录表
CREATE TABLE `recharges` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `merchant_id` bigint unsigned NOT NULL COMMENT '商家ID',
  `amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '充值金额',
  `payment_method` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '支付方式：1微信支付，2线下转账，3后台手工',
  `transaction_no` varchar(100) DEFAULT NULL COMMENT '第三方交易号',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：1待确认，2成功，3失败',
  `operator_id` bigint unsigned DEFAULT NULL COMMENT '操作人ID',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_transaction_no` (`transaction_no`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='充值记录表';

-- 供应商结算单表
CREATE TABLE `supplier_settlements` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `settlement_no` varchar(50) NOT NULL COMMENT '结算单号',
  `supplier_id` bigint unsigned NOT NULL COMMENT '供应商ID',
  `start_date` date NOT NULL COMMENT '结算周期开始',
  `end_date` date NOT NULL COMMENT '结算周期结束',
  `total_amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '汇总金额',
  `service_fee` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '服务费',
  `payable_amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '应付金额',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：1待结算，2已结算',
  `settled_at` timestamp NULL DEFAULT NULL COMMENT '结算时间',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_settlement_no` (`settlement_no`),
  KEY `idx_supplier_id` (`supplier_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='供应商结算单表';

-- 结算单明细表
CREATE TABLE `supplier_settlement_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `supplier_settlement_id` bigint unsigned NOT NULL COMMENT '结算单ID',
  `purchase_order_id` bigint unsigned NOT NULL COMMENT '采购单ID',
  `amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '金额',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_supplier_settlement_id` (`supplier_settlement_id`),
  KEY `idx_purchase_order_id` (`purchase_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='结算单明细表';

-- 应收账款表
CREATE TABLE `receivables` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `receivable_no` varchar(50) NOT NULL COMMENT '应收单号',
  `order_id` bigint unsigned NOT NULL COMMENT '订单ID',
  `merchant_id` bigint unsigned NOT NULL COMMENT '商家ID',
  `original_amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '原始金额',
  `adjusted_amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '调整后金额',
  `discrepancy_amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '差异金额',
  `paid_amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '已付金额',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：1未结算，2已结算，3争议中',
  `settlement_type` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '结算方式：1现结，2账期，3预付款',
  `due_date` date DEFAULT NULL COMMENT '到期日',
  `settled_at` timestamp NULL DEFAULT NULL COMMENT '结算时间',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_receivable_no` (`receivable_no`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='应收账款表';

-- 发票表
CREATE TABLE `invoices` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `invoice_no` varchar(50) DEFAULT NULL COMMENT '发票号',
  `type` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '类型：1客户发票，2供应商发票',
  `target_id` bigint unsigned NOT NULL COMMENT '关联对象ID',
  `title` varchar(100) DEFAULT NULL COMMENT '发票抬头',
  `amount` decimal(15, 2) NOT NULL DEFAULT 0.00 COMMENT '金额',
  `file_url` varchar(255) DEFAULT NULL COMMENT '发票文件地址',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：1待开具，2已开具，3已寄出',
  `applied_at` timestamp NULL DEFAULT NULL COMMENT '申请时间',
  `issued_at` timestamp NULL DEFAULT NULL COMMENT '开具时间',
  `sent_at` timestamp NULL DEFAULT NULL COMMENT '寄出时间',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_target_id` (`target_id`),
  KEY `idx_type` (`type`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='发票表';

-- 单据授权更正表
CREATE TABLE `correction_authorizations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id` bigint unsigned NOT NULL COMMENT '订单ID',
  `operator_id` bigint unsigned NOT NULL COMMENT '授权人ID',
  `reason` varchar(255) NOT NULL COMMENT '更正原因',
  `before_data` json DEFAULT NULL COMMENT '修改前数据',
  `after_data` json DEFAULT NULL COMMENT '修改后数据',
  `authorized_at` timestamp NULL DEFAULT NULL COMMENT '授权时间',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_operator_id` (`operator_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='单据授权更正表';

-- ========================================================
-- 11. 系统支撑模块
-- ========================================================

-- 系统配置表
CREATE TABLE `system_configs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `config_key` varchar(100) NOT NULL COMMENT '配置键',
  `config_value` text DEFAULT NULL COMMENT '配置值',
  `description` varchar(255) DEFAULT NULL COMMENT '说明',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

-- 轮播广告表
CREATE TABLE `banners` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` varchar(100) NOT NULL COMMENT '标题',
  `image_url` varchar(255) NOT NULL COMMENT '图片地址',
  `link_url` varchar(255) DEFAULT NULL COMMENT '跳转链接',
  `sort` int unsigned NOT NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态：0禁用，1启用',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '软删除时间',
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_sort` (`sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='轮播广告表';

-- 运营主推表
CREATE TABLE `promotions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `type` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '类型：1主推商品，2主推品类',
  `target_id` bigint unsigned NOT NULL COMMENT '目标ID',
  `sort` int unsigned NOT NULL DEFAULT 0 COMMENT '排序',
  `start_at` timestamp NULL DEFAULT NULL COMMENT '开始时间',
  `end_at` timestamp NULL DEFAULT NULL COMMENT '结束时间',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_type` (`type`),
  KEY `idx_target_id` (`target_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='运营主推表';

-- 操作日志表
CREATE TABLE `operation_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint unsigned DEFAULT NULL COMMENT '操作人ID',
  `username` varchar(50) DEFAULT NULL COMMENT '操作人用户名',
  `method` varchar(10) DEFAULT NULL COMMENT '请求方法',
  `path` varchar(255) DEFAULT NULL COMMENT '请求路径',
  `ip` varchar(50) DEFAULT NULL COMMENT 'IP地址',
  `content` text DEFAULT NULL COMMENT '操作内容',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';

-- 审计日志表
CREATE TABLE `audit_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `model_type` varchar(100) NOT NULL COMMENT '模型类型',
  `model_id` bigint unsigned NOT NULL COMMENT '模型ID',
  `action` varchar(50) NOT NULL COMMENT '操作动作',
  `before_data` json DEFAULT NULL COMMENT '修改前数据',
  `after_data` json DEFAULT NULL COMMENT '修改后数据',
  `operator_id` bigint unsigned DEFAULT NULL COMMENT '操作人ID',
  `ip` varchar(50) DEFAULT NULL COMMENT '操作人IP地址',
  `user_agent` varchar(255) DEFAULT NULL COMMENT '浏览器/客户端UA',
  `reason` varchar(255) DEFAULT NULL COMMENT '操作原因',
  `relation_type` varchar(50) DEFAULT NULL COMMENT '关联类型',
  `relation_id` bigint unsigned DEFAULT NULL COMMENT '关联ID',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_model` (`model_type`, `model_id`),
  KEY `idx_operator_id` (`operator_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='审计日志表';

-- 登录日志表
CREATE TABLE `login_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint unsigned DEFAULT NULL COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '登录账号',
  `ip` varchar(50) DEFAULT NULL COMMENT 'IP地址',
  `user_agent` varchar(255) DEFAULT NULL COMMENT '浏览器/客户端UA',
  `login_type` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '类型：1管理后台，2商家小程序，3司机小程序',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '结果：1成功，0失败',
  `fail_reason` varchar(100) DEFAULT NULL COMMENT '失败原因（账号不存在/密码错误/账号禁用）',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '登录时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_username` (`username`),
  KEY `idx_ip` (`ip`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='登录日志表';

-- 默认系统配置
INSERT INTO `system_configs` (`config_key`, `config_value`, `description`, `created_at`, `updated_at`) VALUES
('site_name', '本地速送服务平台', '站点名称', NOW(), NOW()),
('contact_phone', '15690631151', '客服电话', NOW(), NOW()),
('default_delivery_batch', '1', '默认配送批次：1上午，2下午', NOW(), NOW()),
('weighing_diff_threshold', '20', '称重差异阈值（百分比）', NOW(), NOW()),
('audit_retention_days', '90', '审计/日志保留天数：0=永久保留，1-180天，到期每日定时清理', NOW(), NOW());

-- ========================================================
-- 12. 微信模块
-- ========================================================

-- 微信用户绑定表
CREATE TABLE `wechat_users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint unsigned DEFAULT NULL COMMENT '关联系统用户ID',
  `openid` varchar(100) NOT NULL COMMENT '微信OpenID',
  `unionid` varchar(100) DEFAULT NULL COMMENT '微信UnionID',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `type` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '类型：1商家端，2司机端',
  `status` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '状态',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_openid` (`openid`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='微信用户绑定表';

SET FOREIGN_KEY_CHECKS = 1;

-- 初始化完成
-- 默认管理员账号：seeding / Password
-- 邮箱：seeding@ihopeso.cn
-- 手机：15690631151
-- 生产环境请立即修改默认密码
