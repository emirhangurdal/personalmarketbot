
import Cocoa
import FirebaseCore
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        print("applicationDidFinishLaunching")
        FirebaseApp.configure()
    }
    private func setupNavigation() {
           // Create an instance of the NavigationController
           let navigationController = NavigationController()

           // Push the initial view controller(s) you want to start with
           let initialViewController = MainView()
           // Setup initialViewController as needed
           navigationController.pushViewController(initialViewController)
       }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

