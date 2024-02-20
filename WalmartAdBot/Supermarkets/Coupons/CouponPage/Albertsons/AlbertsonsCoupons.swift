
import Cocoa
import Foundation
import WebKit
import SwiftSoup

class AlbertsonsCoupons: NSViewController, WKNavigationDelegate, NSWindowDelegate, WKScriptMessageHandler {
    
    override func viewDidLoad() {
        setupButtons()
        webView.navigationDelegate = self
        injectJavaScript()
        urlTextField.stringValue = "https://www.albertsons.com/foru/coupons-deals.html"
        
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
    
    var albertsonsDomain = "https://www.albertsons.com"
    let https = "https:"
    let saveHtml = SaveHTML()
    let openPanel = NSOpenPanel()
    let button = NSButton()
    var urlTextField = NSTextField()
    let support = AlbertsonsSupport()
    let deleteData = NSButton()
    let firebaseSupport = FirebaseSupport()
    var firebaseStatus = Bool()
    var store = "Albertsons"
    let manualPullAtTheEnd = NSButton()
    @objc func buttonAction() {
        let url = URL(string: urlTextField.stringValue)!
        webView.load(URLRequest(url: url))
    }
    //MARK: - Check Boxes
    var firebaseCheck : NSButton = {
        let bttn = NSButton(checkboxWithTitle: "firebase", target: self, action: #selector(fireBaseAction))
        return bttn
    }()
    
    @objc func fireBaseAction(_ sender: NSButton) {
        if sender.state == .on {
            firebaseStatus = true
        } else {
            firebaseStatus = false
        }
    }
    var htmlString: String?
    @objc func manualAction() {
        let html = UserDefaults.standard.string(forKey: "albertsonCoupons")
        let coupons = self.scrapeCoupons(htmlContent: html!)
        let htmlToSave = self.support.couponHtml(store: self.store ,firebaseStatus: self.firebaseStatus, albertsonsDomain: self.albertsonsDomain, imageDomain: self.https, coupons: coupons)
        self.saveHtml.saveFile(htmlString: htmlToSave)
    }
    
    var safewayCheck : NSButton = {
        let bttn = NSButton(checkboxWithTitle: "safeway", target: self, action: #selector(checkerAction))
        return bttn
    }()
    var jeweloscoCheck : NSButton = {
        let bttn = NSButton(checkboxWithTitle: "jewelosco", target: self, action: #selector(checkerAction))
        return bttn
    }()
    var vonsCheck : NSButton = {
        let bttn = NSButton(checkboxWithTitle: "vons", target: self, action: #selector(checkerAction))
        return bttn
    }()
    @objc func checkerAction(_ sender: NSButton) {
        if sender.state == .on {
            if sender.title == "jewelosco" {
                store = "Jewel-Osco"
            } else if sender.title == "safeway" {
                store = "Safeway"
            }
            
            albertsonsDomain = "https://www.\(sender.title).com"
        } else {
            store = "Albertsons"
            albertsonsDomain = "https://www.albertsons.com"
        }
    }
    @objc func deleteDataAction() {
        firebaseSupport.cleanStore(mainCategory: "Grocery", storeBrand: store)
    }
    
    //MARK: - JavaScript Code to Inject
    let script = """
    function checkForButton() {
        var loadMoreButton = document.querySelector('.load-more');
        if (loadMoreButton && !loadMoreButton.hasEventListener) {
            loadMoreButton.hasEventListener = true; // Flag to indicate the event listener has been added
            loadMoreButton.addEventListener('click', function(event) {
                console.log("Load more button clicked");
                var htmlContent = document.documentElement.outerHTML;
                window.webkit.messageHandlers.buttonClicked.postMessage(htmlContent);
            });
        }
    }

    // Check for the button every 500 milliseconds
    var checkInterval = setInterval(checkForButton, 500);

    """
    func injectJavaScript() {
        webView.configuration.userContentController.add(self, name: "buttonClicked")
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(userScript)
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
        
        webView.evaluateJavaScript(script) { (result, error) in
            if let error = error {
                print("Error injecting JavaScript: \(error)")
            }
        }
        webView.evaluateJavaScript("document.body.innerHTML;") { result, error in
            let html = result as? String, error = error
            
            DispatchQueue.main.async {
                let coupons = self.scrapeCoupons(htmlContent: html!)
                
                let htmlToSave = self.support.couponHtml(store: self.store ,firebaseStatus: self.firebaseStatus, albertsonsDomain: self.albertsonsDomain, imageDomain: self.https, coupons: coupons)
                self.saveHtml.saveFile(htmlString: htmlToSave)
            }
           
        }
    }
    //MARK: Load More Message is new html
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if let htmlString = message.body as? String {
            
            DispatchQueue.main.async {
                UserDefaults.standard.set(htmlString, forKey: "albertsonCoupons")
//                let coupons = self.scrapeCoupons(htmlContent: htmlString)

//                let htmlToSave = self.support.couponHtml(store: self.store, firebaseStatus: self.firebaseStatus, albertsonsDomain: self.albertsonsDomain, imageDomain: self.https, coupons: coupons)
//
//                self.saveHtml.saveFile(htmlString: htmlToSave)
                
            }
        }
    }
    
    //MARK: - Scrape Coupons
    func scrapeCoupons(htmlContent: String) -> [AlbertsonsCoupon] {
        var albertsonCpns = [AlbertsonsCoupon]()
        do {
            let doc: Document = try SwiftSoup.parse(htmlContent)
            
            let couponElement = try doc.select("div.grid-coupon-container")
            
            for coupon in couponElement {
                
                let dealTitle = try? coupon.select("span.grid-coupon-heading-offer-price").first?.text()
                let limit = try? coupon.select("span.grid-coupon-details-expiration").first?.text()
                let exp = try? coupon.select("span.grid-coupon-details-expiration-date").first?.text()
                let couponTitle = try? coupon.select("span.grid-coupon-description-text-title").text()
                let productDetail = try? coupon.select("div.grid-coupon-description-text-details > div").text()
                let linkElement = try? coupon.select("div.grid-coupon-description-text-details > span > a.grid-coupon-details-link")
                let linkPath = try? linkElement?[0].attr("href")
                let selectionImage = try? coupon.select("div.grid-coupon-description-image-wrapper > span > picture > source")
                let imageURL = try? selectionImage?[1].attr("srcset")
               
                
                let aCpn = AlbertsonsCoupon(dealTitle: dealTitle,
                                            couponTitle: couponTitle,
                                            limit: limit, exp: exp,
                                            productDetail: productDetail,
                                            linkPath: linkPath,
                                            imageURL: imageURL)
                albertsonCpns.append(aCpn)
                print(albertsonCpns)
                
            }
            
        } catch {
            print("Error parsing HTML: \(error.localizedDescription)")
            
        }
        return albertsonCpns
    }
    
    //MARK: - Constraints
    func setupButtons(){
        view.addSubview(button)
        view.addSubview(webView)
        view.addSubview(urlTextField)
        view.addSubview(safewayCheck)
        view.addSubview(jeweloscoCheck)
        view.addSubview(deleteData)
        view.addSubview(firebaseCheck)
        view.addSubview(manualPullAtTheEnd)
        
        button.title = "AlbertsonsCoupons"
        button.bezelStyle = .rounded
        button.action = #selector(buttonAction)
        
        deleteData.title = "DeleteDataFB"
        deleteData.bezelStyle = .rounded
        deleteData.action = #selector(deleteDataAction)
        
        firebaseCheck.title = "SendToFirebase(onlyfinished)"
        firebaseCheck.bezelStyle = .rounded
        firebaseCheck.action = #selector(fireBaseAction)
        
        manualPullAtTheEnd.title = "Manual Pull Coupons"
        manualPullAtTheEnd.bezelStyle = .rounded
        manualPullAtTheEnd.action = #selector(manualAction)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100)
        ])
        
        deleteData.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteData.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 10),
            deleteData.leftAnchor.constraint(equalTo: button.rightAnchor, constant: 10)
        ])
        
        manualPullAtTheEnd.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            manualPullAtTheEnd.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 10),
            manualPullAtTheEnd.leftAnchor.constraint(equalTo: deleteData.rightAnchor, constant: 10)
        ])
        
        firebaseCheck.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            firebaseCheck.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 10),
            firebaseCheck.rightAnchor.constraint(equalTo: button.leftAnchor, constant: -10)
        ])
        
        safewayCheck.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            safewayCheck.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            safewayCheck.topAnchor.constraint(equalTo: urlTextField.bottomAnchor, constant: 10)
        ])
        jeweloscoCheck.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            jeweloscoCheck.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            jeweloscoCheck.topAnchor.constraint(equalTo: safewayCheck.bottomAnchor, constant: 10)
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
    
}
