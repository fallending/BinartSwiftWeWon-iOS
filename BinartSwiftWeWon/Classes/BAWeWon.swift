

import UIKit

public struct BAWeWon {
    
    // MARK: - 聊天场景
    
    
    
    // MARK: - 消息场景
    
    public static var themeColor: UIColor = UIColor(red: 37/255, green: 38/255, blue: 39/255, alpha: 1.0)
    
    // MARK: = 消息
    
    public static var imagePlaceholder: UIImage?
    public static var imagePlaceholderURL: NSString?
    
    public static var notifyTextColor: UIColor = .lightGray
    public static var notifyTextFont: UIFont = UIFont.italicSystemFont(ofSize: 11)
    
    // MARK: = 输入栏
    
    // Input Bar
    
    public static var inputBarBackgroundColor: UIColor  = UIColor(red: 55/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1/1.0);
    
    // Input TextView
    public static var inputTextViewBorderColor: UIColor = .clear
    public static var inputTextViewBorderWidth: CGFloat = 0.0
    public static var inputTextViewCornerRadius: CGFloat = 8.0
    public static var inputTextViewPlaceholder: UIColor = UIColor(red: 191/255.0, green: 191/255.0, blue: 191/255.0, alpha: 1/1.0)
    
    // Message
    public static var chatThemeColor: UIColor = UIColor(red: 255/255.0, green: 220/255.0, blue: 101/255.0, alpha: 1/1.0)
    
    // Avatar
    public static var outgoingAvatarOverlap: CGFloat = 17.5
    
    // Bubble
    public static var cellBackgroundColorForSelf: UIColor = chatThemeColor
    public static var cellbackgroundColorForThat: UIColor = UIColor(red: 49/255.0, green: 50/255.0, blue: 52/255.0, alpha: 1/1.0)
    
    
    // Audio
//    public static var audioButtonImageNormal: UIImage = nil
    
    
    
    // 扩展按钮
    
    
    
    // 照片
    public static var extImageOrderWeight: Int = 1
    
    
    public static var extPhotoOrderWeight: Int = 100
    
    public static var extAudioOrderWeight: Int = 200
}
