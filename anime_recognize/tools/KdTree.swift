import Foundation
import KDTree

struct FaceFratrue: KDTreePoint {
    var feature: [Float]
    var name: String = ""
    
    static var dimensions: Int { return 512 }
    // 获取每一维的地址
    func kdDimension(_ dimension: Int) -> Double {
        return Double(feature[dimension])
        
    }
    // 计算两个向量之间的距离
    func squaredDistance(to otherPoint: Self) -> Double {
        let x = sqrt(feature.reduce(0) { $0 + $1 * $1 })
        let y = sqrt(otherPoint.feature.reduce(0) { $0 + $1 * $1 })
        let dotProduct = zip(feature, otherPoint.feature).reduce(0) { $0 + $1.0 * $1.1 }
        return 1-Double(dotProduct/(x * y))
    }
}
