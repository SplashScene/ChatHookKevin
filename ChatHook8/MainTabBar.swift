//
//  MainTabBar.swift
//  ChatHook
//
//  Created by Kevin Farm on 8/22/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit

class MainTabBar: UITabBarController {
    
    var registerViewController = FinishRegisterController()
    var introViewController = IntroViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        //set up our custom view controllers
        
        
        let mapViewController = GetLocation1()
        let messagesViewController = MessagesController()
        let postsViewController = RoomsViewController()
        let profileViewController = ProfileViewController()
        let chatNavController = UINavigationController(rootViewController: messagesViewController)
        let postsNavController = UINavigationController(rootViewController: postsViewController)
        let profileNavController = UINavigationController(rootViewController: profileViewController)
        
        
        mapViewController.title = "Home"
        mapViewController.tabBarItem.image = UIImage(named: "GlobeIcon25")
        
        messagesViewController.title = "Chat"
        messagesViewController.tabBarItem.image = UIImage(named: "ChatIcon25")
        
        postsViewController.title = "Posts"
        postsViewController.tabBarItem.image = UIImage(named: "peeps")
        
        profileViewController.title = "Profile"
        profileViewController.tabBarItem.image = UIImage(named: "ProfileIcon25")
        
        
        viewControllers = [mapViewController, chatNavController, postsNavController, profileNavController]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBar.barTintColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
