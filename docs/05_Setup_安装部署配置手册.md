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
## 5 Redis 配置与使用场景

Redis 在本项目中承担 5 个角色：缓存、队列、会话、分布式锁、限流。

### 5.1 .env 配置

```dotenv
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
REDIS_DB=0
REDIS_CACHE_DB=1

CACHE_STORE=redis        # 应用缓存
QUEUE_CONNECTION=redis   # 异步队列
SESSION_DRIVER=redis     # 会话 / 登录态
```

### 5.2 使用场景（匹配功能）

| 场景 | 匹配功能 |
| :--- | :--- |
| 缓存 | 商品列表、系统配置、字典数据、首页统计 |
| 队列 | 订单通知推送、Excel 报表导出、对账/结算批处理 |
| 会话 | 管理后台登录态（Session 共享） |
| 分布式锁 | 库存扣减防超卖、防止重复提交结算 |
| 限流 | API 频率限制（登录接口、下单接口） |

### 5.3 队列启动

```bash
php artisan queue:work redis --queue=default,exports --tries=3
# Windows 可用 install.bat 内置守护；Linux 建议 supervisor 常驻
```

## 6 管理后台主题配置（shadcn/ui）

管理后台基于 shadcn/ui 的 **CSS 变量 + 主题 token**：组件内部只引用 `hsl(var(--xxx))` 与 Tailwind token，改 CSS 变量即可全局换肤。本项目主题基调：**小圆角、小字体、小按钮**，信息密度优先；全局轻提醒使用 Sonner，通知中心使用右侧 Drawer。

### 6.1 CSS 变量（resources/css/app.css 或 globals.css）

```css
@layer base {
  :root {
    /* 基础颜色 token（HSL 三段式，不含 hsl()） */
    --background: 0 0% 100%;
    --foreground: 222 47% 11%;
    --card: 0 0% 100%;
    --card-foreground: 222 47% 11%;
    --popover: 0 0% 100%;
    --popover-foreground: 222 47% 11%;
    --primary: 221 83% 53%;            /* 主色：蓝 */
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96%;
    --secondary-foreground: 222 47% 11%;
    --muted: 210 40% 96%;
    --muted-foreground: 215 16% 47%;
    --accent: 210 40% 96%;
    --accent-foreground: 222 47% 11%;
    --destructive: 0 84% 60%;          /* 错误/删除：红 */
    --destructive-foreground: 210 40% 98%;
    --warning: 38 92% 50%;              /* 警告：橙黄 */
    --warning-foreground: 0 0% 100%;
    --success: 142 71% 45%;             /* 成功：绿 */
    --success-foreground: 0 0% 100%;
    --info: 199 89% 48%;                /* 信息：青蓝 */
    --info-foreground: 0 0% 100%;
    --border: 214 32% 91%;
    --input: 214 32% 91%;
    --ring: 221 83% 53%;

    /* 圆角尺度：单变量驱动全局小圆角，可直接修改 */
    --radius: 0.25rem;                  /* 4px，卡片/按钮/输入框/弹窗/Drawer 统一 */
  }

  .dark {
    --background: 222 47% 11%;
    --foreground: 210 40% 98%;
    --card: 222 47% 14%;
    --card-foreground: 210 40% 98%;
    --popover: 222 47% 14%;
    --popover-foreground: 210 40% 98%;
    --primary: 217 91% 60%;
    --primary-foreground: 222 47% 11%;
    --secondary: 217 33% 17%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217 33% 17%;
    --muted-foreground: 215 20% 65%;
    --accent: 217 33% 17%;
    --accent-foreground: 210 40% 98%;
    --destructive: 0 63% 31%;
    --destructive-foreground: 210 40% 98%;
    --warning: 38 92% 50%;
    --warning-foreground: 0 0% 100%;
    --success: 142 71% 45%;
    --success-foreground: 0 0% 100%;
    --info: 199 89% 48%;
    --info-foreground: 0 0% 100%;
    --border: 217 33% 17%;
    --input: 217 33% 17%;
    --ring: 224 76% 48%;
    --radius: 0.25rem;
  }

  html {
    font-size: 13px;                   /* 小字体：基准字号 */
  }
  body {
    @apply bg-background text-foreground;
    font-size: 13px;
    line-height: 1.5;
  }
}
```

