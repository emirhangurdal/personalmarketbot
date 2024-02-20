
import Foundation
import Cocoa

class PublixSupport {
    func generatePublixCouponHtml(coupons: [PublixCoupon]) -> String {
        let link: String = "https://www.publix.com/savings/digital-coupons"
        
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
        
        for coupon in coupons {
            
            let title = coupon.coupon
            let exp = coupon.exp
            let image = coupon.imageLink
            
            htmlString += "<li>"
            htmlString += "<h3>\(title)</h3>"
            htmlString += "<p>Expires: \(exp)</p>"
            htmlString += "<img src=\"\(image)\" alt=\"\(title)\" style=\"max-width: 150px; max-height: 150px;\">"
            htmlString += "</li>"
            
        }
        
        htmlString += """
        </ol>
        </body>
        </html>
        """
        return htmlString
    }
    func generatePublixBOGOHtml(coupons: [PublixBOGO]) -> String {
        let link: String = "https://www.publix.com/savings/digital-coupons"
        
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
        for coupon in coupons {
            
            if let title = coupon.title,
               let additionalInfo = coupon.additionalInfo,
               let savingsBadge = coupon.savingsBadge,
               let validDate = coupon.validDate,
               let image = coupon.image {
                htmlString += "<li>"
                htmlString += "<strong>\(title)</strong>"
                htmlString += "<p>\(additionalInfo)</p>"
                htmlString += "<p>\(savingsBadge) </p>"
                htmlString += "<p>\(validDate) </p>"
                htmlString += "<img src=\"\(image)\" alt=\"\(title)\" style=\"max-width: 150px; max-height: 150px;\">"
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
