import Foundation

// View Action -> 触发：一个动作，一个事件，反馈：状态更新

public protocol ViewAction {
    var ID: String { get }
}

enum ViewActions: ViewAction {
    // View 层产生的业务事件
    case toLogin
    case toLoginOut
    
    /// Data 层产生的数据变化事件
    case onMsgsChangedsss
    
    // Account Biz
    case Captcha
    case Login
    case Register
    case Logout
    
    
    //
//    case
    
    var ID: String {
        switch self {
        default:
        return ""
        }
    }
}
