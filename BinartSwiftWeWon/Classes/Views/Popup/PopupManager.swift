import Foundation

class PopupManager: NSObject {
    public func show(with view: UIView) {
        popup = PopupView()
        popup.customView = view
        popup.show()
    }
    
    public func show(with view: UIView, offset: CGPoint) {
        popup = PopupView()
        popup.customView = view
        popup.show()
    }
    
    public func show(with view: UIView, in window: UIWindow) {
        popup = PopupView()
        popup.customView = view
        popup.show(in: window)
    }
    
    public func hide () {
        popup.hide(animated: true)
    }
    
    fileprivate var popup: PopupView!
}
