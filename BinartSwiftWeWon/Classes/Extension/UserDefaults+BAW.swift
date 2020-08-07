//
//  UserDefaults+BAW.swift
//  BinartSwiftWeWon
//
//  Created by Seven on 2020/8/1.
//

import Foundation

extension UserDefaults {
    
    public static let messagesKey = "mockMessages"
    
    // MARK: Mock Messages
    
    open func setMockMessages(count: Int) {
        set(count, forKey: UserDefaults.messagesKey)
        synchronize()
    }
    
    open func mockMessagesCount() -> Int {
        if let value = object(forKey: UserDefaults.messagesKey) as? Int {
            return value
        }
        return 20
    }
    
    public static func isFirstLaunch() -> Bool {
        let hasBeenLaunchedBeforeFlag = "hasBeenLaunchedBeforeFlag"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}
