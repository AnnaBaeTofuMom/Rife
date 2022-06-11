//
//  SceneDelegate.swift
//  Rife - Simple Run Life
//
//  Created by 배경원 on 2021/11/17.
//

import UIKit
import ChannelIOFront

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var channelWindow: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        
        let nav = TabBarController()
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        guard let _ = (scene as? UIWindowScene) else { return }
        guard let windowScene = (scene as? UIWindowScene) else { return }
        channelWindow = ChannelIO.initializeWindow(with: windowScene)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) { }
    
    func sceneDidBecomeActive(_ scene: UIScene) { }
    
    func sceneWillResignActive(_ scene: UIScene) { }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        guard let start = UserDefaults.standard.object(forKey: "sceneDidEnterBackground") as? Date else { return }
        let interval = Int(Date().timeIntervalSince(start))
        NotificationCenter.default.post(name: NSNotification.Name("sceneWillEnterForeground"), object: nil, userInfo: ["time": interval])
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        NotificationCenter.default.post(name: NSNotification.Name("sceneDidEnterBackground"), object: nil)
        UserDefaults.standard.setValue(Date(), forKey: "sceneDidEnterBackground")
    }
}

