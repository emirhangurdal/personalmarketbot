

import Foundation

class CVSSupport {
    let firebaseSupport = FirebaseSupport()
    let cvsCpnDetailLink = "https://www.cvs.com/extracare/home/?tab=allCoupons&coupon="
    func couponHtml(coupons: [String: [CVSCoupon]], firebaseStatus: Bool) -> String {
        
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
           
            htmlString += "<h2>\(key) Coupons</h2>"
            
            coupons[key].map { cpnArray in
                cpnArray.map { cpn in
                    if let mfrOfferBrandName = cpn.mfrOfferBrandName,
                       let exp = cpn.endTs,
                       let desc = cpn.cpnDsc,
                       let mfrOfferValueDsc = cpn.mfrOfferValueDsc,
                       let cmpgnId = cpn.cmpgnId,
                       let cpnNbr = cpn.cpnNbr,
                       let imgUrlTxt = cpn.imgUrlTxt
                 
                    {
                        let expDate = convertToMMDDYYYYFormat(dateString: exp)
                        let couponsUrl = "\(cvsCpnDetailLink)\(cmpgnId)_\(cpnNbr)"
                        if firebaseStatus == true {
                            let randomUUID = UUID()
                            firebaseSupport.sendToDatabase(image: imgUrlTxt, title: mfrOfferBrandName, save: mfrOfferValueDsc, desc: desc, exp: expDate!, category: "Pharmacy", id: "\(randomUUID)", mainCategory: "Pharmacy", storeBrand: "CVS", link: couponsUrl)
                        }
                       
                        htmlString += "<li>"
                        htmlString += "<h3><a href=\"\(couponsUrl)\">\(mfrOfferBrandName) - \(mfrOfferValueDsc)</a></h3>"
                        htmlString += "<p style=\"color: red;\">Expires: \(expDate ?? "")</p>"
                        htmlString += "<p>\(desc)</p>"
                        htmlString += "<a href=\"\(couponsUrl)\"><img src=\"\(imgUrlTxt)\" alt=\"\(desc)\" style=\"max-width: 150px; max-height: 150px;\"></a>"
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
    
    
    func convertToMMDDYYYYFormat(dateString: String) -> String? {
        let dateFormatterInput = DateFormatter()
        dateFormatterInput.dateFormat = "yyyyMMdd HH:mm:ss"
        
        if let date = dateFormatterInput.date(from: dateString) {
            let dateFormatterOutput = DateFormatter()
            dateFormatterOutput.dateFormat = "MM/dd/yyyy"
            
            return dateFormatterOutput.string(from: date)
        } else {
            return nil
        }
    }
}
