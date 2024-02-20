
import Cocoa
import Foundation
import WebKit
import SwiftSoup

class CVSCoupons: NSViewController, WKNavigationDelegate, NSWindowDelegate, WKScriptMessageHandler {
    
    override func viewDidLoad() {
        setupButtons()
        webView.navigationDelegate = self
        
    }
    override func viewWillAppear() {
        super.viewWillAppear()
        self.view.window?.delegate = self
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        var frame = self.view.window!.frame
        let initialSize = NSSize(width: 750, height: 500)
        frame.size = initialSize
        self.view.window?.setFrame(frame, display: true)
    }

    let saveHtml = SaveHTML()
    let openPanel = NSOpenPanel()
    let button = NSButton()
    let deleteData = NSButton()
    let sendtoFirebase = NSButton()
    var urlTextField = NSTextField()
    let firebaseSupport = FirebaseSupport()
    let cvsAPI = CVSAPI()
    var firebaseStatus = Bool()
    @objc func buttonAction() {
//        let url = URL(string: urlTextField.stringValue)!
        cvsAPI.callAPI(firebaseStatus: false)
    }
    @objc func deleteDataAction() {
        firebaseSupport.cleanStore(mainCategory: "Pharmacy", storeBrand: "CVS")
    }
    @objc func sendtoFirebaseAction() {
        cvsAPI.callAPI(firebaseStatus: true)
    }
    
  
    
    //MARK: - Webview Configs.
    let webView: WKWebView = {
        let pagePrefs = WKWebpagePreferences()
        pagePrefs.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        configuration.defaultWebpagePreferences = pagePrefs
        let webview = WKWebView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), configuration: configuration)
        return webview
    }()
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish")
        
        webView.evaluateJavaScript("document.body.innerHTML;") { result, error in
            let html = result as? String, error = error
           
        }
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if let htmlString = message.body as? String {
      
        }
    }
    
   
    
    //MARK: - Constraints
    func setupButtons() {
        view.addSubview(button)
        view.addSubview(urlTextField)
        view.addSubview(sendtoFirebase)
        view.addSubview(deleteData)
        
        button.title = "CVS Coupons"
        button.bezelStyle = .rounded
        button.action = #selector(buttonAction)
        
        sendtoFirebase.title = "SendToFB"
        sendtoFirebase.bezelStyle = .rounded
        sendtoFirebase.action = #selector(sendtoFirebaseAction)
        
        deleteData.title = "DeleteFB"
        deleteData.bezelStyle = .rounded
        deleteData.action = #selector(deleteDataAction)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
     
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            urlTextField.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 10),
            urlTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            urlTextField.widthAnchor.constraint(equalToConstant: view.frame.size.width - 10),
            urlTextField.heightAnchor.constraint(equalToConstant: 30)
        ])
        sendtoFirebase.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sendtoFirebase.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendtoFirebase.topAnchor.constraint(equalTo: urlTextField.bottomAnchor, constant: 10)
        ])
        deleteData.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteData.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteData.topAnchor.constraint(equalTo: sendtoFirebase.bottomAnchor, constant: 10)
        ])
        
    }
    
}
