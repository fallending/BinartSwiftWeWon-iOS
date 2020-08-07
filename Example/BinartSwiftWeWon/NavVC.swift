//
//  NavVC.swift
//  BinartSwiftWeWon_Example
//
//  Created by Seven on 2020/8/1.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import BinartSwiftWeWon

final class NavVC: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return viewControllers.last?.preferredStatusBarStyle ?? .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .white
        navigationBar.barTintColor = BAWeWon.themeColor
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        if #available(iOS 11.0, *) {
            navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        }
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        view.backgroundColor = BAWeWon.themeColor
    }
    
    func setAppearanceStyle(to style: UIStatusBarStyle) {
        if style == .default {
            navigationBar.shadowImage = UIImage()
            navigationBar.barTintColor = BAWeWon.themeColor
            navigationBar.tintColor = .white
            navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            if #available(iOS 11.0, *) {
                navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            }
        } else if style == .lightContent {
            navigationBar.shadowImage = nil
            navigationBar.barTintColor = .white
            navigationBar.tintColor = UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)
            navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
            if #available(iOS 11.0, *) {
                navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
            }
        }
    }

}
