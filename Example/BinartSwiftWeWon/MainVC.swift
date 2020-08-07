//
//  MainVC.swift
//  BinartSwiftWeWon_Example
//
//  Created by Seven on 2020/8/1.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import BinartSwiftWeWon

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {

    @IBOutlet var tableView: UITableView!
    
    private lazy var groupArray = [BAWChat]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = BAWeWon.themeColor
        
        tableView.register(BAWChatCell.self, forCellReuseIdentifier: BAWChatCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
//        tableView.select
        
        /////
        BAWGroupAvatar.baseUrl = "http://ww1.sinaimg.cn/small/"
        BAWGroupAvatar.placeholderImage = UIImage(named: "avatarholder")!
        
        BAWGroupAvatar.groupAvatarType = .WeChat
        BAWGroupAvatar.distanceBetweenAvatar = 2
        
        groupArray.removeAll()
        
        let array: [String] = [
            "006tNc79gy1g5fmoexlt6j30u00vxqrb.jpg",
            "006tNc79gy1g5fmofi07aj30u00uwqqk.jpg",
            "006tNc79gy1g5fln5crn5j30u00u00vh.jpg",
            "006tNc79gy1g5fln52xz8j30u00u0411.jpg",
            "006tNc79gy1g5fmtvyydxj30u00u0x6r.jpg",
            "006tNc79gy1g5fmogr9fsj30u00uz4m9.jpg",
            "006tNc79gy1g5fmogcjidj30u00wc7su.jpg",
            "006tNc79gy1g5fmofvp9cj30u00w8kft.jpg",
            "006tNc79gy1g5fmofvp9cj30u00w8kft.jpg",
            "006tNc79gy1g5fln52xz8j30u00u0411.jpg",
            "006tNc79gy1g5fln5crn5j30u00u00vh.jpg",
            "006tNc79gy1g5fli2qszgj30ku0ii0ua.jpg",
            "006tNc79gy1g5fli1g0wtj30rs0rs416.jpg",
            "006tNc79gy1g5fli2zfzwj30qo0qojvv.jpg",
            "006tNc79gy1g5fli3fr0oj30u00u2goh.jpg",
            "006tNc79gy1g56or92vvmj30u00u048a.jpg",
            "006tNc79gy1g56mcmorgrj30rk0nm0ze.jpg",
            "006tNc79gy1g57h4j42ppj30u00u00vy.jpg"
        ];
        
        for i in 0..<9 {
            let item = BAWChat()
            
            item.title = "GroupedAvatar-\(i+1)"
            
            // 1～9
            let groupSource = Array(array[0..<(i+1)])
            item.avatarSource = groupSource
            
            item.detail = "我我我我我哦wowfasfasfasf"
            
            item.badge = 99
            
            item.hint = "星期六"
            
            groupArray.append(item)
        }
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
        navigationController?.pushViewController(ExampleMsgsVC(), animated: true)
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        return true
    }
    
    // MARK: = UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BAWChatCell.reuseIdentifier) as? BAWChatCell

        cell!.data = groupArray[indexPath.row]
        cell!.selectionStyle = .none
        
//        print(cell!.description)
        
        return cell!
    }
    
    // ???
//    ①正确做法是在 prepareForReuse 中重置所有 subview 的显示属性为 nil，例如 UIImageView.image 和 UILabel.attributedText。
//    ②偷懒做法是在 customUpdate 中对所有 subview 的显示属性进行赋值。
    
    
    // MARK: = UITableViewDataSourcePrefetching
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
    }
}
