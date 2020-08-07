
import UIKit

/// 头像类型枚举
///
/// - Parameters:
///   - WeChat: 微信
///   - NewQQ:  QQ（以中心点分割的半圆拼接）
///   - OldQQ:  WeiBo（圆拼接）
public enum DCGroupAvatarType: Int {

    case WeChat
    case QQ
    case WeiBo
//
//    case overlapping // 重叠：微博
//    case centeraligned // 中心对齐：qq
//    case normal // 普通排列：微信
    
}

/// 组内头像的数量
///
/// - Parameters:
///  - One: 1
///  - Two: 2
///  - Three: 3
///  - Four: 4 (QQ最大值) / (微博最大值)
///  - Five: 5
///  - Six: 6
///  - Seven: 7
///  - Eight: 8
///  - Nine: 9 (微信最大值)
public enum DCNumberOfGroupAvatarType: Int {

    case One
    case Two
    case Three
    case Four
    case Five
    case Six
    case Seven
    case Eight
    case Nine
    
    
    public func description() -> Int {
        
        switch self {
        case .One:
            return 1
        case .Two:
            return 2
        case .Three:
            return 3
        case .Four:
            return 4
        case .Five:
            return 5
        case .Six:
            return 6
        case .Seven:
            return 7
        case .Eight:
            return 8
        case .Nine:
            return 9
        }
    }
}

public typealias GroupImageHandler = ((_ groupId: String, _ groupImage: UIImage, _ itemImageArray: [UIImage], _ cacheId: String) -> Void)

public typealias GroupSetImageHandler = (_ setImage: UIImage) -> Void

public typealias GroupImageParamsHandler = () -> Void

public typealias FetchImageHandler = (_ unitImages: [UIImage], _ succeed: Bool) -> Void

public typealias AsynFetchImageHandler = (_ unitImages: [UIImage]) -> Void

public typealias FetchImageParamsHandler = () -> Void


public struct BAWGroupAvatar {
    
    /// 请求的baseURL。这应该只包含URL的共体部分，例如'http://www.example.com'。
    public static var baseUrl: String?
    
    /// 一次性设置小头像加载失败的占位图 ： 权重低于类方法中的placeholder属性 placeholderImage < (id)placeholder
    public static var placeholderImage: UIImage = UIImage()
    
    /// 头像类型枚举(默认微信样式)
    public static var groupAvatarType: DCGroupAvatarType = .WeChat
    
    /// 微博外边圈宽度（默认：10）
    public static var borderWidth: CGFloat = AvatarConfig.DCWeiBoAvatarbordWidth
    
    /// 微博或者微信类型下的大头像的圆角
    public static var borderRadius: CGFloat = 5
    
    /// 微信和QQ群内小头像间距（默认值：2）
    public static var distanceBetweenAvatar: CGFloat = AvatarConfig.DCDistanceBetweenAvatar
    
    /// 头像背景(默认微信背景色)
    public static var avatarBgColor: UIColor = UIColor.bgColor

}

public struct AvatarConfig {
    
    /// 常量方法
    static let DCMaxWeChatCount: Int  = 9
    static let DCMaxQQCount: Int      = 4
    static let DCMaxWeiBoCount: Int   = 4
    
    static let DCMaxWeChatColumn: Int = 3
    
    static let DCDistanceBetweenAvatar: CGFloat = 2
    static let DCWeiBoAvatarbordWidth: CGFloat  = 10

}

// MARK: - 方法扩展
extension AvatarConfig {
    
    public static func urlStr(_ avaStr: String) -> String {
        
        guard let baseUrl = BAWGroupAvatar.baseUrl else {
            return avaStr
        }
        
        // 非http开头的，则拼接baseUrl
        return avaStr.contains("http") ? avaStr : "\(baseUrl)\(avaStr)"
    }
    
    
    public static func cacheIdMD5(_ groupId: String , _ groupSource: [String]) -> String {
        idMD5(groupId, groupSource)
    }

    
    // MARK: - 私有方法
    private static func idMD5(_ groupId: String , _ groupSource: [Any]) -> String {
        
        if groupSource.count == 0 {
            return ""
        }
        
        let appStrs = "id\(groupId)_num\(groupSource.count)_lastObj\(groupSource.last!)_distance\(BAWGroupAvatar.distanceBetweenAvatar)_bordWidth\(BAWGroupAvatar.avatarBgColor)_bgColor\(BAWGroupAvatar.avatarBgColor)"
        return appStrs.md5 ?? ""
    }

}
