
import UIKit
import Kingfisher

public struct CacheAvatarHelper {
    
    // MARK: - 获取群头像内部小头像缓存数组
    public static func fetchItemCacheArraySource(_ groupSource: [String]) -> [UIImage] {
        
        var cacheArray = [UIImage]()
        for item in groupSource {
            
            if let itemIamge = ImageCache.default.retrieveImageInMemoryCache(forKey: AvatarConfig.urlStr(item)) {
                cacheArray.append(itemIamge)
            }
        }
        return cacheArray
        
    }
 
    // MARK: - 批量加载地址头像
    public static func fetchLoadImageSource(groupSource: [String], cacheGroupImage: UIImage? = nil, itemPlaceholder: [UIImage]? = nil, completedHandler: FetchImageHandler? = nil) {
        
        var groupImages = Array(repeating: UIImage(), count: groupSource.count)
        var succeed: Bool = false
        
        var groupSum: Int = 0
        var placeholderSum: Int = 0
        
        let callCompletedBlock: GroupImageParamsHandler = {
            DispatchQueue.main.async {
                if (completedHandler != nil) {
                    completedHandler!(groupImages, succeed)
                }
            }
        }
        
        for (index, value) in groupSource.enumerated() {
            
            let url = URL(string: AvatarConfig.urlStr(value))
            guard let downUrl = url else { continue }
            
            let placeholderImage = BAWGroupAvatar.placeholderImage.backItemPlaceholderImage(itemPlaceholder, groupSource.count, index)
            if cacheGroupImage == nil {
                placeholderSum = placeholderSum + 1
                groupImages[index] = placeholderImage
                if placeholderSum == groupSource.count {
                    callCompletedBlock()
                }
            }
            
            KingfisherManager.shared.retrieveImage(with: downUrl, options: nil, progressBlock: nil) { (image, error, cacheType, url) in
                
                groupSum = groupSum + 1
                
                if (error != nil){
                    print("Error retrieving image!");
                    return;
                }
                
                succeed = true
                
                groupImages[index] = image ?? placeholderImage
                
                if groupSum == groupSource.count {
                    callCompletedBlock()
                }
            }
        }
    }
}

extension CacheAvatarHelper {
    
    
    /// 异步批量加载头像
    /// - Parameters:
    ///   - groupSource: 数据源
    ///   - itemPlaceholder: 占位图
    ///   - completedHandler: 返回加载的图像和是否成功的tag
    public static func asynfetchLoadImageSource(_ groupSource: [String], _ itemPlaceholder: [UIImage]? = nil, _ completedHandler: AsynFetchImageHandler? = nil) {
        
        fetchLoadImageSource(groupSource: groupSource, cacheGroupImage: nil, itemPlaceholder: itemPlaceholder) { (unitImages, succeed) in
            if completedHandler != nil , succeed == true {
                completedHandler!(unitImages)
            }
        }
    }
    
}
