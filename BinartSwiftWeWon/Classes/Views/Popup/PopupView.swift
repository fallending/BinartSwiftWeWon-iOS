import UIKit
import Foundation
//import BinartOCLayout

class PopupView: UIView {
    // Configurations
    
    private struct PopupViewConstants {
        let headerHeight: CGFloat = 56
        let headerHeightWithoutCircle: CGFloat = 30
        let activeVelocity: CGFloat = 150
        let minVelocity: CGFloat = 300
        let separatorThickness: CGFloat = 1.0 / UIScreen.main.scale
    }
    
    public var hasRoundCorners = true
    public var hideAnimationDuration: TimeInterval = 0.5
    public var autoHideTime: TimeInterval = 3.0 ////seconds
    public var isActionButtonsVertical: Bool = false
    public var hasShadow: Bool = false
    public var isHeaderIconFilled: Bool = false
    public var circleFillColor: UIColor? = nil
    
    // Properties
    public var customView: UIView!

    fileprivate var popupView: UIView = UIView(frame: .zero) // content

    fileprivate var popupCenter: CGPoint {
        get {
            return popupView.center
        }
        set {
            popupView.center = newValue
        }
    }

    fileprivate var popupTransform: CGAffineTransform {
        get {
            return popupView.transform
        }
        set {
            popupView.transform = newValue
        }
    }

    fileprivate var popupAlpha: CGFloat {
        get {
            return popupView.alpha
        }
        set {
            popupView.alpha = newValue
        }
    }

    private var popupViewInitialFrame: CGRect!
    private let constants = PopupViewConstants()
    private var backgroundView: UIView = UIView(frame: .zero)
    private var coverView: UIView = UIView(frame: .zero)
    private var buttonView: UIView = UIView(frame: .zero)
    private var titleLabel: UILabel = UILabel(frame: .zero)
    private var messageLabel: UILabel = UILabel(frame: .zero)
    private var textField: UITextField = UITextField(frame: .zero)
    private var isKeyboardVisible: Bool = false
    weak private var hideTimer: Timer!
    public var headerHeight: CGFloat = PopupViewConstants().headerHeight

