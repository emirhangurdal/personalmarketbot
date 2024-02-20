

import Cocoa
import Foundation
import Quartz

class PDFConverter: NSViewController {
    override func viewDidLoad() {
        
//        convertPDFtoJPG(pdfURL: pdfURL, outputDirectory: outputDirectory)
        convertPDFtoTIFF(pdfURL: pdfURL, outputDirectory: outputDirectory)
    }
    let pdfURL = URL(fileURLWithPath: "/Users/emirgurdal/Downloads/foodland.pdf")
    let outputDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
    
    func convertPDFtoJPG(pdfURL: URL, outputDirectory: URL) {
        guard let pdfDocument = PDFDocument(url: pdfURL) else {
            print("Error loading PDF document.")
            return
        }
        print("convertPDFtoJPG worked")
        let pageCount = pdfDocument.pageCount
        
        for pageIndex in 0..<pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else {
                print("Error loading page \(pageIndex + 1).")
                continue
            }
            
            let pdfRect = page.bounds(for: .mediaBox)
            let image = NSImage(size: pdfRect.size)
            
            image.lockFocus()
            
            if let context = NSGraphicsContext.current?.cgContext {
                page.draw(with: .mediaBox, to: context)
            }
            
            image.unlockFocus()
            
            guard let imageData = image.tiffRepresentation else {
                print("Error converting page \(pageIndex + 1) to TIFF.")
                continue
            }
            
            let compressionQuality: CGFloat = 1.0
            
            let jpgData = NSBitmapImageRep(data: imageData)?.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
            
            
            let jpgFilename = "\(pdfURL.deletingPathExtension().lastPathComponent)_page\(pageIndex + 1).jpg"
            let jpgURL = outputDirectory.appendingPathComponent(jpgFilename)
            
            do {
                try jpgData?.write(to: jpgURL)
                print("Page \(pageIndex + 1) converted to JPG: \(jpgURL.path)")
            } catch {
                print("Error writing JPG file for page \(pageIndex + 1): \(error.localizedDescription)")
            }
        }
    }
    func convertPDFtoTIFF(pdfURL: URL, outputDirectory: URL) {
        guard let pdfDocument = PDFDocument(url: pdfURL) else {
            print("Error loading PDF document.")
            return
        }
        print("convertPDFtoJPG worked")
        let pageCount = pdfDocument.pageCount
        
        for pageIndex in 0..<pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else {
                print("Error loading page \(pageIndex + 1).")
                continue
            }
            
            let pdfRect = page.bounds(for: .mediaBox)
            let image = NSImage(size: pdfRect.size)
            
            image.lockFocus()
            
            if let context = NSGraphicsContext.current?.cgContext {
                page.draw(with: .mediaBox, to: context)
            }
            
            image.unlockFocus()
            
            guard let imageData = image.tiffRepresentation else {
                print("Error converting page \(pageIndex + 1) to TIFF.")
                continue
            }
            let tiffFilename = "\(pdfURL.deletingPathExtension().lastPathComponent)_page\(pageIndex + 1).tiff"
            
            let tiffURL = outputDirectory.appendingPathComponent(tiffFilename)
            
            do {
                try imageData.write(to: tiffURL)
                print("Page \(pageIndex + 1) converted to TIFF: \(tiffURL.path)")
            } catch {
                print("Error writing TIFF file for page \(pageIndex + 1): \(error.localizedDescription)")
            }
        }
    }
}
