
import UIKit

// MARK: -

@objc
public protocol BACaptchaInputDelegate: class {
    func onCaptchaInputComplete(captchaInput: BACaptchaInput, didFinishInput captchaCode: String)
}

// MARK: -

@IBDesignable
open class BACaptchaInput: UIControl {
    
    /// 显示模式
    public enum DisplayType {
        case box
        case underlined
        case round
    }
    
    /// 输入模式
    public enum KeyboardType: Int {
        case numeric
        case alphabet
        case alphaNumeric
    }
    
    // 图片文件
    public enum SecureEntryDisplayType: String {
        case dot = "ic_dot"
        case star = "ic_star"
        case none = ""
    }
    
    // MARK: = 配置项
    
    open var fieldDisplayType: DisplayType = .underlined
    open var fieldInputType: KeyboardType = .numeric
    
    /// 安全输入的替代显示图标
    open var secureEntrySymbol: SecureEntryDisplayType = .none
    
    /// Define the font to be used to OTP field.
    @IBInspectable
    open var fieldFont: UIFont = UIFont.systemFont(ofSize: 20)
    
    /// For secure OTP entry set it to `true`.
    @IBInspectable
    open var isSecureEntry: Bool = false
    
    /// 是否需要光标
    @IBInspectable
    open var requireCursor: Bool = true
    
    /// 光标颜色
    @IBInspectable
    open var cursorColor: UIColor = .white
    
    /// 输入框间距
    @IBInspectable
    open var separatorSpace: CGFloat = 10
    
    /// 边框宽度
    @IBInspectable
    open var borderWidth: CGFloat = 2
    
    /// 无输入颜色
    @IBInspectable
    open var emptyFieldBorderColor: UIColor = UIColor(red: 84/255, green: 85/255, blue: 86/255, alpha: 1.0)
    
    /// 有输入颜色
    @IBInspectable
    open var enteredFieldBorderColor: UIColor = .white
    
    /// 特殊反馈颜色变化
    @IBInspectable
    open var feedbackColor: UIColor = UIColor(red: 236/255, green: 43/255, blue: 78/255, alpha: 1.0)
    
    
    /// 安全输入的替代显示图标颜色
    @IBInspectable
    open var secureEntrySymbolColor: UIColor = UIColor(red: 236/255, green: 43/255, blue: 78/255, alpha: 1.0)
    
    /// 文字颜色
    @IBInspectable
    open var textColor: UIColor = .white
    
    /// 验证码数目
	@IBInspectable open var fieldsCount: Int = 4 {
		didSet {
			setupUI()
		}
	}
    
    // MARK: =
    
	@IBOutlet open weak var delegate: BACaptchaInputDelegate?

    /// 验证码容器视图
	var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.distribution = .fillEqually
        stackView.alignment = .fill
		return stackView
	}()
    
    fileprivate var feedbackTriggerred: Bool = false

	fileprivate var items: [BACaptchaInputTextField] = []
	open var code: String {
		get {
			let items = stackView.arrangedSubviews.map({$0 as! BACaptchaInputTextField})
			let values = items.map({$0.text ?? ""})
			return values.joined()
		}
		set {
			let array = newValue.map(String.init)
			for i in 0..<fieldsCount {
				let item = stackView.arrangedSubviews[i] as! BACaptchaInputTextField
				item.text = i < array.count ? array[i] : ""
			}
			if !stackView.arrangedSubviews.compactMap({$0 as? UITextField}).filter({$0.isFirstResponder}).isEmpty {
				self.becomeFirstResponder()
			}
		}
	}

	override open func awakeFromNib() {
		super.awakeFromNib()
        
		setupUI()
	}
    
