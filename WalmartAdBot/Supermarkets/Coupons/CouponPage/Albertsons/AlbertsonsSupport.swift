
import Foundation

class AlbertsonsSupport {
    let firebaseSupport = FirebaseSupport()
    func couponHtml(store: String, firebaseStatus: Bool, albertsonsDomain: String, imageDomain: String, coupons: [AlbertsonsCoupon]) -> String {
        
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
        
        for cpn in coupons {
            if let dealTitle = cpn.dealTitle,
               let couponTitle = cpn.couponTitle,
               let limit = cpn.limit,
               let exp = cpn.exp,
               let productDetail = cpn.productDetail,
               let linkPath = cpn.linkPath,
               let imageURL = cpn.imageURL {
                
                if firebaseStatus == true {
                    let random = UUID()
                    let link = "\(albertsonsDomain)\(linkPath)"
                    firebaseSupport.sendToDatabase(image: "\(imageDomain)\(imageURL)", title: productDetail, save: couponTitle, desc: dealTitle, exp: exp, category: "Grocery", id: "\(random)", mainCategory: "Grocery", storeBrand: store, link: link)
                }
                htmlString += "<li>"
                htmlString += "<h3><a href=\"\(albertsonsDomain)\(linkPath)\">\(dealTitle) - \(couponTitle)</a></h3>"
                htmlString += "<p style=\"color: red;\"> \(exp)</p>"
                htmlString += "<p>Limit: \(limit)</p>"
                htmlString += "<p>Details: \(productDetail)</p>"
                htmlString += "<a href=\"\(albertsonsDomain)\(linkPath)\"><img src=\"\(imageDomain)\(imageURL)\" alt=\"\(productDetail)\" style=\"max-width: 150px; max-height: 150px;\"></a>"
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
}
