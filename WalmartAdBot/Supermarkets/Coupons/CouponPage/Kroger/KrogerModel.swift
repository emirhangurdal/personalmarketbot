
import Foundation

//MARK: - Token for Kroger APIs - https://api.kroger.com/v1/connect/oauth2/token

struct KrogerToken: Codable {
    let expires_in: Int?
    let token_type: String?
    let access_token: String?
}

//MARK: For Kroger API Product Search Result https://api.kroger.com/v1/products

struct KrogerSearchResult: Codable {
    let data: [KrogerProduct]?
}
struct KrogerProduct: Codable {
    let productId: String?
    let brand: String?
    let description: String?
    let categories: [String]?
    let images: [KrogerImages]?
    let items: [KrogerItem]?
}
struct KrogerImages: Codable {
    let perspective: String?
    let sizes: [KrogerImageSize]?
}

struct KrogerImageSize: Codable {
    let size: String?
    let url: String?
}
struct KrogerItem: Codable {
    let fulfillment: [Fullfilment]?
    let price: [KrogerItemPrice]?
}
struct Fullfilment: Codable {
    let curbside: Bool?
    let delivery: Bool?
    let inStore: Bool?
    let shipToHome: Bool?
}
struct KrogerItemPrice: Codable {
    let regular: Double?
    let promo: Double?
}
//MARK: For data of Digital Coupons () - (save json from this url) https://www.kroger.com/savings/cl/coupons/
struct KrogerData: Codable {
    let success: Bool?
    let data: CouponData?
}
struct CouponData: Codable {
    let couponData: Coupons?
}
struct Coupons: Codable {
    let coupons: [String: KrogerCoupon]?
}
struct KrogerCoupon: Codable {
    
    let krogerCouponNumber: String?
    let brandName: String?
    let shortDescription: String?
    let requirementDescription: String?
    let displayDescription: String?
    let expirationDate: String?
    let displayStartDate: String?
    let imageUrl: String?
    let longDescription: String?
    
}

//MARK: - Available Weekly Ads Model - https://api.kroger.com/digitalads/v1/circulars

struct KrogerAdID: Codable {
    let data: [KrogerWeeklyAd]?
}
struct KrogerWeeklyAd: Codable {
    let id: String?
    let eventStartDate: String?
    let eventEndDate: String?
    let previewCircular: Bool?
}

//MARK: - Weekly Ad Data Model - https://www.kroger.com/atlas/v1/shoppable-weekly-deals/deals?filter.circularId

struct KrogerWeeklyAdData: Codable {
    let data: KrogerAdData?
}
struct KrogerAdData: Codable {
    let shoppableWeeklyDeals: ShoppableWeeklyDeals?
}
struct ShoppableWeeklyDeals: Codable {
    let events: [Events]?
    let adGroups: [AdGroup]?
    let ads: [Ads]?
}
// The Big Titles of Deals like Weekly Digital Deals, Locked-in Low Prices
struct Events: Codable {
    let title: String?
    let eventType: String?
}
//Similar to events:
struct AdGroup: Codable {
    let name: String?
    let description: String?
    let ads: [KrogerMainAdTitle]?
}
struct KrogerMainAdTitle: Codable {
    let id: String?
}

//Actual items available in the weekly ads:
struct Ads: Codable {
    let id: String?
    let adId: String?
    let circularId: String?
    //: Text info
    let mainlineCopy: String?
    let underlineCopy: String?
    let disclaimer: String?
    //: Prices - Savings
    let retailPrice: Double?
    let salePrice: Double?
    let saveAmount: Double?
    let percentOff: Int?
    let quantity: Int?
    let pricingTemplate: String?
    //: Date
    let validFrom: String?
    let validTill: String?
    let loyaltyIndicator: String?
    let rank: Int?
    //: Department - Event
    let departments: [Department]?
    let images: [KrogerAdImage]?
    
}
struct KrogerAdImage: Codable {
    let name: String?
    let url: String?
}
struct Department: Codable {
    let department: String?
    let departmentCode: Int?
}
