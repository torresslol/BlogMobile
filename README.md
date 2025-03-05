# Repo: Demonstrating How to Implement a High-Performance Scrolling List

## Main Pages and Features
1. **Article List**  
2. **Article Details (Web)**  

## Design Considerations
1. The article list should support smooth pull-to-refresh and scrolling with no lag.  
2. Optimize image fetching and caching to reduce bandwidth usage and improve loading speed.  
3. Enhance web page loading performance, focusing on faster first-screen rendering.  
4. Ensure the design is visually appealing.  

## Technical Implementation

### Article List Page
Based on previous experience ([reference](https://www.yuque.com/torresslol/share/bdxqgb)), several optimizations were implemented:  

1. **Pre-calculate and cache control heights** using `ArticleLayoutCacheManager`.  
2. **Avoid `boundingRect` and `AutoLayout` for text calculations**. Instead, pre-calculate and cache font metrics ([reference](https://mp.weixin.qq.com/s/zHAlxALPMFZLv8M8bJaRKA)).  
3. **Modern date parsing APIs** are used instead of `NSDateFormatter`.  
4. **IGListKit** is used to support partial updates for better performance.  
5. **Preload data** when scrolling reaches a threshold to ensure smooth scrolling.  
6. **Prefetch images** using `Kingfisher` and cancel requests when necessary.  
7. **Optimize image loading**: Ideally, images should leverage OSS's online scaling and progressive JPEG loading to reduce bandwidth and improve user experience. However, since the images in this example do not support this, `Kingfisher` is used to fetch and cache appropriately scaled images locally, reducing processing time during image loading.  

### Article Details Page
1. **Pre-warm the WebView** during app launch to improve loading speed.  
2. **Custom transition animations** for a smoother user experience.  
3. **Set up caching**: Pages with cached content still reload (likely due to JS logic). For example, switching to Baidu results in instant loading.  

### Third-Party Libraries Used
1. **SnapKit**: For declarative and efficient layout management.  
2. **Moya**: For handling network requests in a clean and type-safe way.  
3. **Kingfisher**: For efficient image loading and caching.  
4. **IGListKit**: For diff-based updates in collection views, enabling smooth partial updates.  
5. **LookinServer**: For rapid layout debugging, significantly improving development efficiency.  

### Other Tools Used
- **Icons**: Sourced from [Flaticon](https://www.flaticon.com/search?word=number&type=uicon). 
- **UI Design**: Inspired by the Medium app.
