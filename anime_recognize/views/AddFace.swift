import SwiftUI
//import Toast_Swift

struct AddFace: View {
    @EnvironmentObject var dataManager: DataManager
    
    @State private var showImagePicker = false
    @State private var isPresentingAlert = false
    @State private var currentFeature:[Float] = []
    @State private var peopleName: String = "" // 输入用户名

    
    @State private var image: UIImage? = nil
    @State private var peoples: [PeopleInfo] = []
    @State private var detectState: DetectState = DetectState.Start
    @State private var showToast: Bool = false
    @State private var toastText: String = ""
    
    private var modelManage = ModelManager()
    
    func showToast (message: String) {
        toastText = message
        showToast = true
    }

    
    func recognition() {
        if(self.image != nil) {
            if let result = self.modelManage.dectImage(image: self.image!, needDistance: false) {
                self.image = result.image
                self.peoples = result.peoples
            }
            detectState = DetectState.Finish
        } else {
            showToast(message: "未选择图片")
            detectState = DetectState.Start
        }
    }

    var body: some View {
        VStack {
            if detectState != DetectState.Doing {
                Button(action: {
                    self.showImagePicker = true
                    detectState = DetectState.Doing
                }, label: { Text("选择图片") })
            }
            
            if detectState == DetectState.Doing  {
                ProgressView()
                Text("检测中").padding(.top, 1.0)
            }
            
            if detectState == DetectState.Finish {
                Image(uiImage: image ?? UIImage()).resizable().scaledToFit()
                List(peoples, id: \.self) { image in
                    HStack {
                        Section {
                            Text("")
                            image.image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 35, alignment:SwiftUI.Alignment.center)
                            Button(action: {
                                currentFeature = image.feature
                                peopleName = ""
                                isPresentingAlert = true
                            }) {
                                Text("添加")
                            }
                        }
                    }
                }.padding(-10)
            }
        }
        .sheet(isPresented: $showImagePicker, onDismiss: recognition) {
            ImagePicker(image: $image)
        }
        .alert("输入角色名字", isPresented: $isPresentingAlert){ // 输入角色姓名弹窗
            TextField(text: $peopleName, prompt: Text("输入角色姓名")){}
            Button(action: {
                if peopleName != "" {
                    if dataManager.AddFace(info: FaceInfo(name: peopleName, feature: currentFeature)) {
                        showToast(message: "添加成功")
                    } else {
                        showToast(message: "添加失败")
                    }
                } else {
                    showToast(message: "名字不能为空！")
                }
            }, label: {Text("确定")})
        }.toast(isShow: $showToast, info: toastText)
    }
}


struct AddFaceView_Previews: PreviewProvider {
//    static let data:[PeopleInfo] = [PeopleInfo(image: Image(systemName: "plus.circle.fill"), name: "测试", distance: 1.1, feature: [])]
    static var previews: some View {
//        AddFace()
        VStack{
            HStack {
                Section(header: Text("Section 1")) {
                    Text("测试")
                    Text("测试2")
                    Text("测试3")
                }
            }
            HStack {
                Section {
                    Text("测试")
                    Text("测试2")
                    Text("测试3")
                }
            }
        }
    }
}

