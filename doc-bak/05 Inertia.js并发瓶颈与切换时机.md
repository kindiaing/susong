# Inertia.js 并发瓶颈与切换时机

> 明确回答：你的场景（公司人少、并发低、订货分散）用 Inertia.js 完全没问题，日活管理后台用户 500 以内、QPS 100 以内都不需要切换。切换纯 API 方案的阈值和信号见下文。

---

## 一、Inertia.js 的并发瓶颈在哪里

```
Inertia.js 请求链路：
浏览器 → Laravel Web 路由 → Controller 查询 → Inertia::render() → 返回 JSON+XHR → React 渲染

纯 API + React 请求链路：
浏览器 → React 静态页面 → API 请求 /api/xxx → Controller 查询 → JSON 返回 → React 渲染
```

**核心区别**：Inertia 把"数据查询"放在了服务端，纯 API 把"数据查询"拆成了两次请求（先加载静态页面，再调 API）。

| 瓶颈点 | Inertia.js | 纯 API |
| :--- | :--- | :--- |
| **服务端压力** | Controller 查询 + 组装数据，CPU 稍高 | API Controller 只做查询，前端 CDN 扛静态资源 |
| **首屏加载** | 服务端直接返回数据，首屏快 | 先加载 HTML+JS，再调 API，首屏多一次 RTT |
| **并发能力** | 依赖 Laravel 进程数（PHP-FPM/FrankenPHP） | 前端走 CDN，API 可独立扩容 |
| **数据库压力** | 相同（查询不可省） | 相同 |
| **内存占用** | 服务端渲染时内存稍高 | 前端完全在浏览器，服务端只做 API |

**结论**：Inertia.js 的瓶颈不是"它不行"，而是**服务端同时扛了"页面路由+数据查询"两件事**。只要查询优化好，它能撑很久。

---

## 二、什么时候必须切换？（具体阈值）

### 2.1 管理后台并发参考线

| 指标 | Inertia.js 无压力 | Inertia.js 需优化 | 建议切换纯 API |
| :--- | :--- | :--- | :--- |
| **日活管理后台用户** | < 50 人 | 50 ~ 500 人 | > 500 人 |
| **同时在线后台用户** | < 10 人 | 10 ~ 50 人 | > 50 人 |
| **页面 QPS** | < 20 | 20 ~ 100 | > 100 |
| **API QPS（含小程序）** | < 50 | 50 ~ 300 | > 300 |
| **数据库连接数** | < 50 | 50 ~ 200 | > 200 |
| **页面平均加载时间** | < 300ms | 300ms ~ 1s | > 1s（优化后） |

### 2.2 你的场景评估

> 公司人少、并发不高、订货分散在全天

| 评估项 | 你的情况 | Inertia.js 是否够用 |
| :--- | :--- | :--- |
| 管理后台同时在线 | 预计 3-5 人 | ✅ 完全没问题 |
| 日活后台用户 | 预计 < 20 人 | ✅ 完全没问题 |
| 订单峰值 QPS | 分散全天，无集中爆发 | ✅ 完全没问题 |
| 页面加载时间 | 数据量小，查询简单 | ✅ 预计 < 200ms |

**判断：你的场景用 Inertia.js 可以撑到项目成熟，至少半年到一年不需要考虑切换。**

---

## 三、切换纯 API 方案的信号

出现以下情况时，再考虑从 Inertia.js 切换到纯 React + Laravel API：

### 3.1 性能信号（硬指标）

```
□ 管理后台页面加载时间持续 > 1 秒（数据库优化后仍如此）
□ 服务器 CPU 占用 > 70%（日常时段，非峰值）
□ 数据库连接池频繁打满
□ PHP-FPM 进程数经常达到上限
□ 用户体验明显卡顿（同事抱怨页面慢）
```

### 3.2 业务信号（软指标）

```
□ 需要独立的移动端 H5 版本（Inertia 只适合做 Web，不适合 H5）
□ 需要把管理后台部署到 CDN（Inertia 页面不能纯静态缓存）
□ 前端团队独立了，需要前后端彻底分离
□ 需要 SSR 做 SEO（管理后台不需要，但未来可能有营销页）
□ 小程序之外还要做 App（Flutter/React Native 需要纯 API）
```

### 3.3 团队信号

```
□ 前端开发者从 1 人变成 2-3 人，需要独立前端仓库
□ 后端开发者从 1 人变成 2-3 人，需要专注 API 设计
□ 需要前后端并行开发（Inertia 里前后端还是耦合在一个项目）
```

---

## 四、Inertia.js 的性能优化（不用切换也能扛）

在切换之前，先做这些优化，通常能把并发能力提 3-5 倍：

### 4.1 数据库层

```php
// 1. 预加载，杜绝 N+1
$orders = Order::with(['customer', 'items.product', 'deliveryTask.driver'])
    ->latest()
    ->paginate(20);  // 每页最多 50 条，不要一次返几百条

// 2. 只选需要的字段
$orders = Order::select(['id', 'order_no', 'customer_id', 'total_amount', 'status', 'created_at'])
    ->with('customer:id,name')
    ->latest()
    ->paginate(20);

// 3. 加索引
// orders 表的 status、created_at、customer_id 必须加索引
```

