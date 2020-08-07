
import UIKit
import MapKit
#if canImport(MessageKit)
import MessageKit
#endif
import InputBarAccessoryView
import SVGKit

// 不大合理啊
//public enum BAWMsgBottomLabelType {
//    case time // 时间
//    case status // 送达状态，已读状态
//    case none // 不显示
//}

open class MsgsScene: MessagesViewController, MessagesDataSource {
    
    open var isMock = false
//    open var msgBottomLabelType: BAWMsgBottomLabelType = .none
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// The `BAWAudioController` controll the AVAudioPlayer state (play, pause, stop) and udpate audio cell UI accordingly.
    open lazy var audioController = BAWAudioController(messageCollectionView: messagesCollectionView)

    public var messageList: [BAWMsg] = []
    
    public let refreshControl = UIRefreshControl()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    /// The object that manages autocomplete, from InputBarAccessoryView
    lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: self.messageInputBar.inputTextView)
        manager.delegate = self
        manager.dataSource = self
        return manager
    }()

    var hastagAutocompletes: [AutocompleteCompletion] = {
        var array: [AutocompleteCompletion] = []
        for _ in 1...100 {
            array.append(AutocompleteCompletion(text: Lorem.word(), context: nil))
        }
        return array
    }()

    // Completions loaded async that get appeneded to local cached completions
    var asyncCompletions: [AutocompleteCompletion] = []
    
    open override func viewDidLoad() {
        
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: BAWNotifyLayout())
        messagesCollectionView.register(NotifyCell.self)
        
        super.viewDidLoad()
        
        view.backgroundColor = BAWeWon.themeColor
        
