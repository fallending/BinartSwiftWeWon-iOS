
import Foundation
import CoreLocation
#if canImport(MessageKit)
import MessageKit
#endif
import AVFoundation

public struct BAWCoordinateMsg: LocationItem {

    public var location: CLLocation
    public var size: CGSize

    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }

}

public struct BAWImageMsg: MediaItem {
    public var thumbnailURL: URL?
    public var originURL: URL?
    public var url: URL?
    public var image: UIImage?
    public var placeholderImage: UIImage
    public var size: CGSize

    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    
    init(url: URL) {
        self.url = url;
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    
    init(thumbnail: URL, origin: URL) {
        self.url = thumbnail;
        self.thumbnailURL = thumbnail
        self.originURL = origin
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }

}

public struct BAWAudioMsg: AudioItem {

    public var url: URL
    public var size: CGSize
    public var duration: Float

    init(url: URL) {
        self.url = url
        self.size = CGSize(width: 160, height: 35)
        // compute duration
        let audioAsset = AVURLAsset(url: url)
        self.duration = Float(CMTimeGetSeconds(audioAsset.duration))
    }

}

public struct BAWContactMsg: ContactItem {
    
    public var displayName: String
    public var initials: String
    public var phoneNumbers: [String]
    public var emails: [String]
    
    init(name: String, initials: String, phoneNumbers: [String] = [], emails: [String] = []) {
        self.displayName = name
        self.initials = initials
        self.phoneNumbers = phoneNumbers
        self.emails = emails
    }
    
}

// MARK: =

public struct BAWMsg: MessageType {

    public var messageId: String
    public var sender: SenderType {
        return user
    }
    public var sentDate: Date
    public var kind: MessageKind

    public var user: BAWUser

    private init(kind: MessageKind, user: BAWUser, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
    }
    
    // default
    public init() {
        self.init(kind: .custom(""), user: BAWUser(senderId: "", displayName: ""), messageId: "", date: Date())
    }
    
    // 自定义消息
    public init(custom: Any?, user: BAWUser, messageId: String, date: Date) {
        self.init(kind: .custom(custom), user: user, messageId: messageId, date: date)
    }

    // 文本消息
    public init(text: String, user: BAWUser, messageId: String, date: Date) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date)
    }
    
    // 通知
    public init(notify: String, id: String, date: Date) {
        self.init(kind: .notify(notify), user: BAWUser(senderId: "0", displayName: "0"), messageId: id, date: date)
    }

    // 富文本
    public init(attributedText: NSAttributedString, user: BAWUser, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), user: user, messageId: messageId, date: date)
    }

    // 图片
    public init(image: UIImage, user: BAWUser, messageId: String, date: Date) {
        let mediaItem = BAWImageMsg(image: image)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }
    
    public init(imageThumbnail: URL, imageOrigin: URL, user: BAWUser, id: String, date: Date) {
        let mediaItem = BAWImageMsg(thumbnail: imageThumbnail, origin: imageOrigin)
        self.init(kind: .photo(mediaItem), user: user, messageId: id, date: date)
    }

    // 视频
    public init(thumbnail: UIImage, user: BAWUser, messageId: String, date: Date) {
        let mediaItem = BAWImageMsg(image: thumbnail)
        self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date)
    }

    // 位置
    public init(location: CLLocation, user: BAWUser, messageId: String, date: Date) {
        let locationItem = BAWCoordinateMsg(location: location)
        self.init(kind: .location(locationItem), user: user, messageId: messageId, date: date)
    }

    // emoji
    public init(emoji: String, user: BAWUser, messageId: String, date: Date) {
        self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date)
    }

    // 音频
    public init(audioURL: URL, user: BAWUser, messageId: String, date: Date) {
        let audioItem = BAWAudioMsg(url: audioURL)
        self.init(kind: .audio(audioItem), user: user, messageId: messageId, date: date)
    }
    
    public init(audioUrl: String, user: BAWUser, id: String, date: Date) {
        self.init(audioURL: URL(string: audioUrl)!, user: user, messageId: id, date: date)
//        let audioItem = BAWAudioMsg(url: audioURL)
//        self.init(kind: .audio(audioItem), user: user, messageId: messageId, date: date)
    }

    // 联系人
    public init(contact: BAWContactMsg, user: BAWUser, messageId: String, date: Date) {
        self.init(kind: .contact(contact), user: user, messageId: messageId, date: date)
    }
}
