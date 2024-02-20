//
//  MeijerSupport.swift
//  WalmartAdBot
//
//  Created by Emir Gurdal on 13.02.2024.
//

import Foundation

class MeijerSupport {
    
    func generateCouponHtml(coupons: [String: [MeijerCoupon]], firebaseStatus: Bool) -> String {
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
        
        var tableOfContents = """
        <div id="toc_container">
            <p class="toc_title"><strong>Contents</strong></p>
            <ul class="toc_list">
        """
        tableOfContents += "<li><a href=\"#meijer-mperks\">mPerks</a></li>"
        for key in coupons.keys {
            print("category: \(key)")
            let couponCounts = coupons[key]?.count
            
            tableOfContents += "<li><a href=\"#\(key)\">\(key) (\(couponCounts ?? 0))</a></li>"
            htmlString += "<h2 id=\"\(key)\">\(key) (\(couponCounts ?? 0))</h2>"
            
            coupons[key].map { meijerCoupons in
               
                meijerCoupons.map { meijerCoupon in
                    if let title = meijerCoupon.offer?.title,
                       let description = meijerCoupon.offer?.description,
                       var termsAndConditions = meijerCoupon.offer?.termsAndConditions,
                       let redemptionStartDate = convertDateFormat(dateString: meijerCoupon.offer?.redemptionStartDate ?? "Date Unknown"),
                       let redemptionEndDate = convertDateFormat(dateString: meijerCoupon.offer?.redemptionEndDate ?? "Date Unknown"),
                       let imageURL = meijerCoupon.offer?.imageURL
                    {
                        let maxLength = 150 // Set your desired maximum length here
                        
                        if termsAndConditions.count > maxLength {
                            termsAndConditions = "\(String(termsAndConditions.prefix(maxLength)))..."
                        }
                        
                        htmlString += "<li>"
                        htmlString += "<strong>\(description)</strong>"
                        htmlString += "<p style=\"color: black;\"><strong>\(title)</strong></p>"
                        htmlString += "<p style=\"color: red;\">Starts: \(redemptionStartDate) - Expires: \(redemptionEndDate)</p>"
                        htmlString += "<p style=\"color: black;\">\(termsAndConditions)</p>"
                        htmlString += "<img src=\"\(imageURL)\" alt=\"\(title)\" style=\"max-width: 150px; max-height: 150px;\">"
                        htmlString += "</li>"
                    }
                }
            }
        }
        tableOfContents += """
               </ul>
           </div>
           """
        htmlString = tableOfContents + htmlString
        
        htmlString += """
        </ol>
        </body>
        </html>
        """
        return htmlString
    }
    func convertDateFormat(dateString: String) -> String? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MM/dd/yyyy"

        if let date = dateFormatterGet.date(from: dateString) {
            return dateFormatterPrint.string(from: date)
        } else {
            return nil
        }
    }

}
