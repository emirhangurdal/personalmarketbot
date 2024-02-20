
import Foundation

struct CVSCpn: Codable {
    let cusInfResp: CusInfResp?
}
struct CusInfResp: Codable {
    let mfrCpnAvailPool: [CVSCoupon]?
}
struct CVSCoupon: Codable {
    //FOR REDIRECT URL:
    let cmpgnId: Int?
    let cpnNbr: Int?
    //DESC AND TITLE
    let cpnCats: [CpnCat]?
    let mfrOfferValueDsc: String? // Save off
    let mfrOfferBrandName: String? // Example: Colgate Toothpaste
    let cpnDsc: String? // Description
    let maxRedeemAmt: String? // Save up to
    //IMAGE:
    let imgUrlTxt: String?
    //DATE:
    let expSoonInd: String? // Expiring soon indication?
    let endTs: String? // Exp Date.
}
struct CpnCat: Codable {
    let cpnCatNbr: Int?
    let cpnCatDsc: String?
}

