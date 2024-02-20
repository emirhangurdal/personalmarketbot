//
//  SaveHTML.swift
//  WalmartAdBot
//
//  Created by Emir Gurdal on 25.11.2023.
//

import Foundation
import Cocoa

class SaveHTML {
    let savePanel = NSSavePanel()
    let fileName = ""
    
    func saveHTMLStringToFile(_ htmlString: String, at fileURL: URL) {
        do {
            try htmlString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("File saved successfully at: \(fileURL.path)")
        } catch {
            print("Error saving file: \(error)")
        }
    }
    func saveFile(htmlString: String){
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "\(fileName).html"
        // Set an initial directory URL
        let initialDirectoryURL = FileManager.default.homeDirectoryForCurrentUser
        savePanel.directoryURL = initialDirectoryURL
        savePanel.begin { result in
            if result == NSApplication.ModalResponse.OK, let url = self.savePanel.url {
                // Save the file at the selected URL
                
                self.saveHTMLStringToFile(htmlString, at: url)
            }
        }
    }
}