### 4.2 缓存层

```php
// 4. Redis 缓存热点数据
$stats = Cache::remember('dashboard_stats', 60, function () {
    return [
        'today_orders' => Order::today()->count(),
        'pending_picking' => PickingList::pending()->count(),
        'deliverying' => DeliveryTask::today()->count(),
    ];
});

// 5. 缓存配置项、字典数据
$productCategories = Cache::remember('categories', 3600, fn() => Category::all());
```

### 4.3 服务端层

```php
// 6. 使用 FrankenPHP 替代 PHP-FPM（Laravel 13 推荐）
// FrankenPHP 支持 Worker 模式，请求间复用内存，性能提升 5-10 倍

// 7. 延迟加载非关键数据
return Inertia::render('Orders/Index', [
    'orders' => $orders,
    // 统计数据异步加载，不阻塞主页面
    'stats' => Inertia::lazy(fn() => $this->getStats()),
]);
```

### 4.4 前端层

```tsx
// 8. 前端缓存请求结果
import { useQuery } from '@tanstack/react-query';

// TanStack Query 自动缓存，5 分钟内重复访问不发起请求
const { data } = useQuery({
  queryKey: ['orders', page, filters],
  queryFn: () => fetchOrders(page, filters),
  staleTime: 5 * 60 * 1000,
});

// 9. 虚拟滚动（表格数据量大时）
// TanStack Table + 虚拟滚动，DOM 只渲染可见行
```

### 4.5 部署层

```
# 10. 静态资源走 CDN
# Vite 打包后的 JS/CSS 上传到 CDN，只留 HTML 走 Laravel

# 11. 数据库读写分离（超纲了，但知道有这选项）
# 读走从库，写走主库

# 12. 水平扩容
# 2 台 4 核 8G 的服务器 + Nginx 负载均衡，轻松撑 500 并发
```

---

## 五、切换成本预估

如果真的到了需要切换的那天，工作量有多大？

| 切换项 | 工作量 | 说明 |
| :--- | :--- | :--- |
| **API 层** | 2-3 天 | 把 Web Controller 改成 API Controller，加 Resource 格式化 |
| **路由** | 半天 | web.php 移入 api.php，加 `Route::apiResource()` |
| **前端入口** | 1 天 | Inertia 的 `app.tsx` 改成独立 React SPA，配 React Router |
| **认证** | 1 天 | Sanctum Token 替代 Session Cookie |
| **页面组件** | 0 天 | React 页面组件完全复用，不需要重写 |
| **UI 组件** | 0 天 | shadcn/ui 组件完全复用 |
| **状态管理** | 半天 | TanStack Query 缓存策略微调 |

**总工作量：约 5-7 天一个人。**

> 关键是：**React 页面组件和 shadcn/ui 组件完全不需要重写**，切换的只是"数据怎么来"（从 Inertia 的 props 变成 API 请求）。

---

## 六、给你的建议

### 现在（MVP 阶段）

```
✅ Inertia.js + React + shadcn/ui
✅ 小程序原生开发（走 api.php）
✅ 专注功能实现，不纠结性能
```

### 未来（6-12 个月后，如果业务爆发）

```
方案一：继续 Inertia.js，做优化（缓存、索引、FrankenPHP）
       适合：后台用户 < 100 人，页面不卡

方案二：切换纯 React + Laravel API
       适合：后台用户 > 100 人，或有 H5/App 需求
       成本：5-7 天一个人

方案三：混合架构（推荐）
       管理后台：Inertia.js（继续用，没坏不用修）
       小程序/App/H5：纯 API（本来就是独立的）
       适合：管理后台并发低，但移动端并发高
```

---

## 七、一句话总结

> **你的场景用 Inertia.js 至少能撑一年。管理后台同时在线 50 人以内、页面加载 500ms 以内，完全不需要切换。真到了那天，切换成本也就 5-7 天，React 组件全部复用。现在别想那么多，先快速把功能做出来。**

---

## 附：并发快速自查表

```bash
# 上线后定期跑这几个命令，监控是否需要优化/切换

# 1. 查看当前 PHP-FPM 进程数
ps aux | grep php-fpm | wc -l

# 2. 查看 MySQL 连接数
mysql -e "SHOW STATUS LIKE 'Threads_connected';"

# 3. 查看 Redis 内存
redis-cli INFO memory | grep used_memory_human

# 4. 查看服务器负载
top  # 看 load average，三核以上服务器 load < 3 算正常

# 5. 查看页面响应时间
# Laravel Telescope 或 Laravel Debugbar，看每个请求的 DB 查询时间
```

| 监控项 | 健康阈值 | 警告阈值 | 危险阈值 |
| :--- | :--- | :--- | :--- |
| 页面加载时间 | < 300ms | 300ms ~ 1s | > 1s |
| DB 查询时间 | < 50ms | 50ms ~ 200ms | > 200ms |
| 服务器 Load | < 核心数 | 核心数 ~ 2x | > 2x 核心数 |
| MySQL 连接数 | < 50 | 50 ~ 150 | > 150 |
| Redis 内存 | < 500MB | 500MB ~ 2GB | > 2GB |
