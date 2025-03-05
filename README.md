Repo: Demonstrating How to Implement a High-Performance Scrolling List
Main Pages and Features
Article List

Article Details (Web)

Design Considerations
The article list requires smooth pull-to-refresh and scrolling with no lag.

Image fetching and caching (to reduce bandwidth and improve loading speed).

Web page loading, with a focus on improving first-screen rendering speed.

Aesthetic design.

Technical Implementation
Article List Page
Based on previous experience (https://www.yuque.com/torresslol/share/bdxqgb), several optimizations were made:

Pre-calculate and cache control heights using ArticleLayoutCacheManager.

Avoid using boundingRect and AutoLayout for text calculations. Instead, pre-calculate and cache font metrics (reference: https://mp.weixin.qq.com/s/zHAlxALPMFZLv8M8bJaRKA).

Date parsing uses modern APIs, avoiding NSDateFormatter.

Use IGListKit to support partial updates.

Preload data when scrolling reaches a threshold to improve smoothness.

Use Kingfisher to prefetch images and cancel requests when necessary.

Ideally, images should leverage OSS's online scaling and progressive JPEG loading to reduce bandwidth and improve user experience. However, since the images in this example do not support this, Kingfisher is used to fetch and cache appropriately scaled images locally, reducing processing time during image loading.

Article Details Page
Pre-warm the WebView during app launch.

Custom transition animations.

Set up caching (pages with cached content still reload, likely due to JS logic; switching to Baidu results in instant loading).

Third-Party Libraries Used
SnapKit for layout.

Moya for network requests.

Kingfisher for image loading.

IGList for diff-based updates in collection views.

LookinServer for rapid layout debugging (a productivity booster).

Other Tools Used
Icons: https://www.flaticon.com/search?word=number&type=uicon.

UI: Inspired by the Medium app.
