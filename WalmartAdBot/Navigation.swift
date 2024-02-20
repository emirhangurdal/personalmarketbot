import Cocoa

class NavigationController {
    private var windowControllers: [NSWindowController] = []
    
    func pushViewController(_ viewController: NSViewController) {
        let window = NSWindow(contentViewController: viewController)
        let windowController = NSWindowController(window: window)
        windowControllers.append(windowController)
        window.makeKeyAndOrderFront(nil)
    }
    
    func popViewController() {
        guard !windowControllers.isEmpty else { return }
        windowControllers.removeLast()
        
        if let previousWindowController = windowControllers.last {
            previousWindowController.window?.makeKeyAndOrderFront(nil)
        }
    }
}
