
import Foundation
import Cocoa

struct WalgreensCouponss: Codable {
    let coupons: [WalgreensCpn]?
}
struct WalgreensCpn: Codable {
    let offerExpiryDate: String?
    let offerActiveDate: String?
    let expiryDate: String?
    let brandName: String?
    let summary: String?
    let image: String?
    let image2: String?
    let categoryName: String?
    let description: String?
    let id: String?
}


