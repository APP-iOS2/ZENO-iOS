import SwiftUI

struct InitialView: View {
    //    @StateObject var contentViewModel = ContentViewModel()
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var isLoading: Bool = true
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
            if isLoading && !isnickNameChanged {
                launchScreenView.transition(.opacity).zIndex(1)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onReceive(userViewModel.$isNickNameRegistViewPop, perform: { chg in
            // isNickNameRegistViewPop을 true로 바꿔주는 시점이 onAppear가 끝난 시점이라서 onReceive에서 받아서 처리.
            print("🦕chg : \(chg.description)")
            if chg { isNickChangeSheet = true }
        })
        .onAppear {
            print("🦕sign : \(userViewModel.signStatus.rawValue)")
            print("🦕nick : \(isnickNameChanged.description)")
            
            // 회원가입이 완료되지않았을때만 온보딩과 회원가입뷰 뿌려준다.
            // 런치스크린 타이머
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                withAnimation(.easeInOut(duration: 0.8)) {
                    isLoading = false
                }
                if !isnickNameChanged {
                    isNickChangeSheet = true
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
