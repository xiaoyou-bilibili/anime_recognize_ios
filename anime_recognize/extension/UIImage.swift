import SwiftUI

enum ImageType {
    case Component8
    case BGRA32
}

// 对UIimage进行扩展，添加新方法
extension UIImage {
    // 对图片进行缩放
    func resize(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize.width, height: newSize.height), true, 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return resizedImage
    }
    
    // 图片裁剪
    func cropped(boundingBox: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage?.cropping(to: boundingBox) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
    
    private func toPixelBuffer(type: ImageType) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        var formatType: OSType
        var cgColorSpace: CGColorSpace
        var bitmapInfo: UInt32
        
        switch(type) {
        case .BGRA32:
            formatType = kCVPixelFormatType_32ARGB
            cgColorSpace = CGColorSpaceCreateDeviceRGB()
            bitmapInfo = CGImageAlphaInfo.noneSkipFirst.rawValue
        case .Component8:
            formatType = kCVPixelFormatType_OneComponent8
            cgColorSpace = CGColorSpaceCreateDeviceGray()
            bitmapInfo = CGImageAlphaInfo.none.rawValue
        }
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), formatType, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
          return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: cgColorSpace, bitmapInfo: bitmapInfo)

        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }

    // 把当前UI转换为pixelBufferComponent8格式
    func toPixelBufferComponent8() -> CVPixelBuffer? {
        return toPixelBuffer(type: ImageType.Component8)
    }
    
    func toPixelBuffer32BGRA() -> CVPixelBuffer? {
        return toPixelBuffer(type: ImageType.BGRA32)
    }
}
