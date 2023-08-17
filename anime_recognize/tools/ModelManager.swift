//
//  ModelManager.swift
//  anime_recognize
//
//  Created by xiaoyou on 2023/7/14.
//

import CoreML
import SwiftUI


struct ModelManager {
    private let yolo = try? yolov5(configuration: MLModelConfiguration())
    private let arce = try? arce_face(configuration: MLModelConfiguration())
    
    // 把MLMultiArray 转换为 [Float] 类型
    func MLMultiArrayToFloatArray(_ multiArray: MLMultiArray) -> [Float]? {
        guard multiArray.dataType == .float32 else {
            return nil // 确保 MLMultiArray 的数据类型为 Float32
        }
        
        let pointer = UnsafeMutablePointer<Float32>(OpaquePointer(multiArray.dataPointer))
        let buffer = UnsafeBufferPointer(start: pointer, count: multiArray.count)
        
        return Array(buffer)
    }
    
    // 获取图像的特征
    func getFaceFeature(image: UIImage) -> [Float]? {
        let imageResize = image.resize(to: CGSize(width: 128, height: 128))
        if let buffer = imageResize.toPixelBufferComponent8() {
            if let out = try? self.arce?.prediction(input: arce_faceInput(image: buffer)) {
                return MLMultiArrayToFloatArray(out.feature)
            }
        }
        return nil
    }
    
    // 检测图片，会自动给图片画框
    func dectImage(image: UIImage, dataManager: DataManager? = nil, needDistance: Bool = true) -> DetectionResult? {
        // 对图片进行缩放
        let imageResize = image.resize(to: CGSize(width: 640, height: 640))
        if let buffer = imageResize.toPixelBuffer32BGRA() {
            if let out = try? self.yolo?.prediction(input: yolov5Input(input: buffer, iouThreshold: 0.6, confidenceThreshold: 0.8)) {
                let coordinates = out.coordinates
                let shape = coordinates.shape
                let size = image.size
                var rects:[CGRect] = []
                var detectionPeoples:[PeopleInfo] = []
                // 遍历这些框
                for i in 0..<shape[0].intValue { // 有多少个框
                    // 获取x,y中心点坐标，和框的长度和宽度信息
                    let index = i*shape[1].intValue
                    let (x,y,width,height) = (coordinates[index].doubleValue, coordinates[index+1].doubleValue, coordinates[index+2].doubleValue, coordinates[index+3].doubleValue)
                    let rect = CGRect(x: size.width * (x-width/2), y: size.height * (y-height/2), width: size.width * width, height: size.height * height)
                    rects.append(rect)
                    // 截取出对应的图片
                    if let cropped = image.cropped(boundingBox: rect) {
                        // 获取图片特征
                        if let feature = getFaceFeature(image: cropped) {
                            if needDistance && dataManager != nil {
                                // 计算特征距离
                                let (face, distance) = dataManager!.getCosineSimilarity(feature: feature)
                                detectionPeoples.append(PeopleInfo(image: Image(uiImage: cropped) , name: face.name, distance: distance, feature: feature))
                            } else {
                                detectionPeoples.append(PeopleInfo(image: Image(uiImage: cropped), name: "", distance: 0, feature: feature))
                            }
                        }
                    }
                }
                // 绘制矩形框
                let renderer = UIGraphicsImageRenderer(size: size)
                let resultImage = renderer.image { context in
                    let existingImage = image
                    existingImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                    for rect in rects {
                        let path = UIBezierPath(rect: rect)
                        path.lineWidth = 4
                        context.cgContext.setFillColor(UIColor.clear.cgColor)
                        context.cgContext.setStrokeColor(UIColor.red.cgColor)
                        path.stroke()
                    }
                }
                return DetectionResult(image: resultImage, peoples: detectionPeoples)
            }
            return nil
        }
        return nil
    }
}
