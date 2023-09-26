import ProjectDescription

let projectName = "Zeno"
let orgName = "https://github.com/gnksbm/Zeno"
let bundleID = "com.Zeno"
let infoPlist: [String: InfoPlist.Value] = [
    "BundleDisplayName": "ZenoAppTest",
    "BundleShortVersionString": "1.0",
    "BundleVersion": "1.0.0",
    "UILaunchStoryboardName": "LaunchScreen",
//    "Fonts provided by application" : [ "BMDOHYEON.tff" ]
    //"LSApplicationQueriesSchemes": ["kakaokompassauth", "kakaolink", "kakao$(KAKAO_APP_KEY)"],
    //"CFBundleURLTypes": [
    //    [
    //        "CFBundleTypeRole": "Editor",
    //        "CFBundleURLSchemes": ["kakao$(KAKAO_APP_KEY)"]
    //    ]
    //],
]
let config = Settings.settings(configurations: [
    .debug(name: "Debug", xcconfig: .relativeToRoot("\(projectName)/Resources/Config/Secrets.xcconfig")),
    .release(name: "Release", xcconfig: .relativeToRoot("\(projectName)/Resources/Config/Secrets.xcconfig")),
])

let project = Project(
    name: projectName,
    organizationName: orgName,
    packages: [
//        .remote(url: "https://github.com/firebase/firebase-ios-sdk", requirement: .upToNextMajor(from: "10.0.0")),
//        .remote(url: "https://github.com/kakao/kakao-ios-sdk", requirement: .upToNextMajor(from: "2.0.0")),
        .remote(url:"https://github.com/airbnb/lottie-ios", requirement: .upToNextMajor(from: "4.0.0"))

    ],
    targets: [
        .init(
            name: "Zeno",
            platform: .iOS,
            product: .app,
            bundleId: bundleID,
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["\(projectName)/Sources/**"],
            resources: ["\(projectName)/Resources/**"],
            scripts: [
                .pre(path: "Scripts/SwiftLintRunScript.sh", arguments: [], name: "SwiftLint"),
            ],
            dependencies: [
//                .package(product: "FirebaseAnalytics"),
//                .package(product: "FirebaseMessaging"),
//                .package(product: "FirebaseFirestore"),
//                .package(product: "FirebaseFirestoreSwift"),
//                .package(product: "KakaoSDKUser"),
//                .package(product: "KakaoSDKAuth"),
//                .package(product: "KakaoSDKCommon"),
                .package(product: "Lottie")
            ],
            settings: config
        )
    ]
)
