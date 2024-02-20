
import Foundation
import Cocoa

struct PublixCoupon: Codable {
    let coupon: String
    let exp: String
    let imageLink: String
}

//: - BOGO Model - https://www.publix.com/savings/weekly-ad/bogo?nav=header
struct PublixBOGO: Codable {
    let title: String?
    let savingsBadge: String?
    let validDate: String?
    let image: String?
    let additionalInfo: String?
    
}
