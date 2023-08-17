import CoreData
import Foundation
import Accelerate
import KDTree

/// Main data manager to handle the todo items
class DataManager: NSObject, ObservableObject {
    /// 添加一个coreData
    let container: NSPersistentContainer = NSPersistentContainer(name: "Model")
    // 缓存数据
    private var featureList: [FaceFratrue] = []
    private var faceTree: KDTree<FaceFratrue>?  = nil
    
    func FaceNum() -> Int {
        return featureList.count
    }
    
    // 添加一条人脸特征数据
    func AddFace(info: FaceInfo) -> Bool {
        let context = container.viewContext
        let face = Face(context: context)
        face.name = info.name
        face.feature =  info.feature
        // 判断是否保存成功
        do {
            try context.save()
            reFreshCache()
            return true
        } catch {
            print("保存失败\(error)")
        }
        
        return false
    }
    
    // 计算特征的余弦相似度，并返回最相似的人脸信息
    func getCosineSimilarity(feature: [Float]) -> (FaceInfo, Float) {
        // 将目标向量和多个向量存储在矩阵中
        let face = FaceFratrue(feature: feature)
        if let nearest:FaceFratrue = faceTree!.nearest(to:face) {
            return (FaceInfo(name: nearest.name, feature: nearest.feature), 1-Float(face.squaredDistance(to: nearest)))
        } else {
            return (FaceInfo(name: "", feature: []), -1)
        }
    }
    
    // 刷新缓存
    private func reFreshCache() {
        let request: NSFetchRequest<Face> = Face.fetchRequest()
        var faceList:[FaceInfo] = []
        if let objects = try? container.viewContext.fetch(request) {
            for face in objects {
                if face.feature != nil && face.name != nil {
                    featureList.append(FaceFratrue(feature: face.feature!,name: face.name!))
                }
            }
        }
        faceTree = KDTree(values: featureList)
        print("数据条数 \(featureList.count)")
    }
    
    // 删除数据
    func deleteData() -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Face")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try container.viewContext.execute(batchDeleteRequest)
            return true
        } catch {
            print("Failed to clear Core Data: \(error)")
            return false
        }
    }
    
//    // 获取所有的特征数据
//    func GetFaceList() -> [FaceInfo] {
//        return faceCache
//    }
    
    // 初始化特征数据
    func initData() {
        let context = container.viewContext
        let request: NSFetchRequest<Face> = Face.fetchRequest()
        do {
            let count = try context.count(for: request)
            print("数据条数 \(count)")
            if count == 0 {
                let decoder = JSONDecoder()
                guard let url = Bundle.main.url(forResource: "SeedData", withExtension: "seed") else {
                     fatalError("Could not find seed data file.")
                }
                let fileContent = try String(contentsOf: url, encoding: .utf8)
                let lines = fileContent.components(separatedBy: .newlines)
                for line in lines {
                    do {
                        let data = try decoder.decode(FaceInfo.self, from: line.data(using: .utf8)!)
                        // 写入数据
                        let face = Face(context: context)
                        face.name = data.name
                        face.feature =  data.feature
                        face.url = data.url
                        print("\(data.name) 写入完成") // 输出person的名字
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                try context.save()
            }
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        } catch {
            print("load data err \(error)")
        }
    }
    
    // 加载我们的模型
    override init() {
        super.init()
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
//            self.initData()
        })
        reFreshCache()
    }
}


