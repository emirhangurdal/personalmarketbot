
import Foundation
import FirebaseFirestore

class FirebaseSupport {
    let db = Firestore.firestore()
    func sendToDatabase(image: String, title: String, save: String, desc: String, exp: String, category: String, id: String, mainCategory: String, storeBrand: String, link: String) {
        var couponNumber = 0
        couponNumber += 1
        
        let categoryReference = db.collection("coupons").document(mainCategory)
        
        categoryReference.setData(["Category" : mainCategory]) { error in
            if let error = error {
                print("error saving category: \(error)")
            }
            
            let brandReference = categoryReference.collection("Brands").document(storeBrand)
            
            brandReference.setData(["Brand" : storeBrand, "CouponNumber":couponNumber]) { error in
                if let error = error {
                    print("error saving brand: \(error)")
                }
                
                let brandsCouponsReference = brandReference.collection("coupons").document(id)
                
                let data = ["image": image, "title": title, "save": save, "desc": desc, "exp" : exp, "category": category, "link":link]
                
                brandsCouponsReference.setData(data) { error in
                    if let error = error {
                        print("error saving coupons: \(error)")
                    } else {
                        print("probably saved the coupons")
                    }
                }
            }
        }
    }
    func cleanStore(mainCategory: String, storeBrand: String) {
        let brandCouponsReferenceToBeDeleted = db.collection("coupons").document(mainCategory).collection("Brands").document(storeBrand).collection("coupons")
        brandCouponsReferenceToBeDeleted.getDocuments { snapShot, error in
            if let error = error {
                print(error)
            }
            
            for document in snapShot!.documents {
                if document.exists == true {
                    document.reference.delete { error in
                        if let error = error {
                            print("error deleting existing coupon: \(error)")
                            
                        } else {
                            print("probably deleted a coupon")
                        }
                    }
                }
            }
        }
    }
}

