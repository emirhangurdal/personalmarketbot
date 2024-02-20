import Cocoa
import Foundation

class Amazon {
    //MARK: - Amazon String HTML
    func createHTMLStringforAmazonTable(from products: [Items]) -> String {
        var htmlString = """
            <html>
            <head>
            <style>
            table {
                border-collapse: collapse;
                width: 100%;
            }
            
            th, td {
                text-align: left;
                padding: 8px;
                border-bottom: 1px solid #ddd;
            }
            
            th {
                background-color: #f2f2f2;
            }
            </style>
            </head>
            <body>
            <table>
            <tr>
                <th>Name</th>
                <th>Desc</th>
                <th>Image</th>
            </tr>
        """
        for product in products {
            
            let price = product.Offers?.Listings?[0].Price ?? Price(Amount: 0.00, Currency: "", DisplayAmount: "-")
            let description = product.ItemInfo?.Features?.DisplayValues
            if let dealPrice = price.Amount,
               let currency = price.Currency,
               let dealTitle = product.ItemInfo?.Title?.DisplayValue,
               let dealURL = product.DetailPageURL,
               let imageURL = product.Images?.Primary?.Medium?.URL {
                htmlString += "<tr>"
                htmlString += "<td><a href=\"\(dealURL)\">\(dealTitle)</a></td>"
                htmlString += "<td>\(description![0])</td>"
                htmlString += "<td><a href=\"\(dealURL)\"><img src=\"\(imageURL)\" alt=\"\(dealTitle)\" style=\"max-width: 100px; max-height: 100px;\"></a></td>"
                htmlString += "</tr>"
            }
        }
        
        htmlString += """
            </table>
            </body>
            </html>
        """
        return htmlString
    }
    func createHTMLStringforAmazon(from products: [Items]) -> String {
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

        for product in products {
            let price = product.Offers?.Listings?[0].Price ?? Price(Amount: 0.00, Currency: "", DisplayAmount: "-")
            let description = product.ItemInfo?.Features?.DisplayValues ?? [""]
            if let dealPrice = price.Amount,
               let currency = price.Currency,
               let dealTitle = product.ItemInfo?.Title?.DisplayValue,
               let dealURL = product.DetailPageURL,
               let imageURL = product.Images?.Primary?.Medium?.URL {
                htmlString += "<li>"
                htmlString += "<h3><a href=\"\(dealURL)\">\(dealTitle)</a></h3>"
                htmlString += "<p>\(description[0])</p>"
                htmlString += "<a href=\"\(dealURL)\"><img src=\"\(imageURL)\" alt=\"\(dealTitle)\" style=\"max-width: 250px; max-height: 250px;\"></a>"
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
    //: Sometimes when they have Cyber Monday or other holiday pages they have a carousel card containing the featured deals. This function is for that:
    func createHTMLStringforAmazonCarousel(from products: [AmazonCarousel]) -> String {
        var htmlString = """
        <html>
        <head>
        <style>
        ol {
            list-style-type: none;
        }
        </style>
        </head>
        <body>
        
        """
        for product in products {
               
            if let dealLink = product.dealLink,
               let dealTitle = product.dealTitle {
                if dealLink != "", dealTitle != "" {
                    htmlString += "<li>"
                    htmlString += "<h4><a href=\"\(dealLink)\">\(dealTitle)</a></h4>"
                    htmlString += "</li>"
                   
                }
            }
        }

        htmlString += """
        
        </body>
        </html>
        """
        return htmlString
    }
}
