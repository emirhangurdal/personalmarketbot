

import Cocoa
import Foundation

class MainView: NSViewController {
    let openPanel = NSOpenPanel()
    let savePanel = NSSavePanel()
    let convert = Convert()
    let button = NSButton()
    let button2 = NSButton()
    let button3 = NSButton()
    let button4 = NSButton()
    let button5 = NSButton()
    let button6 = NSButton()
    let button7 = NSButton()
    let button8 = NSButton()
    
    let amazonClass = Amazon()
    let amazon = AmazonAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    //MARK: - PANEL FUNCTIONS
    @objc func setupPanel() {
     
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["json"] // Specify the file types you want to allow
        openPanel.begin { (result) in
            if result == .OK, let fileURL = self.openPanel.urls.first {
                ParseJson.shared.parseJSON(fileURL: fileURL) { (deals: [Deal]) in
//                    self.saveFile(htmlString: self.createHTMLStringTableWalmart(from: deals))
                    self.saveFile(htmlString: self.createHTMLStringWalmart(from: deals))
                }
            }
        }
    }
    
    @objc func setupPanelAssets(){
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["json", "csv"]
        openPanel.begin { (result) in
            if result == .OK, let fileURL = self.openPanel.urls.first {
                ParseJson.shared.parseJSON(fileURL: fileURL) { (assets: [Asset]) in
                    self.saveFile(htmlString: self.createHTMLStringforAsset(from: assets))
                }
            }
        }
    }
    //MARK: - Amazon Panel
    var fileName = String()
    @objc func amazonDealPanel(){
        
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["json"]
        
        openPanel.begin { (result) in
            if result == .OK, let fileURL = self.openPanel.urls.first {
                self.fileName = fileURL.lastPathComponent
                ParseJson.shared.parseJSONAmazon(fileURL: fileURL) { deals in
                    self.parameterPassAmazon(jsonString: "ItemsResult", deals: deals)
                }
            }
        }
    }
    func parameterPassAmazon(jsonString: String, deals: [String : SearchResult]){
        if let deals = deals[jsonString] {
            let data = deals.Items!
            saveFile(htmlString: amazonClass.createHTMLStringforAmazon(from: data))
        }
    }
    //MARK: - Go to Amazon Scrap Page
    
    @objc func button6Action(){
        
        performSegue(withIdentifier: NSStoryboardSegue.Identifier("GoToScrapASINs"), sender: nil)
    }
    
    
    //MARK: - BlackFriday.com Download Image Bots
    @objc func button5Action(){
        performSegue(withIdentifier: NSStoryboardSegue.Identifier("Gotodownload"), sender: nil)
    }
    
    
    //MARK: - Handle File for Plain Html Walmart Product List
    func handleSelectedFilePlain(at fileURL: URL) {
        // Process the selected file
        print(fileURL)
        ParseJson.shared.parseJSON(fileURL: fileURL) { (deals: [Deal]) in
            self.saveFile(htmlString: self.createHTMLStringWalmart(from: deals))
        }
    }
    //MARK: - Walmart Products
    
    func createHTMLStringTableWalmart(from deals: [Deal]) -> String {
        var htmlString = """
            <html>
            <head>
            <style>
            table {
              border-collapse: collapse;
              width: 100%;
            }
            
            th, td {
              text-align: left;
              padding: 8px;
              border-bottom: 1px solid #ddd;
            }
            
            th {
              background-color: #f2f2f2;
            }
            </style>
            </head>
            <body>
            <h2>Deals</h2>
            <table>
              <tr>
                <th>Name</th>
                <th>Price</th>
                <th>Ad</th>
              </tr>
        """
        for deal in deals {
            if let name = deal.name, let price = deal.price, let ad = deal.ad {
                let linkPattern = #"(?<=href=")[^"]+(?=")""#
                let regex = try! NSRegularExpression(pattern: linkPattern, options: [])
                let matches = regex.matches(in: ad, options: [], range: NSRange(ad.startIndex..., in: ad))
                var adLinkURL = ""
                
                if let match = matches.first {
                    if let urlRange = Range(match.range, in: ad) {
                        adLinkURL = String(ad[urlRange])
                    }
                }
                
                htmlString += "<tr>"
                htmlString += "<td><a href=\"\(adLinkURL)\">\(name)</a></td>"
                htmlString += "<td>\(price)</td>"
                htmlString += "<td>\(ad)</td>"
                htmlString += "</tr>"
            }
        }
        
        htmlString += """
            </table>
            </body>
            </html>
        """
        print(htmlString)
        return htmlString
    }
    
