import UIKit
import Foundation
import Kingfisher

// http://andelf.github.io/blog/2014/06/06/swift-operator-overload/

// 运算符重载
//operator
//prefix 前缀运算符，比如 （取正+、取负- 、自增++、自减–）
//postfix 后缀运算符，比如（自增++、自减–），这两可以前缀也可以后缀
//infix 中缀，最常见二元运算
//precedence 优先级的意思，取值 0~255 ，纯数字，不可以带符号，下划线，指数e/p 表示
//associativity 结合性，可以是 left, right, 或者 none

infix operator <>
infix operator >>
infix operator <<

// MARK: - Double direction binding

func <> (value: LiveData<String>, label: UILabel) -> Void {
    value.on {[weak label] (txt) in
        // 0. label会被该闭包持有
        // 1. 该闭包会被持有
        // 2. value会被VM持有
        // 3. VM会被VC持有
        // 4. label 会被 VC持有
        label?.text = txt
    }
}
    
// MARK: - Right bind to left

/// UILabel 单向绑定
func >> (value: LiveData<String>, label: UILabel) -> Void {
    value.on {[weak label] (txt) in
        // 0. label会被该闭包持有
        // 1. 该闭包会被持有
        // 2. value会被VM持有
        // 3. VM会被VC持有
        // 4. label 会被 VC持有
        label?.text = txt
    }
}

func >> (value: LiveData<String>, button: UIButton) -> Void {
    value.on {[weak button] (txt) in
        button?.setTitle(txt, for: UIControl.State.normal)
    }
}

/// UITableView 单向绑定
func >> <T: Any>(value: LiveData<[T]>, tableView: UITableView) -> Void {
    value.on {[weak tableView] (data) in
        tableView?.reloadData()
    }
}

/// UICollectionView 单向绑定
func >> <T: Any>(value: LiveData<[T]>, collectionView: UICollectionView) -> Void {
    value.on {[weak collectionView] (data) in
        collectionView?.reloadData()
    }
}

/// UIImageView 单向绑定
func >> (value: LiveData<URL>, iv: UIImageView) {
    value.on {[weak iv] (url) in
        iv?.kf.setImage(with: url)
    }
}

func >> (value: LiveData<String>, iv: UIImageView) {
    value.on {[weak iv] (url) in
        if let url = url {
            iv?.kf.setImage(with: URL(string: url))
        }
    }
}

func >> (value: LiveData<Bool>, uiSwitch: UISwitch) -> Void {
    value.on {[weak uiSwitch] (isOn) in
        uiSwitch?.setOn(isOn ?? false, animated: false)
    }
}
    
// MARK: - Left bind to right

func << (value: LiveData<String>, label: UILabel) -> Void {
    value.on {[weak label] (txt) in
        // 0. label会被该闭包持有
        // 1. 该闭包会被持有
        // 2. value会被VM持有
        // 3. VM会被VC持有
        // 4. label 会被 VC持有
        label?.text = txt
    }
}
