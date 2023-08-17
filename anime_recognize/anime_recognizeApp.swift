//
//  anime_recognizeApp.swift
//  anime_recognize
//
//  Created by xiaoyou on 2023/7/13.
//

import SwiftUI
import CoreData
import UIKit


@main
struct anime_recognizeApp: App {
    // 数据管理器
    @StateObject private var manager: DataManager = DataManager()

    
//    init() {
//        if manager.FaceNum() == 0 {
//            self._isPresentingAlert = State(initialValue: true)
//            print("数据条数1 \(manager.FaceNum())")
//        }
//    }
    
    
    var body: some Scene {
        WindowGroup {
            TabView(){
                FaceDection().tabItem{Label("人脸检测", systemImage: "person.fill")}
                AddFace().tabItem{Label("人脸录入", systemImage: "camera.fill")}
                Setting().tabItem{Label("设置", systemImage: "slider.vertical.3")}
            }
            .environmentObject(manager)
            .environment(\.managedObjectContext, manager.container.viewContext)
        }
    }
}
