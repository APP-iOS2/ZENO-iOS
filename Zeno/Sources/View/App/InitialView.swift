import SwiftUI

struct InitialView: View {
    //    @StateObject var contentViewModel = ContentViewModel()
    @EnvironmentObject private var userViewModel: UserViewModel
    @State var isLoading: Bool = true
    @State private var isNickChangeSheet = false
    @AppStorage("nickNameChanged") private var isnickNameChanged = false // 닉변 안했으면 하게 한다.
    
    var body: some View {
        ZStack {
            Group {
                // 로그인 분기 처리
                if userViewModel.signStatus == .signIn {
                    TabBarView()
                        .fullScreenCover(isPresented: $isNickChangeSheet) {
                            NickNameRegistView() // 처음 회원가입시에만 뜨는 뷰
                        }
                } else {
                    LoginView()
                        .environmentObject(EmailLoginViewModel())
                        .tint(ZenoAsset.Assets.mainPurple1.swiftUIColor)
                }
            }
            // 런치스크린
            if isLoading {
                launchScreenView.transition(.opacity).zIndex(1)
            }
        }
        .onReceive(userViewModel.$isNickNameRegistViewPop, perform: { chg in
            print("🦕chg : \(chg.description)")
            if chg { isNickChangeSheet = true }
        })
        .onAppear {
            print("🦕sign : \(userViewModel.signStatus.rawValue)")
            print("🦕nick : \(isnickNameChanged.description)")
            
            // 런치스크린 타이머
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                withAnimation { isLoading.toggle() }
                if !isnickNameChanged {
                    isNickChangeSheet.toggle()
                }
            })
        }
    }
}

extension InitialView {
    /// 런치스크린
    var launchScreenView: some View {
        ZStack(alignment: .center) {
            LinearGradient(gradient: Gradient(colors: [Color("MainPink2"), Color("MainPink3")]),
                           startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            VStack {
                LottieView(lottieFile: "nudgeDevil")
                    .frame(width: 100, height: 100)
                Text("Zeno")
                    .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 60))
                    .fontWeight(.black)
                    .foregroundStyle(LinearGradient(
                        colors: [Color("MainPurple1"), Color("MainPurple2")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        InitialView()
            .environmentObject(UserViewModel())
    }
}
