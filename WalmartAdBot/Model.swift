import Foundation

struct Deal: Codable {
    var name: String?
    var price: String?
    var ad: String?
}

struct Product: Codable {
    
    let ImageURL: String?
    let ProductDescription: String?
    let ProductName: String?
    let ShortLink: String?
    let CurrentPrice: Double?
    let Manufacturer: String?
}

struct Asset: Codable {
    var Name: String?
    var Description: String?
    var LimitedTimeStartDate: String?
    var LimitedTimeEndDate: String?
    var TrackingLink: String?
    var AdType: String?
}

