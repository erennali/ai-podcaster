//
//  TabBarController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import UIKit
import SnapKit


class TabBarController: UITabBarController {

   

    //MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabs()
        customizeTabBarAppearance()
    }
    
}

    //MARK: - Private Methods

private extension TabBarController {
    //CTRL-M
    func setupTabs () {
        let homeVC = createNav(
            with: "Home",
            and: UIImage(systemName: "house.fill"),
            viewController: PodcastsViewController()
        )
        let searchVC = createNav(
            with: "Search",
            and: UIImage(systemName: "magnifyingglass"),
            viewController: SearchViewController()
        )
        let createrPodcast = createNav(
            with: "Create Podcast",
            and: UIImage(systemName: "plus.square"),
            viewController: CreaterPodcastsViewController()
        )
        let libraryVC = createNav(
            with: "Library",
            and: UIImage(systemName: "music.note"),
            viewController: PodcastsViewController()
        )
       
        let profileVC = createNav(
            with: "Profile",
            and: UIImage(systemName: "person.crop.circle.fill"),
            viewController: ProfileViewController()
        )
        
        if SceneDelegate.loginUser == false {
            let registerVC = createNav(
                with: "Register",
                and: UIImage(systemName: "person.fill"),
                viewController: RegisterViewController()
            )
            setViewControllers([homeVC, searchVC, createrPodcast, libraryVC, registerVC], animated: false)
        } else {
            setViewControllers([homeVC,searchVC, createrPodcast,libraryVC, profileVC], animated: false)
        }
        
    }
    
    func customizeTabBarAppearance() {
        //TabBar rengi
        UITabBar.appearance().tintColor = UIColor(red: 0.3, green: 0.3, blue: 0.8, alpha: 1.0)
    }
    
    func createNav(
        with title : String,
        and image : UIImage?,
        viewController : UIViewController
    ) -> UINavigationController {
        let controller = UINavigationController(rootViewController: viewController)
        controller.tabBarItem.title = title
        controller.tabBarItem.image = image
        viewController.title = title
        controller.navigationBar.prefersLargeTitles = true
        viewController.navigationItem.largeTitleDisplayMode = .always
        return controller
    }
}
