
import Cocoa
import Foundation
import WebKit
import SwiftSoup

class MeijerCoupons: NSViewController, WKNavigationDelegate, NSWindowDelegate {
    
    override func viewDidLoad() {
        setupButtons()
        
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
    var firebaseStatus = Bool()
    let meijerAPI = MeijerAPI()
    
    @objc func buttonAction() {
        meijerAPI.callAPI()
    }
    @objc func deleteDataAction() {
      
    }
    @objc func sendtoFirebaseAction() {
      
    }
    
    
    //MARK: - Constraints
    func setupButtons() {
        view.addSubview(button)
        view.addSubview(urlTextField)
        view.addSubview(sendtoFirebase)
        view.addSubview(deleteData)
        
        button.title = "Meijer Coupons"
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
