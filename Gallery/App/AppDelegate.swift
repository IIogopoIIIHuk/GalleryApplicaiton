
import UIKit
import RealmSwift


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

            let config = Realm.Configuration(
                schemaVersion: 1,
                migrationBlock: { _, oldSchemaVersion in
                    if oldSchemaVersion < 1 {
                        
                    }
                }
                
            )
            Realm.Configuration.defaultConfiguration = config
            _ = try! Realm()

            return true
        }

        // MARK: - UISceneSession Lifecycle
        func application(_ application: UIApplication,
                         configurationForConnecting connectingSceneSession: UISceneSession,
                         options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            UISceneConfiguration(name: "Default Configuration",
                                 sessionRole: connectingSceneSession.role)
        }

        func application(_ application: UIApplication,
                         didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }

}

