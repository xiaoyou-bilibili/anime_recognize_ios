//
//  anime_recognizeTests.swift
//  anime_recognizeTests
//
//  Created by xiaoyou on 2023/7/13.
//

import XCTest
import Foundation
@testable import anime_recognize
import CoreData
import CoreML

struct FaceInfo : Codable {
    let name: String
    let feature: [Float]
    let url:String
}


final class anime_recognizeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // 把MLMultiArray 转换为 [Float] 类型
    func MLMultiArrayToFloatArray(_ multiArray: MLMultiArray) -> [Float]? {
        guard multiArray.dataType == .float32 else {
            return nil // 确保 MLMultiArray 的数据类型为 Float32
        }
        
        let pointer = UnsafeMutablePointer<Float32>(OpaquePointer(multiArray.dataPointer))
        let buffer = UnsafeBufferPointer(start: pointer, count: multiArray.count)
        
        return Array(buffer)
    }
    
    
    func testConvertImages() throws {
        // 加载一下yolo检测器
        let arce = try? arce_face(configuration: MLModelConfiguration())
        let fileManager = FileManager.default
        let jsonEncoder = JSONEncoder()
        // 最终结果
        let fileOutURL = URL(fileURLWithPath: "/Users/xiaoyou/Downloads/images/res.txt")
        let fileHandle = try FileHandle(forWritingTo: fileOutURL)
        fileHandle.seekToEndOfFile()
        // 读取一下文本文件
        let fileURL = URL(fileURLWithPath: "/Users/xiaoyou/Downloads/images/info.txt")
        do {
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = fileContent.components(separatedBy: .newlines)
            // 遍历读取
            for line in lines {
                // 使用正则去匹配出所有对应的值
                let regex = try! NSRegularExpression(pattern: "'(id|name|url)':\\s*'([^']*)'", options: [])
                let matches = regex.matches(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count))
                var (id,name,url) = ("","","")
                for match in matches {
                    let fieldNameRange = match.range(at: 1)
                    let fieldValueRange = match.range(at: 2)
                    let fieldName = (line as NSString).substring(with: fieldNameRange)
                    let fieldValue = (line as NSString).substring(with: fieldValueRange)
                    switch fieldName {
                    case "id":
                        id = fieldValue
                    case "name":
                        name = fieldValue
                    case "url":
                        url = fieldValue
                    default:
                        print("pass")
                    }
                }
                print("id \(id) name \(name) url \(url)")
                // 只提取出对应的ID
                id = id.replacingOccurrences(of: "personai_icartoonface_rectrain_", with: "")
                // 读取下面的图片
                do {
                    let imgPath = "/Users/xiaoyou/Downloads/images/images/\(id)"
                    var files = try fileManager.contentsOfDirectory(atPath: imgPath)
                    files.shuffle()
                    // 随机从图片中取出2个
                    for file in Array(files.prefix(2)) {
                        // 读取图片
                        let imgUrl = "\(imgPath)/\(file)"
                        do {
                            if let image = UIImage(contentsOfFile: imgUrl) {
                                let imageResize = image.resize(to: CGSize(width: 128, height: 128))
                                // 获取图片特征
                                if let buffer = imageResize.toPixelBufferComponent8() {
                                    if let out = try? arce?.prediction(input: arce_faceInput(image: buffer)) {
                                        if let feature = MLMultiArrayToFloatArray(out.feature) {
                                            // 转换为json数据
                                            if let jsonData = try? jsonEncoder.encode(FaceInfo(name: name, feature: feature, url: url)) {
                                                fileHandle.write(jsonData)
                                                fileHandle.write("\n".data(using: .utf8)!)
                                                print("load image \(imgUrl) success!")
                                            }
                                        }
                                    }
                                }
                            }
                        } catch {
                            print("read file err \(error)")
                        }
                    }
                } catch {
                    print("Error while getting files: \(error), id \(id)")
                }
            }
        } catch {
            print("Error while reading file: \(error)")
        }
        fileHandle.closeFile()
    }

    
    func testGetImageFeature() throws {
        let decoder = JSONDecoder()
        // 读取一下文本文件
        let fileURL = URL(fileURLWithPath: "/Users/xiaoyou/Downloads/images/res.txt")
        do {
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = fileContent.components(separatedBy: .newlines)
            print(lines.count)
            for line in lines {
                do {
                    let face = try decoder.decode(FaceInfo.self, from: line.data(using: .utf8)!)
                    print(face.name) // 输出person的名字
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

}
