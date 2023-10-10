import SwiftUI
import FirebaseCore
import FirebaseDynamicLinks
import FirebaseMessaging
import KakaoSDKCommon
import KakaoSDKAuth

class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    @AppStorage("fcmToken") var fcmToken: String = ""
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase 설정
        guard let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: filePath)
        else { return true }
        
        FirebaseApp.configure(options: options)
        
        // 원격 알림 등록
        UNUserNotificationCenter.current().delegate = self
        
        // 앱에서 사용 가능한 알림 옵션 세팅
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        FirebaseMessaging.Messaging.messaging().delegate = self

        return true
    }
    
    /// fcm 토큰이 등록 되었을 때
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    /// fcm server 에서 받는 토큰 appStorage 에 저장
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("AppDelegate - Firebase registration token: \(String(describing: fcmToken))")
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        self.fcmToken = fcmToken ?? ""
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    /// 푸시메세지가 앱이 켜져 있을 상태에서 push 메세지 받을 때 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        print("willPresent: userInfo: ", userInfo)
        
        completionHandler([.banner, .sound, .badge])
    }
    
    /// 백그라운드 동작 중 psuh 메세지를 받았을 때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("didReceive: userInfo: ", userInfo)
        completionHandler()
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

extension AppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
      let handled = DynamicLinks.dynamicLinks()
        .handleUniversalLink(userActivity.webpageURL!) { dynamiclink, error in
            
        }

      return handled
    }
}
