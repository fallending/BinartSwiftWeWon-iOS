//
//  MsgCell.swift
//  magpies
//
//  Created by Seven on 2020/8/3.
//  Copyright © 2020 lilithclient. All rights reserved.
//

import Foundation
import UIKit
#if canImport(MessageKit)
import MessageKit
#endif

open class NotifyCell: UICollectionViewCell {
    
    let label = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    open func setupSubviews() {
        contentView.addSubview(label)
        label.textAlignment = .center
        label.font = BAWeWon.notifyTextFont
        label.textColor = BAWeWon.notifyTextColor
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
    
    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        // Do stuff
        switch message.kind {
        case .notify(let data):
            guard let systemMessage = data as? String else { return }
            label.text = systemMessage
        default:
            break
        }
    }
    
}
