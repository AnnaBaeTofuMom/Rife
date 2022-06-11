//
//  OpensourceViewController.swift
//  Rife - Simple Run Life
//
//  Created by 배경원 on 2021/11/29.
//

import UIKit

class OpensourceViewController: UIViewController {
    var libraryArr: [String] = ["Alamofire", "ChannelIOSDK", "Kingfisher", "MarqueeLabel", "NotificationBannerSwift", "Realm", "SideMenu", "Snapkit", "SwiftyJSON","IQKeyboardManager"]
    var urlArr: [String] = ["Elegant HTTP Networking in Swift", "For smooth communication with user and developer", "Easy image caching from web", "Make a beautiful streaming label", "Simple notification banner for Swift", "Embedded object-oriented database", " Customizable side menu for Swift", "For easy auto-layout", "Make it easy to deal with JSON data in Swift", "sliding up and down keyboard without issues"]
    var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension OpensourceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 83
    }
}

extension OpensourceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        libraryArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
