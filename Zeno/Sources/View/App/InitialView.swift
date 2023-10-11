import SwiftUI

struct InitialView: View {
    //    @StateObject var contentViewModel = ContentViewModel()
    @EnvironmentObject private var userViewModel: UserViewModel
    @State var isLoading: Bool = true
    
    var body: some View {
        ZStack {
            Group {
                // 로그인 분기 처리
                if userViewModel.signStatus == .signIn {
                    TabBarView()
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
        .onAppear {
            // 런치스크린 타이머
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5, execute: {
                withAnimation { isLoading.toggle() }
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
