//
//  PDF.swift
//  Converter
//
//  Created by Alan Yepez on 11/8/15.
//  Copyright © 2015 alanypz. All rights reserved.
//

import UIKit
import QuickLook

// Object for the PDF files. Represents the Model.
class PDF: NSObject {
    
    // Container for images.
    private(set) var images: [UIImage] = []
    
    // Variable set to true when rendered to prevent unnecessarily re-rerendering.
    var isRendered: Bool = false
    
    var numberOfImages: Int {
        
        return images.count
        
    }
    
    subscript(index: Int) -> UIImage {
        
        return images[index]
        
    }
    
    func reset() {
    
        images.removeAll()
        
        isRendered = false
    
    }
    
    func appendImage(image: UIImage) {
        
        images.append(image)
        
        isRendered = false
        
    }
    
    // Allows moving images based on user "drag and drop."
    func moveImage(moveImageAtIndex sourceIndex: Int, toIndex destinationIndex: Int) {
        
        let image = images.removeAtIndex(sourceIndex)
        
        images.insert(image, atIndex: destinationIndex)
        
        isRendered = false

    }
    
    // Creates data context for PDF focument.
    func render() {

        if isRendered {
        
            return
            
        }
        
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, [:])
        
        // Specify dimensions of PDF file pages.
        let rect = CGRect(x: 0, y: 0, width: 612, height: 792).insetBy(dx: 18, dy: 18)

        for image in images {
            
            renderImage(image, inRect: rect)
            
        }
        
        UIGraphicsEndPDFContext()
        
        data.writeToURL(previewItemURL, atomically: true)
        
        isRendered = true
        
    }
    
    // "Draws" the images onto the PDF document.
    private func renderImage(var image: UIImage, inRect rect: CGRect) {
        
        UIGraphicsBeginPDFPage()
        
            //  Rotate image to optimize the size of the photograph in document.
            if image.size.width > image.size.height {
                
                image = UIImage(CGImage: image.CGImage!, scale: 1.0, orientation: UIImageOrientation.Right)
                
            }
        
            // Specify ratio of PDF file and image.
            var newRect = rect
            
            let widthRatio = rect.width / image.size.width
            
            let heightRatio = rect.height / image.size.height
            
            let ratio = min(heightRatio, widthRatio)
            
            newRect.size.width = image.size.width * ratio
            
            newRect.size.height = image.size.height * ratio
            
            newRect.origin.x += (rect.width - newRect.width) / 2
            
            newRect.origin.y += (rect.height - newRect.height) / 2
            
            image.drawInRect(newRect)
        
    }
    
}

// Specify file name and path for PDF file.
extension PDF: QLPreviewItem {
    
    var previewItemURL: NSURL {
        
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!.URLByAppendingPathComponent("Converter.pdf")
        
    }
    
    var previewItemTitle: String? {
        
        return "Converter"
        
    }
    
}
