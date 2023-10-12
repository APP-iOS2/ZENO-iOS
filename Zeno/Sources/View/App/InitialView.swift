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
        .edgesIgnoringSafeArea(.all)
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
        InitView()
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        InitialView()
            .environmentObject(UserViewModel())
    }
}
