import SwiftSoup
import Foundation
import Cocoa
import WebKit


class WalgreensCoupons: NSViewController, WKNavigationDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
        webView.navigationDelegate = self
    }
    
    let supporting = WalgreensSupporting()
    let walgreensAPI = WalgreensAPI()
    let webView: WKWebView = {
        let prefs = WKPreferences()
        prefs.javaScriptEnabled = true
        let pagePrefs = WKWebpagePreferences()
        pagePrefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.preferences = prefs
        config.defaultWebpagePreferences = pagePrefs
        let webview = WKWebView()
        
        return webview
    }()
    let button = NSButton()
    let sendToFirebase = NSButton()
    let clean = NSButton()
    let scrapCoupons = ScrapCoupons()
    let firebaseSupport = FirebaseSupport()
    @objc func scrapAction(){
        
//        let url = URL(string: "https://www.walgreens.com/offers/offers.jsp")!
//        webView.load(URLRequest(url: url))
        walgreensAPI.callApi(send: false)
    }
    @objc func sendToFirebaseAction(){
        
//        let url = URL(string: "https://www.walgreens.com/offers/offers.jsp")!
//        webView.load(URLRequest(url: url))
        walgreensAPI.callApi(send: true)
    }
    @objc func cleanAction(){
        
        firebaseSupport.cleanStore(mainCategory: "Pharmacy", storeBrand: "Walgreens")
    }
    
    func setupButton(){
        view.addSubview(button)
        view.addSubview(webView)
        view.addSubview(sendToFirebase)
        view.addSubview(clean)
        
        button.title = "Scrap"
        button.bezelStyle = .rounded
        button.action = #selector(scrapAction)
        
        clean.title = "Clean"
        clean.bezelStyle = .rounded
        clean.action = #selector(cleanAction)
        
        sendToFirebase.title = "Send To FB"
        sendToFirebase.bezelStyle = .rounded
        sendToFirebase.action = #selector(sendToFirebaseAction)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 70)
        ])
        sendToFirebase.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sendToFirebase.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendToFirebase.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 10)
        ])
        clean.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clean.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clean.topAnchor.constraint(equalTo: sendToFirebase.bottomAnchor, constant: 10)
        ])
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor), // Attach to the top of the view
            webView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -10)
        ])
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.innerHTML;") { result, error in
            let html = result as? String
            
        }
    }
    
   
   
    
}
