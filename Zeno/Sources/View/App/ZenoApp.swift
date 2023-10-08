import SwiftUI
import FirebaseCore
import KakaoSDKCommon
import KakaoSDKAuth

class AppDelegate: UIResponder, UIApplicationDelegate {
        
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase 설정
        guard let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: filePath)
        else { return true }
        
        FirebaseApp.configure(options: options)
        
        return true
    }
}

@main
struct ZenoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var commViewModel = CommViewModel()
    
    init() {
        let kakaoKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY")
//        print("kakaoKey = \(kakaoKey)")
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: kakaoKey as? String ?? "")
    }
    
    var body: some Scene {
        WindowGroup {
            InitialView()
                .environmentObject(userViewModel)
                .environmentObject(commViewModel)
                .onChange(of: userViewModel.currentUser) { newValue in
                    commViewModel.updateCurrentUser(user: newValue)
                }
                .onOpenURL { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {  // 딥링크 연결
                        _ = AuthController.handleOpenUrl(url: url) // 린트인가 에러떠서 걍 넣어줌. let _ 이부분.
                    }
                }
        }
    }
}
