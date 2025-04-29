//
//  ProfileViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if SceneDelegate.loginUser == false {
            RegisterViewController()
        }
    }
    



}