//        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: BAWNotifyLayout())
//        messagesCollectionView.register(NotifyCell.self)
        
        configureMessageCollectionView()
        configureMessageInputBar()
        loadFirstMessages()
        
        title = "MessageKit"
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isMock {
            
            MockSocket.shared.connect(with: [SampleData.shared.nathan, SampleData.shared.wu])
                .onTypingStatus { [weak self] in
                    self?.setTypingIndicatorViewHidden(false)
                }.onNewMessage { [weak self] message in
                    self?.setTypingIndicatorViewHidden(true, performUpdates: {
                        self?.insertMessage(message)
                    })
            }
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMock {
            MockSocket.shared.disconnect()
        }
        audioController.stopAnyOngoingPlaying()
    }
    
    open func loadFirstMessages() {
        if isMock {
            DispatchQueue.global(qos: .userInitiated).async {
                let count = UserDefaults.standard.mockMessagesCount()
                SampleData.shared.getAdvancedMessages(count: count) { messages in
                    DispatchQueue.main.async {
                        self.messageList = messages
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom()
                    }
                }
            }
        }
    }
    
    @objc
    open func loadMoreMessages() {
        if isMock {
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
                SampleData.shared.getAdvancedMessages(count: 20) { messages in
                    DispatchQueue.main.async {
                        self.messageList.insert(contentsOf: messages, at: 0)
                        self.messagesCollectionView.reloadDataAndKeepOffset()
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        }
    }
    
    open func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messagesCollectionView.addSubview(refreshControl)
        
        messagesCollectionView.backgroundColor = BAWeWon.themeColor
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        
        // Hide the outgoing avatar and adjust the label alignment to line up with the messages
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))

        // Set outgoing avatar to overlap with the message bubble
        layout?.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 18, bottom: BAWeWon.outgoingAvatarOverlap, right: 0)))
        layout?.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: -BAWeWon.outgoingAvatarOverlap, left: -18, bottom: BAWeWon.outgoingAvatarOverlap, right: 18))
        
        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))
    }

    /// The input bar will autosize based on the contained text, but we can add padding to adjust the height or width if neccesary
    /// See the InputBar diagram here to visualize how each of these would take effect:
    /// https://raw.githubusercontent.com/MessageKit/MessageKit/master/Assets/InputBarAccessoryViewLayout.png
    private func configureInputBarPadding() {
    
        // Entire InputBar padding
        messageInputBar.padding.bottom = 8
        
        // or MiddleContentView padding
        messageInputBar.middleContentViewPadding.right = 8

        // or InputTextView padding
        messageInputBar.inputTextView.textContainerInset.bottom = 8
        
    }
    
    private func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 25, height: 25), animated: false)
                $0.tintColor = UIColor(white: 0.8, alpha: 1)
            }.onSelected {
                $0.tintColor = BAWeWon.themeColor
            }.onDeselected {
                $0.tintColor = UIColor(white: 0.8, alpha: 1)
            }.onTouchUpInside {
                print("Item Tapped")
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                actionSheet.addAction(action)
                if let popoverPresentationController = actionSheet.popoverPresentationController {
                    popoverPresentationController.sourceView = $0
                    popoverPresentationController.sourceRect = $0.frame
                }
                self.navigationController?.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    private func configureInputBarItems() {
        configureMessageInputButton()
        
//        messageInputBar.send
        
        messageInputBar.setRightStackViewWidthConstant(to: 64, animated: false)
        
        //
        let charCountButton = InputBarButtonItem()
            .configure {
                $0.title = "0/140"
                $0.contentHorizontalAlignment = .right
                $0.setTitleColor(UIColor(white: 0.6, alpha: 1), for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .bold)
                $0.setSize(CGSize(width: 50, height: 25), animated: false)
            }.onTextViewDidChange { (item, textView) in
                item.title = "\(textView.text.count)/140"
                let isOverLimit = textView.text.count > 140
                item.inputBarAccessoryView?.shouldManageSendButtonEnabledState = !isOverLimit // Disable automated management when over limit
                if isOverLimit {
                    item.inputBarAccessoryView?.sendButton.isEnabled = false
                }
                let color = isOverLimit ? .red : UIColor(white: 0.6, alpha: 1)
                item.setTitleColor(color, for: .normal)
        }
        let bottomItems = [.flexibleSpace, charCountButton]
        
        configureInputBarPadding()
        
//        messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)
    }
    
    open func configureMessageInputButton() {
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.sendButton.image = #imageLiteral(resourceName: "ic_up")
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.tintColor = BAWeWon.chatThemeColor
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
        messageInputBar.sendButton.activityViewColor = .white
//        messageInputBar.sendButton.backgroundColor = BAWeWon.chatThemeColor
        //        messageInputBar.sendButton.layer.cornerRadius = 10
        messageInputBar.sendButton.setTitleColor(.white, for: .normal)
        messageInputBar.sendButton.setTitleColor(UIColor(white: 1, alpha: 0.3), for: .highlighted)
        messageInputBar.sendButton.setTitleColor(UIColor(white: 1, alpha: 0.3), for: .disabled)
        messageInputBar.sendButton
            .onSelected { item in
                item.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }.onDeselected { item in
                item.transform = .identity
        }
        
        // 发送按钮的动态变化
        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = BAWeWon.chatThemeColor
                })
            }.onDisabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
                })
        }
    }
    
    open func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.backgroundColor = BAWeWon.inputBarBackgroundColor
        messageInputBar.backgroundView.backgroundColor = BAWeWon.inputBarBackgroundColor
        messageInputBar.inputAccessoryView?.backgroundColor = BAWeWon.inputBarBackgroundColor
        
//        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.tintColor = BAWeWon.chatThemeColor
        messageInputBar.inputTextView.backgroundColor = BAWeWon.themeColor
        messageInputBar.inputTextView.placeholderTextColor = BAWeWon.inputTextViewPlaceholder
        messageInputBar.inputTextView.textColor = .white
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = BAWeWon.inputTextViewBorderColor.cgColor
        messageInputBar.inputTextView.layer.borderWidth = BAWeWon.inputTextViewBorderWidth
        messageInputBar.inputTextView.layer.cornerRadius = BAWeWon.inputTextViewCornerRadius
        if BAWeWon.inputTextViewCornerRadius > 0 {
            messageInputBar.inputTextView.layer.masksToBounds = true
        }
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        configureInputBarItems()
        