    public convenience init() {
        self.init(frame: .zero)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        if hasShadow {
            popupView.layer.shadowColor = UIColor.black.cgColor
            popupView.layer.shadowOpacity = 0.2
            popupView.layer.shadowRadius = 4
            popupView.layer.shadowOffset = CGSize.zero
            popupView.layer.masksToBounds = false
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0.0, y: popupView.bounds.size.height))
            path.addLine(to: CGPoint(x: 0, y: headerHeight))
            path.addLine(to: CGPoint(x: popupView.bounds.size.width,
                                     y: CGFloat(headerHeight - 5)))
            path.addLine(to: CGPoint(x: popupView.bounds.size.width,
                                     y: popupView.bounds.size.height))
            path.close()
            popupView.layer.shadowPath = path.cgPath
        }
    }
    
    func topWindow () -> UIWindow {
        var keyWindow = UIApplication.shared.keyWindow
        if let _ = keyWindow {
            keyWindow = UIApplication.shared.windows.first
        }
        
        return keyWindow!
    }
    
    public func show(autohide: Bool = false) {
        show(in: topWindow())
    }
    
    public func show(in window: UIWindow, autohide: Bool = false) {
        window.addSubview(self)
        
        cd_alignToParent(with: 0)
        addSubview(backgroundView)
        backgroundView.cd_alignToParent(with: 0)
        createViews()
        popupViewInitialFrame = popupView.frame
        
        // 动画
        popupView.alpha = 0
        popupView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)

        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
            options: .allowUserInteraction,
            animations: {
                self.backgroundView.alpha = 1
                self.popupView.alpha = 1
                self.popupView.transform = CGAffineTransform(scaleX: 1, y: 1)
            },
            completion: { isCompleted in
//                transitionContext.completeTransition(isCompleted)
            }
        )
        
        // 拖动移除，暂时屏蔽
        let gestureRecognizer = UIPanGestureRecognizer(target: self,
                                                       action: #selector(popupMoved(recognizer:)))
        popupView.addGestureRecognizer(gestureRecognizer)
        
        if autohide {
            hideTimer = Timer.scheduledTimer(timeInterval: autoHideTime, target: self, selector: #selector(self.hideTimeOut(_:)), userInfo: nil, repeats: false)
        }
    }

    @objc func hideTimeOut(_ timer:Timer) {
        
        self.hide(animated: true)
    }
    
    public func hide(animated: Bool) {
        self.hideTimer?.invalidate()
        self.hideTimer = nil

        UIView.animate(withDuration: hideAnimationDuration,
                       animations: { [unowned self] in
            if animated {
                do {
                    var offScreenCenter = self.popupView.center
                    offScreenCenter.y += self.constants.minVelocity * 3
                    self.popupView.center = offScreenCenter
                    self.alpha = 0
                }
            }
        },
                       completion: { (finished) in
            self.removeFromSuperview()
//            if let completion = self.completionBlock {
//                completion(self)
//            }
        })

    }

    @objc func popupMoved(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: backgroundView)
        UIView.animate(withDuration: 0, animations: {
            self.popupView.center = location
        })
        switch recognizer.state {
        case .ended:
            let location = recognizer.location(in: backgroundView)
            let origin = CGPoint(x: backgroundView.center.x - popupViewInitialFrame.size.width / 2,
                                 y: backgroundView.center.y - popupViewInitialFrame.size.height / 2)
            let velocity = recognizer.velocity(in: backgroundView)
            if !CGRect(origin: origin,
                       size: popupViewInitialFrame.size).contains(location) ||
            (velocity.x > constants.activeVelocity || velocity.y > constants.activeVelocity) {
                UIView.animate(withDuration: 1, animations: {
                    self.popupView.center = self.calculatePopupViewOffScreenCenter(from: velocity)
                    self.hide(animated: true)
                })
            } else {
                UIView.animate(withDuration: 0.5, animations: {
                    self.popupView.center = self.backgroundView.center
                })
            }
            break
        case .cancelled:
            UIView.animate(withDuration: 0, animations: {
                self.popupView.center = self.backgroundView.center
            })
            break
        default:
            break
        }
    }

    // MARK: Private
    
    private func calculatePopupViewOffScreenCenter(from velocity: CGPoint) -> CGPoint {
        var velocityX = velocity.x
        var velocityY = velocity.y
        var offScreenCenter = popupView.center

        velocityX = velocityX >= 0 ?
        (velocityX < constants.minVelocity ? 0 : velocityX):
            (velocityX > -constants.minVelocity ? 0 : velocityX)

        velocityY = velocityY >= 0 ?
        (velocityY < constants.minVelocity ? constants.minVelocity : velocityY):
            (velocityY > -constants.minVelocity ? -constants.minVelocity : velocityY)

        offScreenCenter.x += velocityX
        offScreenCenter.y += velocityY

        return offScreenCenter
    }



    private func roundBottomOfCoverView() {
        guard hasRoundCorners == true else {return}
        let roundCornersPath = UIBezierPath(roundedRect: CGRect(x: 0.0,
                                                                y: 0.0,
                                                                width: popupView.bounds.width,
                                                                height: coverView.frame.size.height),
                                            byRoundingCorners: [.bottomLeft, .bottomRight],
                                            cornerRadii: CGSize(width: 8.0,
                                                                height: 8.0))
        let roundLayer = CAShapeLayer()
        roundLayer.path = roundCornersPath.cgPath
        coverView.layer.mask = roundLayer
    }

    private func createViews() {
        popupView.backgroundColor = UIColor.clear
        backgroundView.addSubview(popupView)
        
        createCustomView(customView)

        popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.cd_centerHorizontally()
        popupView.cd_centerVertically()
        popupView.cd_setWidth(customView.bounds.width)
        popupView.sizeToFit()
        popupView.layoutIfNeeded()
    }

    private func createCustomView(_ custom: UIView) {
        custom.clipsToBounds = true
        
        popupView.addSubview(custom)
        
        custom.cd_centerVertically()
        custom.cd_centerHorizontally()
        custom.cd_setWidth(custom.frame.width)
        custom.cd_setHeight(custom.frame.height)
    }
}


