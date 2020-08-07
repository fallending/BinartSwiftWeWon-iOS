
import Foundation

open class BAWChat {
    open var chatId: Int64 = 0
    open var chatType: Int32 = 0
    
    open var avatarSource: [String] = []
    
    open var title: String? = ""
    open var detail: String? = ""
    open var hint: String? = ""
    
    open var badge: Int32 = 0
    
    public init() {
    }
    
    public init (src: [String], title: String, detail: String = "", hint: String = "", badge: Int32 = 0) {
        self.avatarSource = src
        self.title = title
        self.detail = detail
        self.hint = hint
        self.badge = badge
    }
    
    public init (id: Int64, type: Int32, src: [String], title: String, detail: String? = "", hint: String? = "", badge: Int32 = 0) {
        self.chatId = id
        self.chatType = type
        self.avatarSource = src
        self.title = title
        self.detail = detail
        self.hint = hint
        self.badge = badge
    }
}