    func createHTMLStringWalmart(from deals: [Deal]) -> String {
        var htmlString = """
            <html>
            <head>
            <style>
            .deal {
                margin-bottom: 20px;
                border: 1px solid #ddd;
                padding: 10px;
            }
            </style>
            </head>
            <body>
            <h2>Deals</h2>
        """
        
        for deal in deals {
            if let name = deal.name, let price = deal.price, let ad = deal.ad {
                let linkPattern = #"(?<=href=")[^"]+(?=")""#
                let regex = try! NSRegularExpression(pattern: linkPattern, options: [])
                let matches = regex.matches(in: ad, options: [], range: NSRange(ad.startIndex..., in: ad))
                var adLinkURL = ""
                
                if let match = matches.first {
                    if let urlRange = Range(match.range, in: ad) {
                        adLinkURL = String(ad[urlRange])
                    }
                }
                
                htmlString += "<div class=\"deal\">"
                htmlString += "<p> <a href=\"\(adLinkURL)\">\(name)</a> - \(price)</p>"
                htmlString += "<p>\(ad)</p>"
                htmlString += "</div>"
            }
        }
        
        htmlString += """
            </body>
            </html>
        """
        
        
        return htmlString
    }
   
    
    //MARK: - Assets
    func createHTMLStringforAsset(from assets: [Asset]) -> String {
        var htmlString = """
            <html>
            <head>
            <style>
            table {
                border-collapse: collapse;
                width: 100%;
            }
            
            th, td {
                text-align: left;
                padding: 8px;
                border-bottom: 1px solid #ddd;
            }
            tr  {
                        margin-bottom: 10px;
                }
            
            th {
                background-color: #f2f2f2;
            }
            </style>
            </head>
            <body>
            <h2>Assets</h2>
            <table>
              <tr>
                <th>Deal</th>
                <th>Ad Type</th>
                <th>Dates</th>
              </tr>
        """
        
        for item in assets {
            let startDate = formatDate(item.LimitedTimeStartDate!)
            let endDate = formatDate(item.LimitedTimeEndDate!)
            
            htmlString += "<tr>"
            htmlString += "<td><a href=\"\(item.TrackingLink!)\">\(item.Name!)</a></td>"
            //            if item.Name != item.Description {
            //                htmlString += "<td>\(item.Description!)</td>"
            //            } else {
            //                "<td> - </td>"
            //            }
            htmlString += "<td>\(item.AdType!)</td>"
            htmlString += "<td>\(startDate) - \(endDate)</td>"
            htmlString += "</tr>"
        }
        
        htmlString += """
            </table>
            </body>
            </html>
        """
        
        print(htmlString)
        return htmlString
    }
    
    func formatDate(_ dateString: String) -> String {
        let dateFormatterInput = DateFormatter()
        dateFormatterInput.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Input date format
        
        let dateFormatterOutput = DateFormatter()
        dateFormatterOutput.dateFormat = "MM/dd/yy" // Desired output date format
        
        if let date = dateFormatterInput.date(from: dateString) {
            return dateFormatterOutput.string(from: date)
        } else {
            return "-"
        }
    }
    
    
    //MARK: - Save HTML File
    func saveHTMLStringToFile(_ htmlString: String, at fileURL: URL) {
        do {
            try htmlString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("File saved successfully at: \(fileURL.path)")
        } catch {
            print("Error saving file: \(error)")
        }
    }
    
    func saveFile(htmlString: String){
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "\(fileName).html"
        // Set an initial directory URL
        let initialDirectoryURL = FileManager.default.homeDirectoryForCurrentUser
        savePanel.directoryURL = initialDirectoryURL
        savePanel.begin { result in
            if result == NSApplication.ModalResponse.OK, let url = self.savePanel.url {
                // Save the file at the selected URL
                
                self.saveHTMLStringToFile(htmlString, at: url)
            }
        }
    }
    //MARK: - Go TO Coupons
    @objc func button7Action() {
        performSegue(withIdentifier: NSStoryboardSegue.Identifier("GoToCouponPage"), sender: nil)
    }
    //MARK: - Go to PDF to JPG
    @objc func button8Action() {
        
        performSegue(withIdentifier: NSStoryboardSegue.Identifier("goToPDF"), sender: nil)
        
    }
    
  

    
    //: MARK: - SETUPS
    
    func setupButton(){
        
        button.title = "Make Walmart List"
        button.bezelStyle = .rounded
        button.action = #selector(setupPanel)
        
        button2.title = "Make Product List"
        button2.bezelStyle = .rounded
        
        button3.title = "Asset Ads - Deals"
        button3.bezelStyle = .rounded
        button3.action = #selector(setupPanelAssets)
        
        button4.title = "Make Amazon Deals"
        button4.bezelStyle = .rounded
        button4.action = #selector(amazonDealPanel)
        // Set other properties as needed
        button5.title = "blackfriday.com bot" 
        button5.bezelStyle = .rounded
        button5.action = #selector(button5Action)
        // Scrap Data Button
        button6.title = "Scrap ASINs"
        button6.bezelStyle = .rounded
        button6.action = #selector(button6Action)
        
        button7.title = "Coupon Scrape"
        button7.bezelStyle = .rounded
        button7.action = #selector(button7Action)
        
        button8.title = "PDF To JPG"
        button8.bezelStyle = .rounded
        button8.action = #selector(button8Action)

        
        // Add the button to the view controller's view
        view.addSubview(button)
        view.addSubview(button2)
        view.addSubview(button3)
        view.addSubview(button4)
        view.addSubview(button5)
        view.addSubview(button6)
        view.addSubview(button7)
        view.addSubview(button8)
        
        // Add constraints to center the button horizontally and vertically
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20)
        ])
        button2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button2.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -10)
        ])
        button3.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button3.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button3.bottomAnchor.constraint(equalTo: button2.topAnchor, constant: -10)
        ])
        button4.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button4.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button4.bottomAnchor.constraint(equalTo: button3.topAnchor, constant: -10)
        ])
        button5.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button5.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button5.bottomAnchor.constraint(equalTo: button4.topAnchor, constant: -10)
        ])
        button6.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button6.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button6.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 10)
        ])
        
        button7.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button7.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button7.topAnchor.constraint(equalTo: button6.bottomAnchor, constant: 10)
        ])
        button8.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button8.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button8.topAnchor.constraint(equalTo: button7.bottomAnchor, constant: 10)
        ])
    }
    
}


