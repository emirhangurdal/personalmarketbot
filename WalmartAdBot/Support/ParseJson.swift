
import Foundation

class ParseJson {
    let decoder = JSONDecoder()
    static let shared = ParseJson()
    
    func parseJSON<T: Codable>(fileURL: URL, completionHandler: @escaping ([T]) -> Void) {
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let decodedData = try JSONDecoder().decode([T].self, from: jsonData)
            completionHandler(decodedData)
        } catch {
            print("error ParseData = \(error.localizedDescription)")
            print("error ParseData = \(error)")

        }
    }
    func parseJSONKroger(fileURL: URL, completionHandler: @escaping (KrogerData) -> Void) {
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let decodedData = try JSONDecoder().decode(KrogerData.self, from: jsonData)
            completionHandler(decodedData)
         
        } catch {
            print("error ParseData = \(error.localizedDescription)")
            print("error ParseData = \(error)")

        }
    }
    func parseJSONAmazon(fileURL: URL, completionHandler: @escaping ([String:SearchResult]) -> Void) {
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let decodedData = try JSONDecoder().decode([String : SearchResult].self, from: jsonData)
            completionHandler(decodedData)
        } catch {
            print("error ParseData = \(error)")
        }
    }

    func parseJSONGeneric<T: Codable>(data: Data, completionHandler: @escaping (T) -> Void) {
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            
            completionHandler(decodedData)
            
        } catch {
            print("error ParseData = \(error.localizedDescription)")
            print("error ParseData = \(error)")
        }
    }

    
}
