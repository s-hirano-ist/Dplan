//
//  AppDelegate.swift
//  DraPla05
//
//  Created by S.Hirano on 2019/08/09.
//  Copyright © 2019 Sola_studio. All rights reserved.
//

import UIKit
import Material
import IQKeyboardManagerSwift
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var myNavigationController: UINavigationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // MARK: REALMデータベースのパスを表示
        print(Realm.Configuration.defaultConfiguration.fileURL!)

        // MARK: デフォルトはプレミア状態（広告無効化）
        UserDefaults.standard.register(defaults: ["premiumFeatures" : true])

        // MARK: 起動画面（同意後）
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = SideFabMenuView(rootViewController: SideCollectionView())
        self.window?.makeKeyAndVisible()

        // MARK: for keyboard not hiding textView
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true

        UserDefaults.standard.register(defaults: ["isFirstTime" : true])
        
        // MARK: DEBUG
        UserDefaults.standard.set(true, forKey: "isFirstTime")

        if UserDefaults.standard.bool(forKey:"isFirstTime") == true {
            DispatchQueue.main.async {
                let view = FirstScrollView()
                view.modalPresentationStyle = .fullScreen
                self.window?.rootViewController?.present(view, animated: false, completion:nil)
            }
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
