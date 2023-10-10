import ProjectDescription

let projectName = "Zeno"
let orgName = "https://github.com/APPSCHOOL3-iOS/final-zeno"
let bundleID = "education.techit.zeno.dev"
let infoPlist: [String: InfoPlist.Value] = [
    "BundleDisplayName": "Zeno",
    "BundleShortVersionString": "1.0",
    "BundleVersion": "1.0.0",
    "UILaunchStoryboardName": "LaunchScreen",
    "UIBackgroundModes": [
        "fetch",
        "processing",
        "remote-notification"
    ],
    "LSApplicationQueriesSchemes": [
        "kakaokompassauth",
        "kakaolink",
        "kakao$(KAKAO_APP_KEY)"
    ],
    "CFBundleURLTypes": [
        [
            "CFBundleTypeRole": "Editor",
            "CFBundleURLSchemes": ["kakao$(KAKAO_APP_KEY)"]
        ],
        [
            "CFBundleTypeRole": "Viewer",
            "CFBundleURLName": "education.techit.zeno.dev",
            "CFBundleURLSchemes": ["ZenoApp"]
        ]
    ],
    "KAKAO_APP_KEY" : "$(KAKAO_APP_KEY)",
	"FIREBASE_PUSH_API_KEY" : "$(FIREBASE_PUSH_API_KEY)",
]
let config = Settings.settings(configurations: [
    .debug(name: "Debug", xcconfig: .relativeToRoot("\(projectName)/Resources/Config/Secrets.xcconfig")),
    .release(name: "Release", xcconfig: .relativeToRoot("\(projectName)/Resources/Config/Secrets.xcconfig")),
])

let project = Project(
    name: projectName,
    organizationName: orgName,
    packages: [
        .remote(url: "https://github.com/simibac/ConfettiSwiftUI", requirement: .upToNextMajor(from: "1.0.0")),
        .remote(url: "https://github.com/firebase/firebase-ios-sdk", requirement: .upToNextMajor(from: "10.0.0")),
        .remote(url: "https://github.com/kakao/kakao-ios-sdk", requirement: .upToNextMajor(from: "2.0.0")),
        .remote(url: "https://github.com/airbnb/lottie-ios", requirement: .upToNextMajor(from: "4.0.0")),
//        .remote(url: "https://github.com/apple/swift-protobuf.git", requirement: .upToNextMajor(from: "1.0.0")),
        .remote(url: "https://github.com/onevcat/Kingfisher", requirement: .upToNextMajor(from: "7.0.0")),
    ],
    targets: [
        .init(
            name: "Zeno",
            platform: .iOS,
            product: .app,
            bundleId: bundleID,
            deploymentTarget: .iOS(targetVersion: "16.4", devices: .iphone),
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["\(projectName)/Sources/**"],
            resources: ["\(projectName)/Resources/**"],
            entitlements: "\(projectName)/\(projectName).entitlements",
            scripts: [
                .pre(path: "Scripts/SwiftLintRunScript.sh", arguments: [], name: "SwiftLint", basedOnDependencyAnalysis: false),
            ],
            dependencies: [
                .package(product: "ConfettiSwiftUI"),
//                .package(product: "SwiftProtobuf"),
                .package(product: "FirebaseAnalytics"),
                .package(product: "FirebaseMessaging"),
                .package(product: "FirebaseFirestore"),
                .package(product: "FirebaseFirestoreSwift"),
				.package(product: "FirebaseAuth"),
                .package(product: "FirebaseStorage"),
				.package(product: "FirebaseDynamicLinks"),
//				.package(product: "FirebaseDatabase"),
//				.package(product: "FirebaseDatabaseSwift"),
                .package(product: "KakaoSDKUser"),
                .package(product: "KakaoSDKAuth"),
                .package(product: "KakaoSDKCommon"),
                .package(product: "Lottie"),
                .package(product: "Kingfisher")
            ],
            settings: config
        )
    ]
)
