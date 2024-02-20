import SwiftSoup
import Foundation
import AppKit

class ScrapCoupons {
    // if there is [data-asin] key in the source code on amazon.com page, you can get value with this code.
    
    let desktopURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
    let amazonAPI = AmazonAPI()
    
    func scrapAmazonCoupons(html: String) {
        
        let date = amazonAPI.getCurrentUTCDateTimeISO8601()
        var dataAsinArray = [String]()
        do {
            let doc = try SwiftSoup.parse(html)
            // Use a CSS selector to find elements with the data-asin attribute
            let elements = try doc.select("[data-asin]")
            // Iterate through the elements and extract the data-asin values
            for element in elements {
                if let dataAsin = try? element.attr("data-asin") {
                    dataAsinArray.append("\(dataAsin),")
                }
            }
            let textFilePath = desktopURL?.appendingPathComponent("\(date)dataAsin.txt")
            if let textFilePath = textFilePath {
                let dataAsinText = dataAsinArray.joined(separator: "\n")
                do {
                    try dataAsinText.write(to: textFilePath, atomically: true, encoding: .utf8)
                    print("DataAsin values saved to \(textFilePath.path)")
                    let workspace = NSWorkspace.shared
                    workspace.open(textFilePath)
                } catch {
                    print("Error saving dataAsin values: \(error)")
                }
            }
        
        } catch {
            print("Error parsing HTML: \(error)")
        }
    }
    
    func scrapSpecialDealsCarousel(html: String, completion: @escaping ([AmazonCarousel]?) -> Void) {
        let date = amazonAPI.getCurrentUTCDateTimeISO8601()
        var amazonCarouselDeals = [AmazonCarousel]()
        do {
            let doc = try SwiftSoup.parse(html)
            let elements = try doc.select("li.a-carousel-card")
            let textFilePath = desktopURL?.appendingPathComponent("\(date)AmazonCarouselDeals.txt")
            for deal in elements {
                let dealLink = try? deal.select("a.a-link-normal").first()?.attr("href")
                let dealTitle = try deal.select("span.a-truncate-full").text()
                let save = try deal.select("span.a-size-small").text()
                
                print("how much you save = \(save)")
                amazonCarouselDeals.append(AmazonCarousel(dealLink: "https://amazon.com\(dealLink ?? "")&tag=hmsmedia08-20", dealTitle: save))
                
            }
            completion(amazonCarouselDeals)
            
        } catch {
            print("Error parsing HTML: \(error)")
        }
    }
}
