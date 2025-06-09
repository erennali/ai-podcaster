//
//  SceneDelegate.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import UIKit
import FirebaseAuth
import RevenueCat

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    static var loginUser: Bool = false
    private let themeKey = "selectedTheme"
    static let appLanguageName = Locale.current.localizedString(forLanguageCode: Locale.current.language.languageCode?.identifier ?? "en") ?? "English"

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let splashVC = SplashViewController()
        window.rootViewController = splashVC
        window.makeKeyAndVisible()
        
        // Apply saved theme
        applyTheme(to: window)
        
        let currentUser = Auth.auth().currentUser
        if currentUser != nil {
            SceneDelegate.loginUser = true
            
            // Kullanıcı oturum açmışsa, RevenueCat entegrasyonunu yapılandır
            configureRevenueCatForLoggedInUser()
        } 
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        Task {
            // Uygulama aktif olduğunda bildirim durumunu kontrol et ve gerekirse güncelle
            await NotificationManager.shared.handleNotificationStatusChange()
            
            NotificationCenter.default.post(name: .didReturnFromSettings, object: nil)
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
        // Uygulamaya geri dönüldüğünde kullanıcı kimliğini ve abonelik durumunu güncelleyelim
        if SceneDelegate.loginUser {
            configureRevenueCatForLoggedInUser()
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else {
            return
        }

        window.rootViewController = vc
        
        // Apply theme to the new root view controller's window
        applyTheme(to: window)

        if animated {
            UIView.transition(with: window,
                              duration: 0.4,
                              options: [.transitionCrossDissolve],
                              animations: nil,
                              completion: nil)
        }
    }
    
    // Temayı uygula
    private func applyTheme(to window: UIWindow) {
        let savedTheme = UserDefaults.standard.integer(forKey: themeKey)
        
        switch savedTheme {
        case 1:
            window.overrideUserInterfaceStyle = .light
        case 2:
            window.overrideUserInterfaceStyle = .dark
        default:
            window.overrideUserInterfaceStyle = .unspecified
        }
    }
    
    // Kullanıcı oturum açtığında RevenueCat entegrasyonunu yapılandır
    private func configureRevenueCatForLoggedInUser() {
        // Cache'i temizle ve fresh data al
        Purchases.shared.invalidateCustomerInfoCache()
        
        // IAPService'i yeniden yapılandır - bu, RevenueCat ile kullanıcı kimliğini eşleştirecek
        IAPService.shared.configure()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let authStateChanged = Notification.Name("authStateChanged")
}

