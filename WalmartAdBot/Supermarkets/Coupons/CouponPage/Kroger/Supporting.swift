import Cocoa
import Foundation
import SwiftSoup


// to use this you need to parse html file of https://www.kroger.com/savings/cl/coupons/ to get coupons: [String:KrogerCoupon] using func parseJSONKroger(fileURL: URL, completionHandler: @escaping (KrogerData) -> Void)

class Support {
    let firebaseSupport = FirebaseSupport()
    var products: [String: [String]] = [:]
    //MARK: Generate Coupon HTML
    func couponHtml(firebaseStatus: Bool, store: String, brand: String, coupons: [String:KrogerCoupon]) -> String {
        var cpns = [KrogerCoupon]()
        
        for key in coupons.keys {
            print("key = \(key)")
            if let coupon = coupons[key] {
                cpns.append(coupon)
            }
        }
        
        var htmlString = """
        <html>
        <head>
        <style>
        ol {
            list-style-type: decimal;
        }
        </style>
        </head>
        <body>
        <ol>
        """
        
        for coupon in cpns {
            let link = "https://www.\(brand).com/savings/c/\(coupon.krogerCouponNumber!)"
            if let reqDesc = coupon.requirementDescription,
               let imageUrl = coupon.imageUrl,
               let exp = convertISO8601DateString(coupon.expirationDate!),
               let dispDate = coupon.displayStartDate,
               let shortDesc = coupon.shortDescription
                
            {
                if firebaseStatus == true {
                    let random = UUID()
                    firebaseSupport.sendToDatabase(image: imageUrl, title: shortDesc, save: reqDesc, desc: "", exp: exp, category: "Grocery", id: "\(random)", mainCategory: "Grocery", storeBrand: store, link: link)
                }
                
                htmlString += "<li>"
                htmlString += "<h3><a href=\"\(link)\">\(shortDesc)</a></h3>"
                htmlString += "<p>Expires: \(exp)</p>"
                htmlString += "<p>Requirements: \(reqDesc)</p>"
                htmlString += "<a href=\"\(link)\"><img src=\"\(imageUrl)\" alt=\"\(shortDesc)\" style=\"max-width: 150px; max-height: 150px;\"></a>"
                htmlString += "</li>"
            }
        }
        
        htmlString += """
        </ol>
        </body>
        </html>
        """
        return htmlString
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
    func convertISO8601DateString(_ dateString: String) -> String? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]
        
        if let date = dateFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM d, yyyy HH:mm:ss"
            return outputFormatter.string(from: date)
        } else {
            return nil
        }
    }
    let weeklyImage = "https://cdn.weeklyads2.com/wp-content/uploads/2022/12/wead_logo_big.png?width=58"
    //MARK: - Weekly Ad
    func weeklyAdHtml(weeklyAd: KrogerWeeklyAdData) -> String {
        
        var htmlString = """
        <html>
        <head>
        <style>
        ol {
            list-style: none;
        }
        </style>
        </head>
        <body>
        """
        let adGroups = weeklyAd.data?.shoppableWeeklyDeals?.adGroups
        let adItems = weeklyAd.data?.shoppableWeeklyDeals?.ads
        for adGroup in adGroups! {
            
            htmlString += "<h2>\(adGroup.name ?? "nil")</h2>"
            adGroup.ads.map { ads in
                ads.map { krogerMainAdTitle in
                    let mainId = krogerMainAdTitle.id
                    
                    for item in adItems! {
                        print("item.pricing = \(item.pricingTemplate)")
                        var bogoText = ""
                        if item.id == mainId, item.departments?[0].department != "LIQUOR" {
                            if item.pricingTemplate?.contains("BOGO") == true {
                                 bogoText = "BOGO Deal"
                            }
                            if let regP = item.retailPrice {
                                htmlString += "<h3>\(item.mainlineCopy ?? "") Reg. Price: $\(regP), \(item.loyaltyIndicator ?? "") \(bogoText)</h3>"
                                
                                if let quantity = item.quantity, quantity != 0 {
                                    htmlString += "<h4>\(quantity) for $\(regP)</h4>"
                                }
                            } else {
                                htmlString += "<h3>\(item.mainlineCopy ?? "") \(bogoText)</h3>"
                                if let quantity = item.quantity, quantity != 0 {
                                    htmlString += "<h4>Must-Buy \(quantity)</h4>"
                                }
                            }
                            htmlString += "<p>\(item.underlineCopy ?? "")</p>"
                            htmlString += "<img src=\"\(item.images?[0].url ?? "\(weeklyImage)")\" alt=\"\(item.mainlineCopy ?? "")\" style=\"max-width: 150px; max-height: 150px;\">"
                            if let saleP = item.salePrice {
                                htmlString += "<p style=\"color: blue; font-weight: bold;\">Sale: $\(saleP), \(item.loyaltyIndicator ?? "")</p>"
                            }
                            if let percentOff = item.percentOff {
                                htmlString += "<p style=\"color: red; font-weight: bold;\">\(percentOff)% OFF</p>"
                            }
                            htmlString += "<hr>"
                        }
                    }
                }
            }
        }
        
        htmlString += """
        </body>
        </html>
        """
        return htmlString
    }
    
}
