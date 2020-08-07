
import UIKit
import Kingfisher

extension UIImageView {
    
    /// 设置群头像
    /// - Parameters:
    ///   - groupId: 群头像id
    ///   - groupSource: 群头像数据源数组
    ///   - itemPlaceholder: 占位图 例：[image1,image2] 权重大于 placeholderImage属性
    ///   - options: 加载图片选项，详情可见DCGroupAvatarCacheType枚举
    ///   - setImageHandler: 绘制好的群头像图片
    ///   - groupImageHandler: _ groupId: String, _ groupImage: UIImage, _ itemImageArray: [UIImage], _ cacheId: String
    public func baw_setImageAvatar(groupId: String, groupSource: [String], itemPlaceholder: [UIImage]? = nil, setImageHandler: GroupSetImageHandler? = nil, groupImageHandler: GroupImageHandler? = nil) {
     
        UIImage.baw_setCacheImageAvatar(groupId, groupSource, itemPlaceholder, CGSize(width: self.frame.size.width, height: self.frame.size.height), {[weak self] (groupImage) in
            guard let self = self else { return }
            self.image = groupImage
            if setImageHandler != nil {
                setImageHandler!(groupImage)
            }
        }) {[weak self] (groupId, groupImage, itemImageArray, cacheId) in
            guard let self = self else { return }
            self.image = groupImage
            if groupImageHandler != nil {
                groupImageHandler!(groupId, groupImage, itemImageArray, cacheId)
            }
        }
    }
}