//    var isFirstInPage: Bool
//    open override func layoutSubviews() {
//        // 在子view中自动获取焦点，时机比较挑剔
//        if (autoFirstResponder) {
//            if let tf = stackView.arrangedSubviews.first as? BACaptchaInputTextField {
//                tf.perform(#selector(becomeFirstResponder), with: nil, afterDelay: 0.17)
//            }
//
//        }
//    }

    // 初始化UI
	fileprivate func setupUI() {
        stackView.spacing = separatorSpace
        
		if stackView.superview == nil {
			addSubview(stackView)
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.superview?.addConstraints([
                NSLayoutConstraint(item: stackView, attribute: .width, relatedBy: .equal, toItem: stackView.superview, attribute: .width, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: stackView, attribute: .height, relatedBy: .equal, toItem: stackView.superview, attribute: .height, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: stackView, attribute: .centerY, relatedBy: .equal, toItem: stackView.superview, attribute: .centerY, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: stackView, attribute: .centerX, relatedBy: .equal, toItem: stackView.superview, attribute: .centerX, multiplier: 1.0, constant: 0)
            ]);
		}
		stackView.arrangedSubviews.forEach{($0.removeFromSuperview())}

		for index in 0..<fieldsCount {
			let itemView = createInputTextField(forIndex: index)
			itemView.delegate = self

			stackView.addArrangedSubview(itemView)
		}
	}
    
    fileprivate func indexForTag(forIndex index: Int) -> Int {
        return index + 1
    }

	// 获取单个
    fileprivate func createInputTextField(forIndex index: Int) -> BACaptchaInputTextField {
        
        let hasOddNumberOfFields = (fieldsCount % 2 == 1)
        let txtWidth = (self.frame.width / CGFloat(fieldsCount)) - separatorSpace
        
        var fieldSize: CGFloat = 100
        
        if fieldSize > self.frame.height {
            fieldSize = self.frame.height
        }
        if txtWidth < fieldSize {
            fieldSize = txtWidth
        }
        var fieldFrame = CGRect(x: 0, y: 0, width: fieldSize, height: fieldSize)
        
//         If odd, then center of self will be center of middle field. If false, then center of self will be center of space between 2 middle fields.
        if hasOddNumberOfFields {
            // Calculate from middle each fields x and y values so as to align the entire view in center
            fieldFrame.origin.x = bounds.size.width / 2 - (CGFloat(fieldsCount / 2 - index) * (fieldSize + separatorSpace) + fieldSize / 2)
        } else {
            // Calculate from middle each fields x and y values so as to align the entire view in center
            fieldFrame.origin.x = bounds.size.width / 2 - (CGFloat(fieldsCount / 2 - index) * fieldSize + CGFloat(fieldsCount / 2 - index - 1) * separatorSpace + separatorSpace / 2)
        }
        
        fieldFrame.origin.y = (bounds.size.height - fieldSize) / 2
        
        let textField = BACaptchaInputTextField(frame: fieldFrame)
        textField.delegate = self
        textField.tag = indexForTag(forIndex: index)
        textField.font = fieldFont
        
        switch fieldInputType {
        case .numeric:
            textField.keyboardType = .numberPad
        case .alphabet:
            textField.keyboardType = .alphabet
        case .alphaNumeric:
            textField.keyboardType = .namePhonePad
        }
        
        if requireCursor {
            textField.tintColor = cursorColor
        } else {
            textField.tintColor = UIColor.clear
        }
        
        textField.initalizeUI(forFieldType: fieldDisplayType, normalBorderColor: emptyFieldBorderColor, highlightBorderColor: enteredFieldBorderColor)
        
        return textField
    }

	@discardableResult
	override open func becomeFirstResponder() -> Bool {
		let items = stackView.arrangedSubviews
			.map({$0 as! BACaptchaInputTextField})
		return (items.filter({($0.text ?? "").isEmpty}).first ?? items.last)!.becomeFirstResponder()
	}

	@discardableResult
	override open func resignFirstResponder() -> Bool {
		stackView.arrangedSubviews.forEach({$0.resignFirstResponder()})
		return true
	}

	override open func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		setupUI()
	}
    
    private func deleteText(in textField: UITextField) {
        if let lbl = self.viewWithTag(textField.tag + fieldsCount) as? UILabel {
            lbl.text = ""
        }
        
        textField.layer.borderColor = emptyFieldBorderColor.cgColor
        
        textField.becomeFirstResponder()
    }

    fileprivate func check() {
        let captchaCode = code
        if (captchaCode.count == fieldsCount) {
            delegate?.onCaptchaInputComplete(captchaInput: self, didFinishInput: captchaCode)
        }
    }
    
    // MARK: - Public Mehtods
    
    public func clear() {
        for index in stride(from: 0, to: fieldsCount, by: 1) {
            
            let textField = viewWithTag(index + 1) as? BACaptchaInputTextField
            
            self.deleteText(in: textField!)
        }
    }
    
    public func feedback () {
        // 如果没有输入完全，调用则没有效果
        if code.count < fieldsCount {
            return
        }
        
        // 默认方式用颜色
        stackView.arrangedSubviews.forEach {
            let t = $0 as! BACaptchaInputTextField
            
            t.textColor = feedbackColor
            t.borderView?.backgroundColor = feedbackColor
        }
        
        feedbackTriggerred = true
    }
    
    public func resetFeedback () {
        // 默认方式用颜色
        stackView.arrangedSubviews.forEach {
            let t = $0 as! BACaptchaInputTextField
            
            t.textColor = textColor
            
            if ((t.text?.count) != nil) {
                t.borderView?.backgroundColor = enteredFieldBorderColor
            } else {
                t.borderView?.backgroundColor = emptyFieldBorderColor
            }
        }
        
        feedbackTriggerred = false
    }
}

