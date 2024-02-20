//
//  MeijerModel.swift
//  WalmartAdBot
//
//  Created by Emir Gurdal on 13.02.2024.
//

import Foundation

struct MeijerCouponData: Codable {
    let listOfCoupons: [MeijerCoupon]?
}
struct MeijerCoupon: Codable {
    let offer: MeijerCpn?
}
struct MeijerCpn: Codable {
    let meijerOfferId: Int?
    let title: String?
    let description: String?
    let departments: [MeijerDepartment]?
    let category: MeijerCategory?
    let imageURL: String?
    let termsAndConditions: String?
    let redemptionStartDate: String?
    let redemptionEndDate: String?
    let redeemAmount: Double?
}
struct MeijerDepartment: Codable {
    let categoryName: String?
    let subCategoryName: String? 
}
struct MeijerCategory: Codable {
    let segmentName: String?
}
