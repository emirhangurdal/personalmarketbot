import SwiftSoup
import Foundation
import Cocoa
import WebKit
import FirebaseAuth

class CouponPage: NSViewController, WKNavigationDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
       
        print("user = \(Auth.auth().currentUser)")
    }
    let loginFB = NSButton()
    let krogerCoupon = KrogerCoupons()
    let walgreensButton = NSButton()
    let krogerButton = NSButton()
    let publixButton = NSButton()
    let albertsonsButton = NSButton()
    let cvsButton = NSButton()
    let meijerButton = NSButton()
    
    @objc func meijerAction(){
        performSegue(withIdentifier: "GotoMeijer", sender: self)
    }
    
    @objc func walgreensAction(){
        
        performSegue(withIdentifier: "GoToWalgreens", sender: self)
        
    }
    @objc func krogerAction() {
        
        performSegue(withIdentifier: "GoToKroger", sender: self)

    }
    
    @objc func publixAction() {
        
        performSegue(withIdentifier: "GoToPublixCoupons", sender: self)

    }
    @objc func albertsonsAction() {
        
        performSegue(withIdentifier: "goToAlbertsons", sender: self)

    }
    
    @objc func cvsAction(){
        
        performSegue(withIdentifier: "goToCVS", sender: self)
        
    }
    
    @objc func loginFBAction(){
        
        if Auth.auth().currentUser == nil {
            Auth.auth().signIn(withEmail: "emirhangurdal@gmail.com", password: "wtawta1!") { result, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                if result?.user != nil {
                    print("logged in as \(result?.user.email)")
                    DispatchQueue.main.async {
                        self.loginFB.title = "Logout"
                        self.loginFB.bezelStyle = .rounded
                        self.loginFB.action = #selector(self.logoutAction)
                    }
                }
            }
        }
    }
    func changeLoginButton() {
        if Auth.auth().currentUser != nil {
            loginFB.title = "Logout"
            loginFB.bezelStyle = .rounded
            loginFB.action = #selector(logoutAction)
        } else {
            loginFB.title = "Login"
            loginFB.bezelStyle = .rounded
            loginFB.action = #selector(loginFBAction)
        }
    }
    @objc func logoutAction() {
        do {
            try Auth.auth().signOut()
            loginFB.title = "Login"
            loginFB.bezelStyle = .rounded
            loginFB.action = #selector(loginFBAction)
        } catch let signOutError as NSError {
            loginFB.title = "Logout"
            loginFB.bezelStyle = .rounded
            loginFB.action = #selector(logoutAction)
        }
    }
    
    func setupButton(){
        view.addSubview(walgreensButton)
        view.addSubview(krogerButton)
        view.addSubview(publixButton)
        view.addSubview(albertsonsButton)
        view.addSubview(cvsButton)
        view.addSubview(loginFB)
        view.addSubview(meijerButton)
        changeLoginButton()
        
        walgreensButton.title = "Walgreens"
        walgreensButton.bezelStyle = .rounded
        walgreensButton.action = #selector(walgreensAction)
        
        cvsButton.title = "CVS"
        cvsButton.bezelStyle = .rounded
        cvsButton.action = #selector(cvsAction)
        
        krogerButton.title = "Kroger"
        krogerButton.bezelStyle = .rounded
        krogerButton.action = #selector(krogerAction)
        
        publixButton.title = "Publix"
        publixButton.bezelStyle = .rounded
        publixButton.action = #selector(publixAction)
        
        albertsonsButton.title = "Albertsons"
        albertsonsButton.bezelStyle = .rounded
        albertsonsButton.action = #selector(albertsonsAction)
        
        meijerButton.title = "Meijer"
        meijerButton.bezelStyle = .rounded
        meijerButton.action = #selector(meijerAction)
        
        cvsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cvsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cvsButton.bottomAnchor.constraint(equalTo: albertsonsButton.topAnchor, constant: -10)
        ])
        
        loginFB.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginFB.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginFB.topAnchor.constraint(equalTo: view.topAnchor, constant: 5)
        ])
        
        albertsonsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            albertsonsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            albertsonsButton.bottomAnchor.constraint(equalTo: walgreensButton.topAnchor, constant: -10)
        ])
        
        walgreensButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            walgreensButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            walgreensButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
        ])
        krogerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            krogerButton.topAnchor.constraint(equalTo: walgreensButton.bottomAnchor, constant: 10),
            krogerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        publixButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            publixButton.topAnchor.constraint(equalTo: krogerButton.bottomAnchor, constant: 10),
            publixButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        meijerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            meijerButton.topAnchor.constraint(equalTo: publixButton.bottomAnchor, constant: 10),
            meijerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}
