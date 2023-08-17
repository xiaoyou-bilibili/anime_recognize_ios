import SwiftUI
//import Toast_Swift

enum DetectState {
    case Start
    case Doing
    case Finish
}

struct FaceDection: View {
    @EnvironmentObject var dataManager: DataManager
    
    @State private var image: UIImage? = nil
    @State private var showImagePicker = false
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
            if let result = self.modelManage.dectImage(image: self.image!, dataManager: dataManager) {
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
                }) {
                    Text("选择图片")
                }
            }
            
            if detectState == DetectState.Doing  {
                ProgressView()
                Text("检测中").padding(.top, 1.0)
            }
            
            if detectState == DetectState.Finish {
                Image(uiImage: image ?? UIImage()).resizable().scaledToFit()
                List(peoples, id: \.self) { image in
                    HStack {
                        image.image.resizable().aspectRatio(contentMode: .fit).frame(height: 35, alignment: SwiftUI.Alignment.center)
                        /*@START_MENU_TOKEN@*/Text(image.name)/*@END_MENU_TOKEN@*/
                        Text("\(image.distance)")
                    }.padding(.leading, 10)
                }.padding(-10)
            }
        }
        .sheet(isPresented: $showImagePicker, onDismiss: recognition) {
            ImagePicker(image: self.$image)
        }.toast(isShow: $showToast, info: toastText)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FaceDection()
    }
}

