import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct ZenoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var commViewModel = CommViewModel()
    @StateObject private var mypageViewModel = MypageViewModel()
    @StateObject private var alarmViewModel: AlarmViewModel = AlarmViewModel()
    @StateObject private var iAPStore: IAPStore = IAPStore()
	
	@AppStorage("fcmToken") var fcmToken: String = ""
    
    init() {
        let kakaoKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY")
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: kakaoKey as? String ?? "")
    }
    
    var body: some Scene {
        WindowGroup {
            InitialView()
                .environmentObject(userViewModel)
                .environmentObject(commViewModel)
                .environmentObject(mypageViewModel)
                .environmentObject(alarmViewModel)
                .environmentObject(iAPStore)
                .onReceive(SignStatusObserved.shared.$signStatus, perform: { newValue in
                    Task {
                        switch newValue {
                        case .signIn:
                            print("✔️signIn")
                            try? await userViewModel.loadUserData()
                        case .unSign:
                            print("✔️unsign")
                            userViewModel.currentUser = nil
                            userViewModel.userSession = nil
                        }
                        
                        if let currentUser = userViewModel.currentUser {
                            await alarmViewModel.fetchAlarmPagenation(showUserID: currentUser.id)
                            SignStatusObserved.shared.isNeedLogin = false
							await userViewModel.updateUserFCMToken(fcmToken)
                        } else {
                            SignStatusObserved.shared.isNeedLogin = true // signIn상태가 아닌데 currentUser값을 가져오지 못하면
                        }
                        
                        print("✔️ userInfo :\(String(describing: userViewModel.currentUser))")
                        if let currentUser = userViewModel.currentUser {
                            if commViewModel.currentUser == nil {
                                // snapshot 연결
                                commViewModel.login(id: currentUser.id)
                            }
                        } else {
                            commViewModel.logout()
                        }
                    }
                })
//                .onChange(of: userViewModel.currentUser) { newValue in
//                    Task {
//                        if let newValue {
//                            await alarmViewModel.fetchAlarmPagenation(showUserID: currentUser.id)
//                        }
//                    }
//                    userViewModel의 currentUser가 있을 때
//                    if newValue != nil {
//                        // commViewModel의 currentUser가 없을 때
//                        if commViewModel.currentUser == nil {
//                            guard let newValue else { return }
//                            // snapshot 연결
//                            commViewModel.login(id: newValue.id)
//                        }
//                        // userViewModel의 currentUser가 없을 때
//                    } else {
//                        // snapshot 해제
//                        commViewModel.logout()
//                    }
//                }
//            commViewModel.updateCurrentUser(user: newValue)
                .onOpenURL { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {  // 딥링크 연결
                        _ = AuthController.handleOpenUrl(url: url) // 린트인가 에러떠서 걍 넣어줌. let _ 이부분.
                    }
                }
        }
    }
}
