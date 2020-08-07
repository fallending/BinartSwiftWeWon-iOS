
import UIKit
import MapKit
#if canImport(MessageKit)
import MessageKit
#endif
import InputBarAccessoryView

// MARK: - Text 文字输入的特殊控制

extension MsgsScene: InputBarAccessoryViewDelegate {
    
    open func onMsgSent(_ text: String) {
        
    }
    
    // MARK: =
 
    public func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

        // Here we can parse for which substrings were autocompleted
        let attributedText = messageInputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in

            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            
//            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }

        let components = inputBar.inputTextView.components
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()

        // Send button activity animation
//        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
//                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Say something~"
                self?.insertMessages(components)
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    public func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        
    }
    
    public func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        
    }
    
    public func inputBar(_ inputBar: InputBarAccessoryView, didSwipeTextViewWith gesture: UISwipeGestureRecognizer) {
        
    }
}