// MARK: - UITextFieldDelegate & BACaptchaTextFieldDelegate

extension BACaptchaInput: UITextFieldDelegate {
    
	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        NSLog("变更内容："+string)
        
        if string.hasSuffix("\n") {
            return false;
        }

		if string == "" { //is backspace
            if feedbackTriggerred {
                resetFeedback()
            }
            
			return true
		}
        
        let replacedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        
        // Check since only alphabet keyboard is not available in iOS
        if !replacedText.isEmpty && fieldInputType == .alphabet && replacedText.rangeOfCharacter(from: .letters) == nil {
            return false
        }
        
        if feedbackTriggerred {
            resetFeedback()
        }
        
        if replacedText.count > 1 {
            return false
        }
        
        /// 只处理单个输入
        if replacedText.count == 1 {
   
            if isSecureEntry {
                
                let fullString = NSMutableAttributedString(string: "")
                let imageAttachment = NSTextAttachment()
                if secureEntrySymbol != .none {
                    textField.text = "M"
                    textField.textColor = textColor
                } else {
                    textField.text = string
                    textField.textColor = textColor
                }
                let origImage = UIImage(named: secureEntrySymbol.rawValue)
                let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                if #available(iOS 13.0, *) {
                    imageAttachment.image = tintedImage
                } else {
                    imageAttachment.image = tintedImage?.imageWithColor(color: .red)
                }
                imageAttachment.bounds = CGRect(x: 0, y: 0, width: (textField.text?.widthOfString(usingFont: fieldFont) ?? 0), height: (textField.text?.widthOfString(usingFont: fieldFont) ?? 0))
                let imageString = NSAttributedString(attachment: imageAttachment)
                fullString.append(imageString)
                if let lbl = self.viewWithTag(textField.tag + fieldsCount) as? UILabel, secureEntrySymbol != .none {
                    
                    lbl.textAlignment = .center
                    if secureEntrySymbol != .none {
                        lbl.attributedText = fullString
                    }
                    if #available(iOS 13.0, *) {
                        lbl.textColor = secureEntrySymbolColor
                    }
                }
            } else {
                textField.text = string
                textField.textColor = textColor
            }
            
            if let txt = viewWithTag(textField.tag) as? BACaptchaInputTextField, fieldDisplayType == .underlined {
                
                txt.highlight(animated: true)
            }
            
            let nextOTPField = viewWithTag(textField.tag + 1)
            
            if let nextOTPField = nextOTPField {
                nextOTPField.becomeFirstResponder()
            } else {
//                textField.resignFirstResponder()
                
                // 检查是否已填充满
                check()
            }
        }
        /// 退格处理
        else {
            
            let currentText = textField.text ?? ""
            
            if textField.tag > 1 && currentText.isEmpty {
                
                if let prevOTPField = viewWithTag(textField.tag - 1) as? UITextField {
                    deleteText(in: prevOTPField)
                }
            } else {
                deleteText(in: textField)
                
                if textField.tag > 1 {
                    if let prevOTPField = viewWithTag(textField.tag - 1) as? UITextField {
                        prevOTPField.becomeFirstResponder()
                    }
                }
            }
        }
        
        return false
	}
}

extension String {

    func widthOfString(usingFont font: UIFont) -> CGFloat {
        
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

extension UIImage {
    
    func imageWithColor(color:UIColor) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height);
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.clip(to: rect, mask: self.cgImage!)
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let imageFromCurrentContext = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImage(cgImage: imageFromCurrentContext!.cgImage!, scale: 1.0, orientation:.downMirrored)
    }
}
