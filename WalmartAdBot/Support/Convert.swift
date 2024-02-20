
import SwiftCSV
import Foundation

class Convert {
    
    func removeSpacesInJSONKeys(fileURL: URL) -> String? {
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
            
            if let updatedObject = removeSpacesInKeys(jsonObject: jsonObject) {
                let updatedData = try JSONSerialization.data(withJSONObject: updatedObject)
                if let jsonString = String(data: updatedData, encoding: .utf8) {
                    return jsonString
                }
            }
            
            return nil
        } catch {
            print("Error reading or processing JSON file: \(error)")
            return nil
        }
    }

    private func removeSpacesInKeys(jsonObject: Any) -> Any? {
        if let dictionary = jsonObject as? [String: Any] {
            var updatedDictionary = [String: Any]()
            
            for (key, value) in dictionary {
                let updatedKey = key.replacingOccurrences(of: " ", with: "")
                if let updatedValue = removeSpacesInKeys(jsonObject: value) {
                    updatedDictionary[updatedKey] = updatedValue
                }
            }
            
            return updatedDictionary
        }
        
        if let array = jsonObject as? [Any] {
            var updatedArray = [Any]()
            
            for element in array {
                if let updatedElement = removeSpacesInKeys(jsonObject: element) {
                    updatedArray.append(updatedElement)
                }
            }
            
            return updatedArray
        }
        
        return jsonObject
    }

}
