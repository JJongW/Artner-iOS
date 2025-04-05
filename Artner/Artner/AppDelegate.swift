//
//  AppDelegate.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

// AppDelegate.swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        let docentListVC = DocentListViewController()
        let navVC = UINavigationController(rootViewController: docentListVC)
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()

        return true
    }
}
