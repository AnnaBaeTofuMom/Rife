//
//  TabBarController.swift
//  Rife - Simple Run Life
//
//  Created by 경원이 on 2022/06/11.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let tabOne = UINavigationController(rootViewController: ChartViewController()) // 네비게이션 컨트롤러 없는 뷰컨트롤러
        //탭바를 아름답게 꾸며주겠습니다. 타이틀도 넣어주고 이미지도 넣어줍니다.
        let tabOneBarItem = UITabBarItem(title: "", image: UIImage(named: "chart_icon")?.withRenderingMode(.alwaysOriginal), tag: 0)
        tabOne.tabBarItem = tabOneBarItem
        
        let tabTwo = UINavigationController(rootViewController: RecordsViewController()) // 뷰컨 품은 네비게이션 컨트롤러
        let tabTwoBarItem = UITabBarItem(title: "", image: UIImage(named: "record_icon")?.withRenderingMode(.alwaysOriginal), tag: 1)
        tabTwo.tabBarItem = tabTwoBarItem
        
        let tabThree = UINavigationController(rootViewController: MapViewController())
        let tabThreeBarItem = UITabBarItem(title: "", image: UIImage(named: "home_icon")?.withRenderingMode(.alwaysOriginal), tag: 2)
        tabThree.tabBarItem = tabThreeBarItem
        
        let tabFour = UINavigationController(rootViewController: ProfileViewController())
        let tabFourBarItem = UITabBarItem(title: "", image: UIImage(named: "profile_icon")?.withRenderingMode(.alwaysOriginal), tag: 3)
        tabFour.tabBarItem = tabFourBarItem
        
        //탭바컨트롤러에 뷰 컨트롤러를 array형식으로 넣어주면 탭바가 완성됩니다.
        self.viewControllers = [tabOne, tabTwo, tabThree, tabFour]
        
    }
}

extension TabBarController: UITabBarControllerDelegate {
    
}
