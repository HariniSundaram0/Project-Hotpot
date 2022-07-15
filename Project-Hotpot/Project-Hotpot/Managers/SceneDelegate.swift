import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var api_instance = SpotifyManager.shared()
    lazy var rootViewController = ConnectViewController()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.makeKeyAndVisible()
        window!.windowScene = windowScene
        window!.rootViewController = rootViewController
    }

    // For spotify authorization and authentication flow
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        let parameters = api_instance.appRemote.authorizationParameters(from: url)
        if let code = parameters?["code"] {
            api_instance.responseCode = code
        } else if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            api_instance.accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            NSLog("No access token error =", error_description)
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if let accessToken = api_instance.appRemote.connectionParameters.accessToken {
            api_instance.appRemote.connectionParameters.accessToken = accessToken
            api_instance.appRemote.connect()
        
        } else if let accessToken = api_instance.accessToken {
            api_instance.appRemote.connectionParameters.accessToken = accessToken
            api_instance.appRemote.connect()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if api_instance.appRemote.isConnected {
            api_instance.appRemote.disconnect()
        }
    }
}
