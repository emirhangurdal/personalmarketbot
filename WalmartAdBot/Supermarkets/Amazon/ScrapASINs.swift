import SwiftSoup
import Foundation
import Cocoa
import WebKit

class ScrapASINs: NSViewController, WKNavigationDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
        webView.navigationDelegate = self
    }
    var urlTextField = NSTextField()
    let amazon = Amazon()
    let saveHTML = SaveHTML()
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
    var checkStatus = String()
    let button = NSButton()
    let buttonCarousel = NSButton()
    let scrapCoupons = ScrapCoupons()
    
    @objc func scrapAction(){
        let urlString = urlTextField.stringValue
        let url = URL(string: urlString)

        webView.load(URLRequest(url: url!))
        checkStatus = "scrapAction"
    }
    @objc func carouselAction(){
        let urlString = urlTextField.stringValue
        let url = URL(string: urlString)
        
        webView.load(URLRequest(url: url!))
        checkStatus = "carouselAction"
    }
    
    func setupButton(){
        view.addSubview(button)
        view.addSubview(webView)
        view.addSubview(urlTextField)
        view.addSubview(buttonCarousel)
        
        button.title = "Scrap"
        button.bezelStyle = .rounded
        button.action = #selector(scrapAction)
        
        buttonCarousel.title = "CarouselDeals"
        buttonCarousel.bezelStyle = .rounded
        buttonCarousel.action = #selector(carouselAction)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100)
        ])
        buttonCarousel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonCarousel.leftAnchor.constraint(equalTo: button.rightAnchor, constant: 10),
            buttonCarousel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100)
        ])
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor), // Attach to the top of the view
            webView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -10)
        ])
        
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            urlTextField.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 10),
            urlTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            urlTextField.widthAnchor.constraint(equalToConstant: view.frame.size.width - 10),
            urlTextField.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.innerHTML;") { result, error in
            let html = result as? String, error = error
            if self.checkStatus == "scrapAction" {
                self.scrapCoupons.scrapAmazonCoupons(html: html!)
            } else if self.checkStatus == "carouselAction" {
                self.scrapCoupons.scrapSpecialDealsCarousel(html: html!) { data in
                    
                    let htmlTosave = self.amazon.createHTMLStringforAmazonCarousel(from: data!)
                    
                    self.saveHTML.saveFile(htmlString: htmlTosave)
                }
            }
        }
    }
    
}