//        configureMessageInputBar()
        
        // 自定义 configureMessageInputBarForChat
                
        messageInputBar.setMiddleContentView(messageInputBar.inputTextView, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 52, animated: false)
        
        let bottomItems = [makeButton(named: "ic_at"), makeButton(named: "ic_hashtag"), .flexibleSpace]
//        messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)
    }
    
    // MARK: - Helpers
    
    public func insertMessage(_ message: BAWMsg) {
        messageList.append(message)
        
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    public func insertMessages(_ data: [Any]) {
        for component in data {
            let user = SampleData.shared.currentSender
            if let str = component as? String {
                let message = BAWMsg(text: str, user: user, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            } else if let img = component as? UIImage {
                let message = BAWMsg(image: img, user: user, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            }
        }
    }
    
    public func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    // MARK: - MessagesDataSource
    
    public func currentSender() -> SenderType {
        return SampleData.shared.currentSender
    }
    
    public func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    public func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    open func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    public func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if isTimeLabelVisible(at: indexPath) {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
        
//        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    open func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !isPreviousMessageSameSender(at: indexPath) {
            let name = message.sender.displayName
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
    }
    
    open func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message) {
            return NSAttributedString(string: "Delivered", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        
        return nil
    }
    
    public func customCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell {
        return UICollectionViewCell();
    }
    
}

// MARK: - MessageCellDelegate

extension MsgsScene: MessageCellDelegate {
    
    public func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    public func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    open func didTapImage(in cell: MessageCollectionViewCell) {
        print("Image tapped")
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Failed to identify message when audio cell receive tap gesture")
                return
        }
        
//        let msg: BAWMsg = message as! BAWMsg
        
        switch message.kind {
        case .photo(let item):
            guard let url = item.originURL else {
                break
            }
            
            BAWImageUtil.preview(sources: [url], context: self)
        default:
            break
        }
        
    }
    
    public func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    public func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    public func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    public func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }

    public func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Failed to identify message when audio cell receive tap gesture")
                return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }

    public func didStartAudio(in cell: AudioMessageCell) {
        print("Did start playing audio sound")
    }

    public func didPauseAudio(in cell: AudioMessageCell) {
        print("Did pause audio sound")
    }

    public func didStopAudio(in cell: AudioMessageCell) {
        print("Did stop audio sound")
    }

    public func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }

}

// MARK: - MessageLabelDelegate

extension MsgsScene: MessageLabelDelegate {
    
    public func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    public func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    public func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    public func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    public func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }

    public func didSelectHashtag(_ hashtag: String) {
        print("Hashtag selected: \(hashtag)")
    }

    public func didSelectMention(_ mention: String) {
        print("Mention selected: \(mention)")
    }

    public func didSelectCustom(_ pattern: String, match: String?) {
        print("Custom data detector patter selected: \(pattern)")
    }

}

/// MARK: - MessagesDisplayDelegate

extension MsgsScene {
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section - 1].user
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section + 1].user
    }
    
    func setTypingIndicatorViewHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
        updateTitleView(title: "MessageKit", subtitle: isHidden ? "请配置你的次标题" : "Typing...")
        setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] success in
            if success, self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
}

extension MsgsScene: MessagesDisplayDelegate {

    // MARK: - Text Messages

