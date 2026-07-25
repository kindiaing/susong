# 功能验收测试用例

对应 PRD / FSD 版本：V1.0

---

## 1 审计模块

| 用例编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
| :--- | :--- | :--- | :--- | :--- |
| TC-A01 | 登录成功审计 | 已有有效账号 | 管理后台输入正确账号密码登录 | login_logs 新增 1 条：username、IP、UA、login_type=1、status=1 |
| TC-A02 | 登录失败审计 | 账号存在但密码错误 | 输入错误密码登录 | login_logs 记录 status=0，fail_reason=密码错误，含 IP |
| TC-A03 | 小程序登录审计 | 商家已绑定微信 | 商家小程序微信登录 | login_logs 记录 login_type=2，含用户标识 |
| TC-A04 | 敏感操作审计-删除 | 管理员登录 | 删除一个商品（二次确认后） | audit_logs 记录 action=delete，含修改前数据 JSON、操作人、IP |
| TC-A05 | 敏感操作审计-授权更正 | 财务角色登录 | 对已签收订单执行授权更正 | audit_logs 记录 action=correction，前后数据完整、含 IP 与原因 |
| TC-A06 | 配置修改审计 | 超管登录 | 系统配置管理修改任意配置值 | audit_logs 记录配置键、修改前后值、操作人、IP |
| TC-A07 | 审计列表筛选 | 已有审计数据 | 按模型类型/操作动作/时间组合筛选 | 列表正确过滤，详情展示前后数据 JSON |
| TC-A08 | 保留天数生效 | audit_retention_days=30，存在 31 天前日志 | 执行 `php artisan audit:cleanup` | 31 天前的 login_logs/audit_logs/operation_logs 被删除，30 天内保留 |
| TC-A09 | 永久保留 | audit_retention_days=0 | 执行 `php artisan audit:cleanup` | 命令跳过，不删除任何数据 |
| TC-A10 | 保留天数边界 | 超管登录 | 审计设置分别输入 -1、0、180、181 | -1 与 181 校验拒绝；0 与 180 保存成功 |
| TC-A11 | 审计数据保护 | 超管登录 | 尝试在界面上删除/编辑审计记录 | 无删除/编辑入口；直接调 API 返回 403 |
| TC-A12 | 系统配置管理菜单 | 超管 / 非超管分别登录 | 查看侧边菜单 | 超管可见「系统配置管理」独立一级菜单（基础配置/审计设置/界面设置/变更记录）；非超管不可见 |

## 2 数据库迁移

| 用例编号 | 场景 | 操作步骤 | 预期结果 |
| :--- | :--- | :--- | :--- |
| TC-M01 | 顺序迁移 | 按 03_DB 7.0 节顺序逐个模块执行 `php artisan migrate` | 12 个模块全部执行成功，无报错 |
| TC-M02 | 回滚 | 执行 `php artisan migrate:rollback` | 最近一个模块的表按 down() 反向删除成功 |
| TC-M03 | 清库重建 | `php artisan migrate:fresh --seed` 或导入 `init.sql` | 全表重建成功；默认数据齐全（角色、超管、系统配置含 audit_retention_days=90） |
| TC-M04 | init.sql 重入 | 重复执行 init.sql | DROP IF EXISTS 生效，无表已存在报错 |
