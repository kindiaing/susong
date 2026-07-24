# Setup 系统安装部署配置手册
适配环境：Windows / Linux CentOS/Ubuntu
技术环境要求：
PHP >= 8.3、MySQL >=8.0、Node >=18、Composer、Nginx

## 1 前置依赖安装
### Windows
1. 安装PHP8.3、MySQL8.0、Node.js
2. 配置环境变量，cmd可直接调用 php / npm
### Linux
apt/yum 安装 php mysql nginx nodejs composer

## 2 一键部署步骤
1. 克隆代码仓库到本地服务器
2. 进入项目根目录，复制配置文件
   cp docs/attach/.env.example .env
3. 修改.env内数据库、端口、密钥配置
4. 执行数据库初始化脚本
   mysql -u账号 -p库名 < docs/attach/init.sql
5. 后端依赖安装
   composer install
   php artisan key:generate
6. 前端打包
   npm install && npm run build
7. 启动服务
   Windows：运行 docs/attach/install.bat
   Linux：chmod +x docs/attach/install.sh && ./docs/attach/install.sh

## 3 核心配置说明
1. 数据库配置：DB_* 开头参数
2. 文件存储：本地/OSS切换配置
3. 定时任务、缓存开关
4. 跨域、前端访问端口配置

## 4 常见故障排查
1. 数据库连接失败：核对.env账号密码、数据库是否创建
2. 端口占用：修改.env服务端口
3. 前端打包报错：清理node_modules重新install
4. 登录500错误：检查APP_KEY是否生成