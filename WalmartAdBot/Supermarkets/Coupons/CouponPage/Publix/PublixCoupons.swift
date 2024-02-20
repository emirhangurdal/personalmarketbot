
import Cocoa
import Foundation
import WebKit
import SwiftSoup
import FirebaseFirestore

class PublixCoupons: NSViewController, WKNavigationDelegate, WKScriptMessageHandler, NSWindowDelegate {
    
    override func viewDidLoad() {
        setupButtons()
        webView.navigationDelegate = self
        injectJavaScript()
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
    let firebaseSupport = FirebaseSupport()
    let openPanel = NSOpenPanel()
    let button = NSButton()
    let deleteData = NSButton()
    let support = PublixSupport()
    var urlTextField = NSTextField()
    var checkStatus = ""
    let saveHtml = SaveHTML()
    
    var bogoStatus = Bool()
    var firebaseStatus = Bool()
    //MARK: Button Actions
    var bogoCheck : NSButton = {
        let bttn = NSButton(checkboxWithTitle: "getBOGOs", target: self, action: #selector(checkBoxAction))
        return bttn
    }()
    
    var fireBaseCheck : NSButton = {
        let bttn = NSButton(checkboxWithTitle: "sendToFB(TaponlyFinish)", target: self, action: #selector(firebaseAction))
        return bttn
    }()
    
    @objc func checkBoxAction(_ sender: NSButton) {
 
        if sender.state == .on {
            bogoStatus = true
        } else {
            bogoStatus = false
        }
    }
    @objc func firebaseAction(_ sender: NSButton) {
        if sender.state == .on {
            firebaseStatus = true
        } else {
            firebaseStatus = false
        }
    }
    
    @objc func buttonAction() {
        let url = URL(string: urlTextField.stringValue)! //example: https://www.publix.com/savings/digital-coupons/bogo
        if bogoStatus == true {
            loadwithHeader()
        } else {
            webView.load(URLRequest(url: url))
        }
    }
    //MARK: Delete Coupons from Firebase
    @objc func deleteCouponsFromFirebase() {
        firebaseSupport.cleanStore(mainCategory: "Grocery", storeBrand: "Publix")
    }
    
    
    func loadwithHeader() {
        let url = URL(string: urlTextField.stringValue)!
        var request = URLRequest(url: url)
        
        // Set custom headers here
        request.addValue("https://www.publix.com/locations/519-cumming-400-shopping-center", forHTTPHeaderField: "referer")
        
        webView.load(request)
    }
    //MARK: - Inject JavaScript in Webview
    let script = """
        try {
            document.addEventListener('mousedown', function(event) {
                var element = event.target;
                var classes = element.className;
                if (classes.includes('button__label')) {
                    console.log("button clicked");
                var htmlContent = document.documentElement.outerHTML;
        window.webkit.messageHandlers.buttonClicked.postMessage(htmlContent);
                }
            });
        } catch (error) {
            console.error("Error occurred:", error);
        }
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
        
        webView.evaluateJavaScript(script) { (result, error) in
            if let error = error {
                print("Error injecting JavaScript: \(error)")
            }
        }
        if bogoStatus == false {
            
            webView.evaluateJavaScript("document.body.innerHTML;") { result, error in
                let html = result as? String, error = error
                self.scrapeBOGOs(htmlContent: html ?? "")
                
                let coupons = self.scrapeCoupon(htmlContent: html!)
                let couponsHtml = self.support.generatePublixCouponHtml(coupons: coupons)
                DispatchQueue.main.async {
                    self.saveHtml.saveFile(htmlString: couponsHtml)
                }
            }
        }
    }
    //MARK: - Listen - Load More Button new HTML
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if bogoStatus == true {
            if let htmlString = message.body as? String {
                DispatchQueue.main.async {
                    let coupons = self.scrapeBOGOs(htmlContent: htmlString)
                    let html = self.support.generatePublixBOGOHtml(coupons: coupons)
                    self.saveHtml.saveFile(htmlString: html)
                    
                }
                // Handle the updated HTML content here
            }
        } else {
            if let htmlString = message.body as? String {
                DispatchQueue.main.async {
                    let coupons = self.scrapeCoupon(htmlContent: htmlString)
                    let html = self.support.generatePublixCouponHtml(coupons: coupons)
                    self.saveHtml.saveFile(htmlString: html)
                    
                }
                // Handle the updated HTML content here
            }
        }
    }
    //MARK: - Functions to Get Html for Wordpress
    
    // for https://www.publix.com/savings/digital-coupons?nav=header - the url changes if you set different filters.
    func scrapeCoupon(htmlContent: String) -> [PublixCoupon] {
        var publixCoupons: [PublixCoupon] = []
        do {
            let doc: Document = try SwiftSoup.parse(htmlContent)
            
            // Find the element containing the product information
            let couponElement = try doc.select("div.p-grid-item")
            for coupon in couponElement {
                let randomUUID = UUID()
                let couponExp = try? coupon.select("span.expiration").text()
                let couponDesc = try? coupon.select("span.description").text()
                let imageLink = try? coupon.select("img").first()?.attr("src")
                let couponNumber = try? coupon.select("div.p-card.p-coupon-card").first()?.attr("data-item-code")
                let link = "https://www.publix.com/savings/digital-coupons?cid=\(couponNumber ?? "")"
                let publixCoupon = PublixCoupon(coupon: couponDesc ?? "", exp: couponExp ?? "", imageLink: imageLink ?? "")
                publixCoupons.append(publixCoupon)
                
                if firebaseStatus == true {
                    
                    self.firebaseSupport.sendToDatabase(image: imageLink!, title: couponDesc!, save: "", desc: "", exp: couponExp!, category: "Grocery", id: "\(randomUUID)", mainCategory: "Grocery", storeBrand: "Publix", link: link)
                    
                }
            }
            
        } catch {
            print("Error parsing HTML: \(error.localizedDescription)")
        }
        return publixCoupons
    }
    // for https://www.publix.com/savings/weekly-ad/bogo?nav=header - sign up in webview to filter out the sneak peek BOGOs.
    func scrapeBOGOs(htmlContent: String) -> [PublixBOGO] {
        var publixBOGO: [PublixBOGO] = []
        do {
            let doc: Document = try SwiftSoup.parse(htmlContent)
            
            // Find the element containing the product information
            let couponElement = try doc.select("div.p-grid-item")
            
            for coupon in couponElement {
                
                let title = try? coupon.select("span.p-text").first()?.text()
                let savingsBadge = try? coupon.select("span.p-savings-badge").first()?.text()
                let additionalInfo = try? coupon.select("span.additional-info").text()
                let validDate = try? coupon.select("span.valid-dates").text()
                let image = try? coupon.select("img").first()?.attr("src")
                let publixBOGOItem = PublixBOGO(title: title, savingsBadge: savingsBadge, validDate: validDate, image: image, additionalInfo: additionalInfo)
                publixBOGO.append(publixBOGOItem)
            }
            
        } catch {
            print("Error parsing HTML: \(error.localizedDescription)")
        }
        return publixBOGO
    }
    
    
    
    //MARK: - Constraints
    func setupButtons(){
        view.addSubview(button)
        view.addSubview(webView)
        view.addSubview(urlTextField)
        view.addSubview(bogoCheck)
        view.addSubview(fireBaseCheck)
        view.addSubview(deleteData)
        button.title = "Publix"
        button.bezelStyle = .rounded
        button.action = #selector(buttonAction)
        
        deleteData.title = "DeleteCouponsFirebase"
        deleteData.bezelStyle = .rounded
        deleteData.action = #selector(deleteCouponsFromFirebase)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100)
        ])
        
        deleteData.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteData.rightAnchor.constraint(equalTo: button.leftAnchor, constant: -10),
            deleteData.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        bogoCheck.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bogoCheck.leftAnchor.constraint(equalTo: button.rightAnchor, constant: 10),
            bogoCheck.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        fireBaseCheck.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fireBaseCheck.leftAnchor.constraint(equalTo: bogoCheck.rightAnchor, constant: 10),
            fireBaseCheck.centerYAnchor.constraint(equalTo: button.centerYAnchor)
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
