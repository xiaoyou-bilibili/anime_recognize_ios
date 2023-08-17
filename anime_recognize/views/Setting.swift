import SwiftUI

struct Setting: View {
    // 数据管理器
    @EnvironmentObject var dataManager: DataManager
    @State private var showToast: Bool = false
    @State private var toastText: String = ""
    @State private var isPresentingAlert = false
    @State private var loading = false
    
    func showToast (message: String) {
        toastText = message
        showToast = true
    }
    
    var body: some View {
        VStack {
            if loading  {
                ProgressView()
                Text("数据导入中").padding(.top, 1.0)
            } else {
                Text("数据总数\(dataManager.FaceNum())").padding(5)
                Button("清空数据"){
                    if dataManager.deleteData() {
                        showToast(message: "删除成功")
                    } else {
                        showToast(message: "删除成功")
                    }
                }.padding(5)
                Button("导入数据"){
                    isPresentingAlert=true
                }.padding(5)
                Button("复制链接"){
                    
                }.padding(5)
            }
        }
        .toast(isShow: $showToast, info: toastText)
        .alert("导入人脸数据", isPresented: $isPresentingAlert){
            Button("确定", role: .destructive){
                loading = true
                // 后台对数据进行处理
                DispatchQueue.main.async {
                    dataManager.initData()
                    loading = false
                }
            }
            Button("取消", role: .cancel){}
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Setting()
    }
}
