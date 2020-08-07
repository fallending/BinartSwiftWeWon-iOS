
import UIKit
import MapKit
#if canImport(MessageKit)
import MessageKit
#endif
import InputBarAccessoryView

// MARK: - Manager

extension MsgsScene {
    
    // MARK: = 输入区域状态控制
    
    enum InputBarStatus {
        case onNormal // 没有文字输入、扩展区域收起
        case onText // 正在输入文字，文字输入和扩展按钮互斥
        case onAudio // 正在录音，下方显示录音控制区域
        case onEmoticons // 正在选择表情
        case onExt // 正在展示扩展按钮
    }
    
    
    // MARK: = 
}
