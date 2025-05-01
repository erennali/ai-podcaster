//
//  TabBarController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import UIKit
import SnapKit
import AI_Podcaster

class TabBarController: UITabBarController {

    //MARK: Properties

    //MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabs()
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
            viewController: LibraryViewController()
        )
       
        let profileVC = createNav(
            with: "Profile",
            and: UIImage(systemName: "gear"),
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