    public func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .darkText : .white
    }

    public func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention:
            if isFromCurrentSender(message: message) {
                return [.foregroundColor: UIColor.white]
            } else {
                return [.foregroundColor: BAWeWon.themeColor]
            }
        default: return MessageLabel.defaultAttributes
        }
    }

    public func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }

    // MARK: - All Messages
    
    public func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? BAWeWon.cellBackgroundColorForSelf : BAWeWon.cellbackgroundColorForThat
    }

    public func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        var corners: UIRectCorner = []
        
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topRight)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topLeft)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
        
        return .custom { view in
            let radius: CGFloat = 16
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
    }
    
    public func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        avatarView.set(avatar: avatar)
        avatarView.isHidden = isNextMessageSameSender(at: indexPath)
        avatarView.layer.borderWidth = 2
        avatarView.layer.borderColor = BAWeWon.themeColor.cgColor
    }
    
    public func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // Cells are reused, so only add a button here once. For real use you would need to
        // ensure any subviews are removed if not needed
        accessoryView.subviews.forEach { $0.removeFromSuperview() }
        accessoryView.backgroundColor = .clear

        let shouldShow = Int.random(in: 0...10) == 0
        guard shouldShow else { return }

        let button = UIButton(type: .infoLight)
        button.tintColor = BAWeWon.chatThemeColor
        accessoryView.addSubview(button)
        button.frame = accessoryView.bounds
        button.isUserInteractionEnabled = false // respond to accessoryView tap through `MessageCellDelegate`
        accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
        accessoryView.backgroundColor = BAWeWon.chatThemeColor.withAlphaComponent(0.3)
    }
    
    // MARK: - Location Messages
    
    public func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    public func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    
    public func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }

    // MARK: - Audio Messages

    public func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return self.isFromCurrentSender(message: message) ? .white : BAWeWon.themeColor
    }

    public func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        audioController.configureAudioCell(cell, message: message) // this is needed especily when the cell is reconfigure while is playing sound
    }
    
}

// MARK: - MessagesLayoutDelegate

extension MsgsScene: MessagesLayoutDelegate {

    public func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        return 0
    }
    
    public func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? (20 + BAWeWon.outgoingAvatarOverlap) : 0
        }
    }

    public func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
    }
}

// MARK: - AutocompleteManagerDelegate, AutocompleteManagerDataSource

extension MsgsScene: AutocompleteManagerDelegate, AutocompleteManagerDataSource {
    
    // MARK: - AutocompleteManagerDataSource

    public func autocompleteManager(_ manager: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {

        if prefix == "@" {
            return SampleData.shared.senders
                .map { user in
                    return AutocompleteCompletion(text: user.displayName,
                                                  context: ["id": user.senderId])
            }
        } else if prefix == "#" {
            return hastagAutocompletes + asyncCompletions
        }
        return []
    }

    public func autocompleteManager(_ manager: AutocompleteManager, tableView: UITableView, cellForRowAt indexPath: IndexPath, for session: AutocompleteSession) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: AutocompleteCell.reuseIdentifier, for: indexPath) as? AutocompleteCell else {
            fatalError("Oops, some unknown error occurred")
        }
        let users = SampleData.shared.senders
        let id = session.completion?.context?["id"] as? String
        let user = users.filter { return $0.senderId == id }.first
        if let sender = user {
            cell.imageView?.image = SampleData.shared.getAvatarFor(sender: sender).image
        }
        cell.imageViewEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        cell.imageView?.layer.cornerRadius = 14
        cell.imageView?.layer.borderColor = BAWeWon.chatThemeColor.cgColor
        cell.imageView?.layer.borderWidth = 1
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.attributedText = manager.attributedText(matching: session, fontSize: 15)
        return cell
    }

    // MARK: - AutocompleteManagerDelegate

    public func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        setAutocompleteManager(active: shouldBecomeVisible)
    }

    // Optional
    public func autocompleteManager(_ manager: AutocompleteManager, shouldRegister prefix: String, at range: NSRange) -> Bool {
        return true
    }

    // Optional
    public func autocompleteManager(_ manager: AutocompleteManager, shouldUnregister prefix: String) -> Bool {
        return true
    }

    // Optional
    public func autocompleteManager(_ manager: AutocompleteManager, shouldComplete prefix: String, with text: String) -> Bool {
        return true
    }

    // MARK: - AutocompleteManagerDelegate Helper

    func setAutocompleteManager(active: Bool) {
        let topStackView = messageInputBar.topStackView
        if active && !topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.insertArrangedSubview(autocompleteManager.tableView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active && topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.removeArrangedSubview(autocompleteManager.tableView)
            topStackView.layoutIfNeeded()
        }
        messageInputBar.invalidateIntrinsicContentSize()
    }
}