### 6.2 Tailwind token 映射（tailwind.config.ts）

```ts
export default {
  theme: {
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        warning: {
          DEFAULT: "hsl(var(--warning))",
          foreground: "hsl(var(--warning-foreground))",
        },
        success: {
          DEFAULT: "hsl(var(--success))",
          foreground: "hsl(var(--success-foreground))",
        },
        info: {
          DEFAULT: "hsl(var(--info))",
          foreground: "hsl(var(--info-foreground))",
        },
      },
      borderRadius: {
        /* 圆角尺度直接由 --radius 变量派生，修改 --radius 即可全局生效 */
        lg: "var(--radius)",                       // 4px（卡片/Drawer/弹窗）
        md: "calc(var(--radius) - 1px)",           // 3px（按钮/输入框）
        sm: "calc(var(--radius) - 2px)",           // 2px（标签/小徽章）
      },
      fontSize: {
        xs:   ["12px", { lineHeight: "16px" }],  // 辅助文字 / 表格
        sm:   ["13px", { lineHeight: "20px" }],  // 正文基准
        base: ["14px", { lineHeight: "20px" }],  // 强调正文
        lg:   ["16px", { lineHeight: "24px" }],  // 区块标题
        xl:   ["18px", { lineHeight: "26px" }],  // 页面标题
      },
    },
  },
}
```

### 6.3 反馈与通知组件约定

1. **轻提醒（Toast）**：全局统一使用 Sonner 组件
   - 安装：`npx shadcn add sonner`
   - 在根布局中引入 `<Toaster />`
   - 调用方式：`toast.success('保存成功')` / `toast.error('保存失败')` / `toast.warning('请确认')` / `toast.info('提示信息')`
   - 风格与主题色一致，小圆角、小字体，位置默认右下角
2. **通知中心（站内消息）**：统一使用右侧 Drawer（Sheet）组件
   - 入口位于顶部导航栏消息图标
   - 宽度 360px，小圆角，从右侧滑出
   - 展示未读/已读通知列表，支持一键已读/清空
3. **二次确认**：删除、结算、授权更正等敏感操作仍使用 `AlertDialog` 弹窗确认

### 6.4 使用约定

1. 组件内只写 token 类名（`bg-primary`、`rounded-md`、`text-sm`、`h-8` 等），禁止写死色值与 px 圆角
2. 表格、标签、辅助信息统一 `text-xs`（12px）；正文 `text-sm`（13px）
3. 按钮默认小尺寸：`size="sm"` 或等效 `h-8 px-3 text-sm`，与表格/表单紧凑布局匹配
4. 图标配色按 FSD 7.2 约定使用蓝 / 橙 / 黄 / 绿 / 红语义色，避免页面单调
5. 修改基础颜色或圆角尺度只需编辑 CSS 变量，组件代码零改动
6. 新增主题（如暗色）只需在 `.dark` 下覆盖变量，无需修改 Tailwind token

### 6.5 尺寸档位配置（字体 / 图标：S · M · L，系统默认 M）

管理后台支持 S / M / L 三种界面尺寸档位，**系统默认 M 档**（正文 14px · 图标 16px · 按钮 32px）。实现原理：所有尺寸一律走 CSS 变量；`.env` 中的 `VITE_UI_SIZE` 决定全站默认档位，**改一处配置即可同步修改系统所有字体、图标与按钮尺寸**。

#### 6.5.1 .env 配置

```dotenv
# UI 尺寸规格：S=小 M=中（默认） L=大
# 控制管理后台字体、图标、按钮全局尺寸
VITE_UI_SIZE=M
```

前端入口读取并设置（Vite 环境变量构建期注入）：

```tsx
// main.tsx / App.tsx 启动时执行
document.documentElement.dataset.size =
  (import.meta.env.VITE_UI_SIZE ?? "M").toLowerCase(); // s | m | l
```

> 修改 `.env` 后需重启 `npm run dev`（或重新 build）生效；用户个人档位（如有）优先级高于系统默认，存 localStorage 或用户偏好表。

#### 6.5.2 尺寸 token 表（S / M / L）

