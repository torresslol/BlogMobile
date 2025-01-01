# Repo 主要用来演示如何实现一个高性能的滑动列表

## 主要页面和功能
1. 文章列表
2. 文章详情（ web ）

## 设计考虑
1. 文章列表需要上下拉，希望滑动流畅，无卡顿
2. 图片获取和缓存（减少带宽，提升加载速度）
3. web 页加载，提升首屏渲染速度
4. 尽量美观

## 技术实现
#### 列表页
基于原来的经验 [https://www.yuque.com/torresslol/share/bdxqgb](https://www.yuque.com/torresslol/share/bdxqgb) 做了一些优化

1. 提前计算控件高度并缓存 **ArticleLayoutCacheManager**
2. 文本计算避免使用 **boundingRect** 和 **Autolayout**，提前计算并缓存字体 (参考 [https://mp.weixin.qq.com/s/zHAlxALPMFZLv8M8bJaRKA](https://mp.weixin.qq.com/s/zHAlxALPMFZLv8M8bJaRKA))
3. Date 解析采用了新的 Api，避免使用 **NSDateFormatter**
4. 使用 **IGlistKit** 支持局部刷新
5. 在上拉到一个阈值时，提前加载，提升流畅度
6. prefetch 中 提前使用 **Kingfisher** 加载图片， cancel 的时候取消
7. 理想情况下图片应该在 oss 想利用 oss 的 在线缩放 和 jpg 的渐进式加载 减少带宽占用和提升体验，本示例中的图片不支持，所以使用 Kingfisher 根据 scale 获取对应大小的图片缓存在本地，减少图片加载过程中的处理时间

#### 详情页
1. 启动对 webView 进行预热
2. 自定义转场动画
3. 设置缓存（加载有缓存的页面还是会重新load，应该是js的逻辑，我换了百度是秒开）

#### 采用的第三方库
1. **SnapKit** 用于布局
2. **Moya** 网络请求
3. **Kingfisher** 图片加载
4. **IGList** 网格视图差异更新
5. **LookinServer** 仅用于快速调试布局，提效利器


#### 使用的其他工具
**icon** - [https://www.flaticon.com/search?word=number&type=uicon](https://www.flaticon.com/search?word=number&type=uicon) （时间有限，使用 IconFont 比较麻烦）

**AI** - Github Copilot (Cursor 国内没有稳定的付费途径)

**UI** - 参考的 Medium 客户端 （开始 也显示了 article 的 user 和 tags,  但是获取到的数据里的这部分看起来是加密过的，显示上去太丑了，就去掉了）

## 其他
Web 那部分的优化应该可以使用离线资源包来实现的，限于时间和需要前端协作没法实现




