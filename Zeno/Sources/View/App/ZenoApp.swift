import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct ZenoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var commViewModel = CommViewModel()
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
                            alarmViewModel.isFetchComplete = false // 로그아웃시 초기화 알람데이터 Fetch완료시 true
                            alarmViewModel.isLoading = false       // 로그아웃시 초기화
                        }
                       
                        print("✔️ userInfo :\(String(describing: userViewModel.currentUser))")
                        if let currentUser = userViewModel.currentUser {
// await [카카오로그인: 로그인 상태관리?] ->
// Firebase 데이터 통신 (userRepo ㅣ currentUser.id(Auth.currentUser) <- [commRepo, alarmRepo])
// Home: userViewModel.currentComm -> currentUser의 Alarm 받아옴 -> joinedComm이 받아와지고난뒤 progress 종료
                            
// await 카카오로그인 확인 -> userViewModel이 firebase에서 정보 가져옴 -> commViewModel이 firebase에서 정보 가져옴
// await commViewModel의 (currentComm에 대한) joinedComm fetch ->
// homeView의 progressview 해제 -> 앱 시작
// myPage에서 user값 계속 fetch commVM sink
                            if commViewModel.currentUser == nil {
                                // snapshot 연결
                                commViewModel.setUserSnapshot(id: currentUser.id) {
                                    Task {
                                        await alarmViewModel.fetchAlarmPagenation(showUserID: currentUser.id)
                                    }
                                }
                            }
                        } else {
                            commViewModel.logout()
                        }

                        if userViewModel.currentUser != nil {
                            SignStatusObserved.shared.isNeedLogin = false
                            await userViewModel.updateUserFCMToken(fcmToken)
                        } else {
                            SignStatusObserved.shared.isNeedLogin = true // signIn상태가 아닌데 currentUser값을 가져오지 못하면
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