| token | S（紧凑） | M（默认） | L（舒适） | 用途 |
| :--- | :--- | :--- | :--- | :--- |
| --font-base | 13px | 14px | 16px | 正文 / 按钮文字 |
| --font-xs | 12px | 13px | 14px | 表格 / 辅助文字 / badge |
| --font-title | 15px | 16px | 18px | 区块标题 |
| --font-h1 | 18px | 19px | 22px | 页面标题 |
| --font-stat | 20px | 22px | 26px | 统计数字 |
| --icon | 14px | 16px | 18px | 常规图标 |
| --icon-sm | 12px | 13px | 15px | 小按钮图标 |
| --icon-alert | 16px | 18px | 20px | Alert 图标 |
| --btn-h | 30px | 32px | 36px | 按钮高度 |
| --btn-h-xs | 24px | 26px | 30px | 列表操作按钮高度 |
| --control | 14px | 15px | 17px | radio / checkbox |
| --cell-py | 8px | 9px | 12px | 表格单元格纵向 padding |

> 说明：`--radius` 不属于尺寸档位，全局固定 0.25rem（小圆角主题基调）。

#### 6.5.3 CSS 实现（globals.css 追加）

```css
/* 默认 M 档 */
:root, :root[data-size="m"] {
  --font-base: 14px; --font-xs: 13px; --font-title: 16px;
  --icon: 16px; --icon-sm: 13px; --btn-h: 32px; --btn-h-xs: 26px;
  --control: 15px; --cell-py: 9px;
}
:root[data-size="s"] {
  --font-base: 13px; --font-xs: 12px; --font-title: 15px;
  --icon: 14px; --icon-sm: 12px; --btn-h: 30px; --btn-h-xs: 24px;
  --control: 14px; --cell-py: 8px;
}
:root[data-size="l"] {
  --font-base: 16px; --font-xs: 14px; --font-title: 18px;
  --icon: 18px; --icon-sm: 15px; --btn-h: 36px; --btn-h-xs: 30px;
  --control: 17px; --cell-py: 12px;
}
```

#### 6.5.4 组件化开发约定（优先复用，禁止重复造样式）

系统**优先采用组件化开发**：按钮、图标、Block、Badge、Alert、表格统一封装为全局组件，业务页面只组装复用，尺寸全部由组件内部读取 token，`.env` 切换档位时全站自动同步：

| 全局组件 | 封装内容 | 尺寸来源 |
| :--- | :--- | :--- |
| AppButton | 语义色变体（primary/success/warning/danger/secondary）+ 彩色图标位 | var(--btn-h) / var(--btn-h-xs) |
| AppIcon | lucide 图标统一出口，语义色（蓝/橙/黄/绿/红） | var(--icon) / var(--icon-sm) |
| StatBlock | 左边框统计 / 通知块（蓝/绿/橙/红/紫） | var(--font-stat) |
| StatusBadge | 订单状态、冷链/常温 tag | var(--font-xs) |
| AppAlert | 信息 / 成功 / 警告 / 危险提示条 | var(--icon-alert) |
| AppTable | 列表页（行 hover 浅蓝背景、彩色操作按钮列） | var(--cell-py) |

```tsx
// 业务页面只允许这样组装，不允许复制样式：
<AppButton variant="primary" icon="plus">新增订单</AppButton>
<StatBlock color="blue" label="今日订单" value={128} trend="+12.5%" />
<StatusBadge status="pending_pick" />
<AppAlert type="warning" title="库存预警" desc="冷鲜鸡腿 500g 库存低于安全阈值" />
```

约束：

1. 组件尺寸一律引用 token（`h-[var(--btn-h)]`、`size-[var(--icon)]`），禁止写死 px，否则该组件不随档位缩放
2. 业务页面禁止从示例页复制样式，只能引用全局组件
3. lucide-react 图标必须经 `AppIcon` 统一出口，size 默认 `var(--icon)`

#### 6.5.5 用户切换（可选，个人设置页）

```tsx
// 切换档位：改一个属性即可，全站生效
function setSize(size: "s" | "m" | "l") {
  document.documentElement.dataset.size = size;
  localStorage.setItem("ui-size", size);
}

// 应用启动时：用户偏好优先，否则取 .env 系统默认
useEffect(() => {
  document.documentElement.dataset.size =
    localStorage.getItem("ui-size") ??
    (import.meta.env.VITE_UI_SIZE ?? "M").toLowerCase();
}, []);
```

