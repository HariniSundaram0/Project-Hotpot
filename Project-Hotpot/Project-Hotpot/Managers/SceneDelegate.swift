import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var apiInstance = SpotifyManager.shared()
    lazy var rootViewController = ConnectViewController()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.makeKeyAndVisible()
        window!.windowScene = windowScene
        window!.rootViewController = rootViewController
    }
    
    // For spotify authorization and authentication flow
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        let parameters = apiInstance.appRemote.authorizationParameters(from: url)
        if let code = parameters?["code"] {
            apiInstance.responseCode = code
        } else if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            apiInstance.accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            NSLog("No access token error =", error_description)
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        if let accessToken = apiInstance.appRemote.connectionParameters.accessToken {
            apiInstance.appRemote.connectionParameters.accessToken = accessToken
            apiInstance.appRemote.connect()
            
        } else if let accessToken = apiInstance.accessToken {
            apiInstance.appRemote.connectionParameters.accessToken = accessToken
            apiInstance.appRemote.connect()
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        if apiInstance.appRemote.isConnected {
            apiInstance.appRemote.disconnect()
        }
    }
}