internal extension UIView {
    func cd_alignToTop(of view: UIView, margin: CGFloat, multiplier: CGFloat) {
        self.superview!.addConstraint(NSLayoutConstraint(item: self,
                                                         attribute: .top,
                                                         relatedBy: .equal,
                                                         toItem: view,
                                                         attribute: .top,
                                                         multiplier: multiplier,
                                                         constant: margin))
    }

    func cd_alignTopToParent(with margin: CGFloat) {
        cd_alignToTop(of: self.superview!, margin: margin, multiplier: 1)
    }

    func cd_alignBottomToParent(with margin: CGFloat) {
        cd_alignToBottom(of: self.superview!, margin: margin)
    }

    func cd_alignToBottom(of view: UIView, margin: CGFloat) {
        self.superview!.addConstraint(NSLayoutConstraint(item: self,
                                                         attribute: .bottom,
                                                         relatedBy: .equal,
                                                         toItem: view,
                                                         attribute: .bottom,
                                                         multiplier: 1,
                                                         constant: -margin))
    }

    func cd_alignLeftToParent(with margin: CGFloat) {
        cd_alignToLeft(of: self.superview!, margin: margin)
    }

    func cd_alignToLeft(of view: UIView, margin: CGFloat) {
        self.superview!.addConstraint(NSLayoutConstraint(item: self,
                                                         attribute: .left,
                                                         relatedBy: .equal,
                                                         toItem: view,
                                                         attribute: .left,
                                                         multiplier: 1,
                                                         constant: margin))
    }

    func cd_alignRightToParent(with margin: CGFloat) {
        cd_alignToRight(of: self.superview!, margin: margin)
    }

    func cd_alignToRight(of view: UIView, margin: CGFloat) {
        self.superview!.addConstraint(NSLayoutConstraint(item: self,
                                                         attribute: .right,
                                                         relatedBy: .equal,
                                                         toItem: view,
                                                         attribute: .right,
                                                         multiplier: 1,
                                                         constant: -margin))
    }

    func cd_alignToParent(with margin: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        cd_alignTopToParent(with: margin)
        cd_alignLeftToParent(with: margin)
        cd_alignRightToParent(with: margin)
        cd_alignBottomToParent(with: margin)
    }

    func cd_setHeight(_ height: CGFloat) {
        self.addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: height))
    }

    func cd_setMaxHeight(_ height: CGFloat) {
        self.addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .height,
                                              relatedBy: .lessThanOrEqual,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: height))
    }

    func cd_setWidth(_ width: CGFloat) {
        self.addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: width))
    }

    func cd_centerHorizontally() {
        self.superview!.addConstraint(NSLayoutConstraint(item: self,
                                                         attribute: .centerX,
                                                         relatedBy: .equal,
                                                         toItem: self.superview,
                                                         attribute: .centerX,
                                                         multiplier: 1,
                                                         constant: 0))
    }

    func cd_centerVertically() {
        self.superview!.addConstraint(NSLayoutConstraint(item: self,
                                                         attribute: .centerY,
                                                         relatedBy: .equal,
                                                         toItem: self.superview,
                                                         attribute: .centerY,
                                                         multiplier: 1,
                                                         constant: 0))
    }

    func cd_place(below view: UIView, margin: CGFloat) {
        self.superview!.addConstraint(NSLayoutConstraint(item: self,
                                                         attribute: .top,
                                                         relatedBy: .equal,
                                                         toItem: view,
                                                         attribute: .bottom,
                                                         multiplier: 1,
                                                         constant: margin))
    }

    func cd_place(above view: UIView, margin: CGFloat) {
        self.superview!.addConstraint(NSLayoutConstraint(item: self,
                                                         attribute: .bottom,
                                                         relatedBy: .equal,
                                                         toItem: view,
                                                         attribute: .top,
                                                         multiplier: 1,
                                                         constant: margin))
    }
}
