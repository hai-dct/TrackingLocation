//
//  SceneDelegate.swift
//  TrackingLocation
//
//  Created by Hai Nguyen H.P. [3] VN.Danang on 5/23/22.
//

import UIKit
import Swinject

let container = Container()

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var locationManager: LocationManager?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.makeKeyAndVisible()
        self.window = window
        setupContainer()
        configRoot()
        
        locationManager = container.resolve(LocationManager.self)
        locationManager?.request()
    }
    
    private func configRoot() {
        let vc = HomeViewController()
        vc.viewModel = DefaultHomeViewModel()
        window?.rootViewController = UINavigationController(rootViewController: vc)
    }
    
    private func setupContainer() {
        container.register(LocationManager.self) { _ in
            return LocationManager()
        }
    }
    
    private func trackingLocation() {
        guard let location = locationManager?.getCurrentLocation().map({
            Location(lat: $0.coordinate.latitude, long: $0.coordinate.longitude)
        }) else { return }
        Session.shared.locationsSaved = Session.shared.locationsSaved + [location]
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        trackingLocation()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        print("sceneDidBecomeActive", scene.activationState.rawValue)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        trackingLocation() // foreground
        print("sceneWillResignActive", scene.activationState.rawValue)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("sceneWillEnterForeground", scene.activationState.rawValue)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        trackingLocation() // background
        print("sceneDidEnterBackground", scene.activationState.rawValue)
    }


}