#### 6.5.6 可行性与示例

1. **完全可行**：shadcn/ui 组件样式本就由 CSS 变量驱动，尺寸变量是同一机制的延伸，无额外依赖
2. **前提约束**：组件尺寸引用 token、禁止写死 px（见 6.5.4）
3. **规范自包含**：颜色与尺寸的全部权威数值以本手册 6.1–6.6 节为准，不依赖任何 demo/html 示例文件（示例文件仅用于预览效果，可随时删除）

### 6.6 颜色与尺寸速查表（自包含规范）

本节为颜色与尺寸的**唯一权威数值来源**，开发以此为准；即使删除所有示例/html 文件，规范仍然完整可用。

#### 6.6.1 语义色板（已确认配色）

| 语义 | 主色（按钮/图标） | 浅底（Alert / Tag / 块背景） | 深色（文字/描边） | 用途 |
| :--- | :--- | :--- | :--- | :--- |
| 主色 蓝 | #2563eb | #eff6ff / #dbeafe | #1e40af | 主操作、查看、信息提示；列表行 hover 固定 #eff6ff |
| 成功 绿 | #16a34a | #f0fdf4 / #dcfce7 | #166534 | 签收、结算完成、成功提示 |
| 警告 橙 | #f97316（按钮）/ #d97706（提示） | #fffbeb / #fef3c7 | #92400e | 差异处理、库存预警 |
| 危险 红 | #dc2626 | #fef2f2 / #fee2e2 | #991b1b | 删除、取消、冷链温度异常 |
| 次要 靛 | #4f46e5 | #eef2ff / #e0e7ff | #3730a3 | 编辑、导出、回单 |
| 信息 青 | #0891b2 | #ecfeff / #cffafe | #155e75 | 智能搜索、配送中状态 |
| 冷链 紫 | #9333ea | #faf5ff / #f3e8ff | #6b21a8 | 冷链标识、运营公告 |
| 常温 翠绿 | #059669 | #ecfdf5 / #d1fae5 | #065f46 | 常温标识 |
| 中性 灰 | #64748b | #f8fafc / #f1f5f9 | #334155 | 表头背景、辅助文字、已归档；边框统一 #e2e8f0 |

通用底色：页面背景 `#f5f7fa`；卡片背景 `#ffffff`；表格斑马/表头 `#f8fafc`。

#### 6.6.2 尺寸速查（字体 / 图标 / 按钮，三档）

| 元素 | S（紧凑） | M（默认） | L（舒适） |
| :--- | :--- | :--- | :--- |
| 正文 / 按钮文字 | 13px | 14px | 16px |
| 辅助 / 表格 / badge | 12px | 13px | 14px |
| 区块标题 | 15px | 16px | 18px |
| 页面标题 | 18px | 19px | 22px |
| 统计数字 | 20px | 22px | 26px |
| 常规图标 | 14px | 16px | 18px |
| 小按钮图标 | 12px | 13px | 15px |
| Alert 图标 | 16px | 18px | 20px |
| 按钮高度 | 30px | 32px | 36px |
| 列表操作按钮高度 | 24px | 26px | 30px |
| radio / checkbox | 14px | 15px | 17px |
| 表格单元格 padding | 8px 12px | 9px 14px | 12px 16px |

#### 6.6.3 边框与圆角（三档通用，不随档位变化）

| 元素 | 数值 |
| :--- | :--- |
| 圆角基准 `--radius` | 4px（0.25rem）：卡片 / 弹窗 / Drawer |
| 按钮 / 输入框圆角 | 3px（calc(var(--radius) - 1px)） |
| tag / badge 圆角 | 2px（calc(var(--radius) - 2px)） |
| 卡片 / 表格描边 | 1px solid #e2e8f0 |
| Block 左边框 | 3px 语义色（蓝/绿/橙/红/紫） |
| badge 内边距 | 1px 8px（M 档），行内高约 18px |
| 按钮内边距 | 常规 0 14px；列表操作按钮 0 9px（M 档） |
| 通知 Drawer 宽度 | 360px，右侧滑出 |
