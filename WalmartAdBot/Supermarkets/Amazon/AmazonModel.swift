
import Foundation

struct AmazonDeal: Codable {
    let SearchResult: [SearchResult]?
}

struct SearchResult: Codable {
    let Items: [Items]?
}

struct Items: Codable {
    let DetailPageURL: String?
    let ItemInfo: ItemInfo?
    let Images: Image?
    let Offers: Offers?
}

struct Image: Codable {
    let Primary: Primary?
}
struct Primary: Codable {
    let Medium: Medium?
}
struct Medium: Codable {
    let URL: String?
}
struct ItemInfo: Codable {
    let Title: Title?
    let Features: Features?
}
struct Features: Codable {
    let DisplayValues: [String]?
}

struct Title: Codable {
    let DisplayValue: String?
}
struct Offers: Codable {
    let Listings: [Listing]?
}
struct Listing: Codable {
    let Price: Price?
}
struct Price: Codable {
    let Amount: Double?
    let Currency: String?
    let DisplayAmount: String?
}


// Carousel Scrape

struct AmazonCarousel: Codable {
    let dealLink: String?
    let dealTitle: String?
}
