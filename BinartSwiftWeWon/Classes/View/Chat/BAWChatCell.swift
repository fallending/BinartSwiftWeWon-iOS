
import UIKit
import SnapKit

public struct BAWChatCellConfig {
    public static var cellHeight: CGFloat = 64
    
    public static var avatarSize: CGFloat = 50
    public static var avatarFrame: CGRect = CGRect(
            x: 12,
            y: (cellHeight-avatarSize)/2,
            width: avatarSize,
            height: avatarSize
        )

    public static var titleColor: UIColor = .white
    public static var titleFont: UIFont = UIFont.systemFont(ofSize: 17)
    
    public static var detailColor: UIColor = .lightGray
    public static var detailFont: UIFont = UIFont.systemFont(ofSize: 13)
    
    public static var hintColor: UIColor = .lightGray
    public static var hintFont: UIFont = UIFont.systemFont(ofSize: 10)
    
    // badge
    public static var badgeColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    public static var badgeFontSize: Float = 11.0
    public static var badgeColorHighlighted: UIColor = .darkGray
    public static var badgeTextStyle: UIFont.TextStyle = .body
    public static var badgeTextColor: UIColor = .white
    public static var badgeTextOffset: Float = 0
    public static var badgeRadius: Float = 20
    public static var badgeOffset = CGPoint(x:10, y:0)
}

open class BAWChatCell: UITableViewCell {
    
    public static let reuseIdentifier = "BAWChatCell"
    
    let avatar = UIImageView()
    let title = UILabel()
    let detail = UILabel()
    
    let hint = UILabel()
    
    let badgeImageView = UIImageView()
    public var badge: String = "" {
        didSet {
            if badge == "" || badge == "0" {
                badgeImageView.removeFromSuperview()
                layoutSubviews()
            } else {
                contentView.addSubview(badgeImageView)
                drawBadge()
            }
        }
    }
    
    open var data: BAWChat! {
        didSet {
            display()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.backgroundColor = .clear
        
        title.textColor = BAWChatCellConfig.titleColor
        title.font = BAWChatCellConfig.titleFont
        
        detail.font = BAWChatCellConfig.detailFont
        detail.textColor = BAWChatCellConfig.detailColor
        
        hint.textAlignment = .right
        hint.font = BAWChatCellConfig.hintFont
        hint.textColor = BAWChatCellConfig.hintColor
        
        contentView.addSubview(avatar)
        contentView.addSubview(title)
        contentView.addSubview(detail)
        contentView.addSubview(hint)
        
        
        // 约束
        hint.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.lessThanOrEqualTo(20)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        avatar.frame = BAWChatCellConfig.avatarFrame
        
        title.frame = CGRect(x: 76, y: 6, width: self.frame.size.width - 92, height: 30)
        detail.frame = CGRect(x: 76, y: 32, width: self.frame.size.width - 92, height: 20)
        
        // Layout our badge's position
        var offsetX = BAWChatCellConfig.badgeOffset.x
        if (!isEditing) && (accessoryType != .none) || (accessoryView != nil) {
            offsetX = 0 // Accessory types are a pain to get sizing for?
        }

        badgeImageView.frame.origin.x = floor(contentView.frame.width - badgeImageView.frame.width - offsetX)
        badgeImageView.frame.origin.y = floor((frame.height / 2) - (badgeImageView.frame.height / 2))
    }
    
    func drawBadge() {
        let badgeFont = UIFont.boldSystemFont(ofSize:CGFloat(BAWChatCellConfig.badgeFontSize))

        // Calculate the size of our string
        let textSize: CGSize = NSString(string: badge).size(withAttributes: [NSAttributedString.Key.font: badgeFont])

        // Create a frame with padding for our badge
        let height = textSize.height + 10
        var width = textSize.width + 16

        if width < height {
            width = height
        }
        let badgeFrame : CGRect = CGRect(x:0, y:0, width:width, height:height)

        let badgeLayer = CALayer()
        badgeLayer.frame = badgeFrame

        if isHighlighted || isSelected {
            badgeLayer.backgroundColor = BAWChatCellConfig.badgeColorHighlighted.cgColor
        } else {
            badgeLayer.backgroundColor = BAWChatCellConfig.badgeColor.cgColor
        }

        let isRadiusLower = CGFloat(BAWChatCellConfig.badgeRadius) < (badgeLayer.frame.size.height / 2)
        badgeLayer.cornerRadius = isRadiusLower ? CGFloat(BAWChatCellConfig.badgeRadius) : CGFloat(badgeLayer.frame.size.height / 2)

        // Draw badge into graphics context
        UIGraphicsBeginImageContextWithOptions(badgeLayer.frame.size, false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        badgeLayer.render(in:ctx)
        ctx.saveGState()

        NSString(string: badge)
            .draw(in: CGRect(x: CGFloat(8 + 0), y: 5, width: textSize.width, height: textSize.height), withAttributes: [
            NSAttributedString.Key.font:badgeFont,
            NSAttributedString.Key.foregroundColor: BAWChatCellConfig.badgeTextColor
        ])

        let badgeImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        badgeImageView.frame = CGRect(x:0, y:0, width:badgeImage.size.width, height:badgeImage.size.height)
        badgeImageView.image = badgeImage

        layoutSubviews()
    }
    
    func display() {
        
        self.hint.text = data.hint
        self.title.text = data.title
        self.detail.text = data.detail
        self.badge = "\(data.badge)"
        
        self.avatar.baw_setImageAvatar(groupId: data.title!, groupSource:data.avatarSource)
    }
}
