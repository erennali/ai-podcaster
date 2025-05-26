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
            with: NSLocalizedString("HomeTabBar", comment: "Home tab title"),
            and: UIImage(systemName: "house.fill"),
            viewController: HomeViewController()
        )
        let searchVC = createNav(
            with: NSLocalizedString("ChatTabBar", comment: "Chat tab title"),
            and: UIImage(systemName: "ellipsis.message.fill"),
            viewController: ChatAIViewController()
        )
        let createrPodcast = createNav(
            with: NSLocalizedString("CreatePodcastTabBar", comment: "Create podcast tab title"),
            and: UIImage(systemName: "plus.square"),
            viewController: CreaterPodcastsViewController()
        )
        let libraryVC = createNav(
            with: NSLocalizedString("LibraryTabBar", comment: "Library tab title"),
            and: UIImage(systemName: "music.note"),
            viewController: PodcastsViewController()
        )
       
        let profileVC = createNav(
            with: NSLocalizedString("ProfileTabBar", comment: "Profile tab title"),
            and: UIImage(systemName: "person.crop.circle.fill"),
            viewController: ProfileViewController()
        )
        
        if SceneDelegate.loginUser == false {
            let registerVC = createNav(
                with: NSLocalizedString("RegisterTabBar", comment: "Register tab title"),
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
        UITabBar.appearance().tintColor = UIColor(named: "anaTemaRenk")
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
