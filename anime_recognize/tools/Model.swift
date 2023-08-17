import SwiftUI

// 检测信息
struct PeopleInfo:Hashable {
    let image: Image
    let name: String
    let distance: Float
    let feature: [Float]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(feature)
    }
}

// 图像检测结果
struct DetectionResult {
    let image: UIImage // 检测图片结果
    let peoples: [PeopleInfo] // 检测到的人物
}


// 人脸数据信息
struct FaceInfo: Decodable {
    let name: String
    let feature: [Float]
    let url: String? = nil
}

