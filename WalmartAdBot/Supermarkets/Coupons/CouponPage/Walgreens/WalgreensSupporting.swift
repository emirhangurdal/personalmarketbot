//
//  WalgreensSupporting.swift
//  WalmartAdBot
//
//  Created by Emir Gurdal on 1.12.2023.
//

import Foundation
import Cocoa

class WalgreensSupporting {
    let walgreensLink = "https://www.walgreens.com/store/store/save/digital_family_offers.jsp?offerCode="
    func couponHtml(coupons: [String: [WalgreensCpn]]) -> String {
        
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
        for key in coupons.keys {
           
            htmlString += "<h2>\(key)</h2>"
            coupons[key].map { cpnArray in
                cpnArray.map { cpn in
                    if let brandName = cpn.brandName,
                       let exp = cpn.expiryDate,
                       let summary = cpn.summary,
                       let desc = cpn.description,
                       let id = cpn.id
                    {
                        htmlString += "<li>"
                        htmlString += "<h4><a href=\"\(walgreensLink)\(id)\">\(brandName)</a></h4>"
                        htmlString += "<p style=\"color: red;\">Expires: \(exp)</p>"
                        htmlString += "<p>\(summary)</p>"
                        htmlString += "<p>\(desc)</p>"
                        htmlString += "</li>"
                    }
                }
            }
        }

        htmlString += """
        </ol>
        </body>
        </html>
        """
        return htmlString
    }
}
