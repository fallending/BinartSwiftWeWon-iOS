//
//  MainVC.swift
//  BinartSwiftWeWon_Example
//
//  Created by Seven on 2020/8/1.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import BinartSwiftWeWon

class MainVC: UIViewController {

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: = UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
       
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        return true
    }
    
    // MARK: = UITableViewDataSource
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return groupArray.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: BAWChatCell.reuseIdentifier) as? BAWChatCell
//
//        cell!.data = groupArray[indexPath.row]
//        cell!.selectionStyle = .none
//
////        print(cell!.description)
//
//        return cell!
//    }
    
    // ???
//    ①正确做法是在 prepareForReuse 中重置所有 subview 的显示属性为 nil，例如 UIImageView.image 和 UILabel.attributedText。
//    ②偷懒做法是在 customUpdate 中对所有 subview 的显示属性进行赋值。

}
