
import Cocoa
import Foundation
import WebKit
import FirebaseFirestore
import Firebase

class KrogerCoupons: NSViewController, WKNavigationDelegate, NSWindowDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
   
    let productLabel : NSTextField = {
        let label = NSTextField()
        
        label.isEditable = false
        label.isBezeled = false
        label.drawsBackground = false
        label.maximumNumberOfLines = 0

        // Set font and text color if needed
        label.font = NSFont.systemFont(ofSize: 13.0)
        label.textColor = NSColor.white
        
        return label
    }()
    let firebaseSupport = FirebaseSupport()
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
    
    var productSearchText = NSTextField()
    let savePanel = NSSavePanel()
    let openPanel = NSOpenPanel()
    let button = NSButton()
    
    let couponButton = NSButton()
    let deleteData = NSButton()
    let krogerAPI = KrogerAPI()
    var cookie = String()
    let locationId = "01100318"
    let parse = ParseJson()
    let supporting = Support()
    var couponBrand = "kroger"
    let startingNumber = 0
    var firebaseStatus = Bool()
    
    var store = "Kroger"
    //MARK: - Check Boxes for Brands
    var firebaseCheck : NSButton = {
        let bttn = NSButton(checkboxWithTitle: "Firebase", target: self, action: #selector(checkBoxAction))
        return bttn
    }()
    var ralphsCheck : NSButton = {
        let bttn = NSButton(checkboxWithTitle: "ralphs", target: self, action: #selector(checkBoxAction))
        return bttn
    }()
    var fredMeyerCheck : NSButton = {
        let bttn = NSButton(checkboxWithTitle: "fredmeyer", target: self, action: #selector(checkBoxAction))
        return bttn
    }()
    var frysCheck : NSButton = {
        let bttn = NSButton(checkboxWithTitle: "frysfood", target: self, action: #selector(checkBoxAction))
        return bttn
    }()
    var kingSoopersCheck : NSButton = {
        let bttn = NSButton(checkboxWithTitle: "kingsoopers", target: self, action: #selector(checkBoxAction))
        return bttn
    }()
    var harrisTeeterCheck : NSButton = {
        let bttn = NSButton(checkboxWithTitle: "harristeeter", target: self, action: #selector(checkBoxAction))
        return bttn
    }()
    
    //MARK: Button Actions
    @objc func buttonAction() {
        let term = productSearchText.stringValue
        
        krogerAPI.getAdId { weeklyAdId in
            for ad in weeklyAdId! {
                let adId = ad.id
                if ad.previewCircular == true {
                    DispatchQueue.main.async {
                        self.productLabel.stringValue = "Start: \(ad.eventStartDate) \n End \(ad.eventEndDate)"
                    }
                    
                    self.krogerAPI.getWeeklyAd(id: adId!) { weeklyad in
                        let htmlToSave = self.supporting.weeklyAdHtml(weeklyAd: weeklyad)
                        
                        DispatchQueue.main.async {
                            self.saveFile(htmlString: htmlToSave)
                        }
                    }
                }
            }
        }
    }
    var i = 1
    
    @objc func deleteDataAction() {
//        firebaseSupport.cleanStore(mainCategory: "Grocery", storeBrand: store)
        firebaseSupport.cleanStore(mainCategory: "Grocery", storeBrand: store)
    }
    
    //MARK: - Check Box Actions
    @objc func checkBoxAction(_ sender: NSButton) {
       
        if sender.state == .on {
            firebaseStatus = true
            if sender.title != "Firebase" {
                couponBrand = sender.title
            }
            
            switch couponBrand {
            case "ralphs":
                store = "Ralphs"
            case "fredmeyer":
                store = "Fred Meyer"
            case "frysfood":
                store = "Fry's"
            case "kingsoopers":
                store = "King Soopers"
            case "harristeeter":
                store = "Harris Teeter"
            default:
                store = "Kroger"
            }
            print("couponBrand: \(couponBrand)")
        } else {
            firebaseStatus = false
            store = "Kroger"
            couponBrand = "kroger"
            print(couponBrand)
        }
    }
    
    @objc func couponsJson(){
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["json"]
        openPanel.begin { (result) in
            if result == .OK, let fileURL = self.openPanel.urls.first {
                var cpns = [KrogerCoupon]()
                self.parse.parseJSONKroger(fileURL: fileURL) { coupons in
                    print("store: \(self.store)")
                    let coupons = coupons.data?.couponData?.coupons
                    let htmlfile = self.supporting.couponHtml(firebaseStatus: self.firebaseStatus, store: self.store, brand: self.couponBrand, coupons: coupons!)
                    self.saveFile(htmlString: htmlfile)
                    
                }
            }
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.innerHTML;") { result, error in
            let html = result as? String, error = error
            
        }
    }
    
    //MARK: - Constraints
    
    func setupButtons(){
        
        view.addSubview(button)
        view.addSubview(couponButton)
        view.addSubview(ralphsCheck)
        view.addSubview(fredMeyerCheck)
        view.addSubview(frysCheck)
        view.addSubview(kingSoopersCheck)
        view.addSubview(harrisTeeterCheck)
        view.addSubview(productSearchText)
        view.addSubview(deleteData)
        view.addSubview(productLabel)
        view.addSubview(webView)
        view.addSubview(firebaseCheck)
        
        button.title = "KrogerWeeklyAd"
        button.bezelStyle = .rounded
        button.action = #selector(buttonAction)
        
        deleteData.title = "deleteData"
        deleteData.bezelStyle = .rounded
        deleteData.action = #selector(deleteDataAction)
        
        couponButton.title = "Coupons"
        couponButton.bezelStyle = .rounded
        couponButton.action = #selector(couponsJson)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        couponButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            couponButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            couponButton.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 10)
        ])
        ralphsCheck.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ralphsCheck.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ralphsCheck.topAnchor.constraint(equalTo: couponButton.bottomAnchor, constant: 10)
        ])
        fredMeyerCheck.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fredMeyerCheck.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fredMeyerCheck.topAnchor.constraint(equalTo: ralphsCheck.bottomAnchor, constant: 10)
        ])
        frysCheck.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            frysCheck.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            frysCheck.topAnchor.constraint(equalTo: fredMeyerCheck.bottomAnchor, constant: 10)
        ])
        kingSoopersCheck.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            kingSoopersCheck.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            kingSoopersCheck.topAnchor.constraint(equalTo: frysCheck.bottomAnchor, constant: 10)
        ])
        harrisTeeterCheck.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            harrisTeeterCheck.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            harrisTeeterCheck.topAnchor.constraint(equalTo: kingSoopersCheck.bottomAnchor, constant: 10)
        ])
        firebaseCheck.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            firebaseCheck.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firebaseCheck.topAnchor.constraint(equalTo: harrisTeeterCheck.bottomAnchor, constant: 10)
        ])
        productSearchText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            productSearchText.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -10),
            productSearchText.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            productSearchText.widthAnchor.constraint(equalToConstant: view.frame.size.width - 30),
            productSearchText.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        deleteData.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteData.leftAnchor.constraint(equalTo: productSearchText.rightAnchor, constant: 5),
            deleteData.bottomAnchor.constraint(equalTo: productSearchText.bottomAnchor),
            deleteData.topAnchor.constraint(equalTo: productSearchText.topAnchor)

        ])
        productLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            productLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            productLabel.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -10),
            productLabel.widthAnchor.constraint(equalToConstant: view.frame.size.width - 10),  // Adjust width as needed
            productLabel.heightAnchor.constraint(equalToConstant: view.frame.size.height/2)
        ])
    }
    //MARK: - Save File
    func saveFile(htmlString: String) {
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "KrogerCoupons\(Date()).html"
        // Set an initial directory URL
        let initialDirectoryURL = FileManager.default.homeDirectoryForCurrentUser
        savePanel.directoryURL = initialDirectoryURL
        savePanel.begin { result in
            if result == NSApplication.ModalResponse.OK, let url = self.savePanel.url {
                // Save the file at the selected URL
                self.supporting.saveHTMLStringToFile(htmlString, at: url)
            }
        }
    }
}

extension WKWebView {
    
    private var httpCookieStore: WKHTTPCookieStore  { return WKWebsiteDataStore.default().httpCookieStore }
    
    func getCookies(for domain: String? = nil, completion: @escaping ([String : Any])->())  {
        var cookieDict = [String : AnyObject]()
        httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if let domain = domain {
                    if cookie.domain.contains(domain) {
                        cookieDict[cookie.name] = cookie.properties as AnyObject?
                    }
                } else {
                    cookieDict[cookie.name] = cookie.properties as AnyObject?
                }
            }
            completion(cookieDict)
        }
    }
}
