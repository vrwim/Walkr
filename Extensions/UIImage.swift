//
//  UIImage.swift
//  Walkr (iOS)
//
//  Created by Wim Van Renterghem on 25/03/2021.
//

import UIKit

extension UIImage {
    func fixedOrientation() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        self.draw(in: CGRect(origin: .zero, size: self.size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func crop(scaledRectWidth: CGFloat, scaledRectHeight: CGFloat, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat) -> UIImage? {
        guard let cgImage = cgImage else {
            return nil
        }
        let xScale = size.width / scaledRectWidth
        let yScale = size.height / scaledRectHeight
        let newWidth = xScale * (scaledRectWidth - paddingLeft - paddingRight)
        let newHeight = yScale * (scaledRectHeight - paddingTop - paddingBottom)
        let croppedRect = CGRect(x: paddingLeft * xScale, y: paddingTop * yScale, width: newWidth, height: newHeight)
        return cgImage.cropping(to: croppedRect).map(UIImage.init)
    }
    
    func saveImage(key: String) {
        guard let data = jpegData(compressionQuality: 0.5) else { return }
        let encoded = try! PropertyListEncoder().encode(data)
        UserDefaults.standard.set(encoded, forKey: key)
    }

    static func loadImage(key: String) -> UIImage? {
         guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
         let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
         return UIImage(data: decoded)
    }
}
