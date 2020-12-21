import Foundation
import UIKit

public enum BADirection {
    case toLeft
    case toRight
    case toTop
    case toBottom
    case toBottomLeft
    case toBottomRight
    case toTopLeft
    case toTopRight
}

public extension UIButton {
    class func TextButton (title: String, action: Selector, target: Any, font: CGFloat, background: UIColor) -> UIButton {
        let b = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40));
        b.setTitleColor(UIColor.white, for:.normal);
        b.setTitle(title, for: .normal);
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20);
        
        b.addTarget(target, action: action, for: .touchUpInside);
        
        return b;
    }
    
    
    func setGradientBackgroundColors(_ colors: [UIColor], direction: BADirection) {
        assert(colors.count>1)
        
        let highlightedColors: [UIColor] = []
//        colors.forEach {
//            highlightedColors.append($0.transparenter())
//        }
        setGradientBackgroundColors(colors, direction: direction, for: .normal)
        setGradientBackgroundColors(highlightedColors, direction: direction, for: .highlighted)
    }
    
    /// Button should be Custom not System
    func setGradientBackgroundColors(_ colors: [UIColor], direction: BADirection, for state: UIControl.State) {
        assert(colors.count==2)
        
        setBackgroundImage(UIImage(size: CGSize(width: 1, height: 1), direction: direction, colors: colors), for: state)
    }
}
