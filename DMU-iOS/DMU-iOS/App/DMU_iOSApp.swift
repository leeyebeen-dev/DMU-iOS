//
//  DMU_iOSApp.swift
//  DMU-iOS
//
//  Created by 이예빈 on 12/26/23.
//

import SwiftUI

import Firebase
import FirebaseMessaging

@main
struct DMU_iOSApp: App {
    
    init() {
        //MARK: 탭바 배경화면 투명도 제거
        let appearanceTabBar = UITabBarAppearance()
        
        appearanceTabBar.configureWithOpaqueBackground()
        appearanceTabBar.backgroundColor = UIColor.white
        
        UITabBar.appearance().barTintColor = UIColor.white
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().standardAppearance = appearanceTabBar
        
        //MARK: 네비게이션바 투명도, 그림자 제거
        let appearanceNavigationBar = UINavigationBarAppearance()
        
        appearanceNavigationBar.configureWithOpaqueBackground()
        appearanceNavigationBar.titleTextAttributes = [.foregroundColor: UIColor.gray500]
        appearanceNavigationBar.backgroundColor = .white
        appearanceNavigationBar.shadowColor = nil
        
        UINavigationBar.appearance().standardAppearance = appearanceNavigationBar
    }
    
    @Environment(\.scenePhase) private var scenePhase
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    checkAndUpdateIfNeeded()
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        checkAndUpdateIfNeeded()
                    }
                }
                .environmentObject(UserSettings())
        }
    }
    
    func checkAndUpdateIfNeeded() {
        AppStoreCheck().latestVersion { marketingVersion in
            DispatchQueue.main.async {
                guard let marketingVersion = marketingVersion else {
                    print("앱스토어 버전을 찾지 못했습니다.")
                    return
                }
                
                // 현재 기기의 버전
                let currentProjectVersion = AppStoreCheck.appVersion ?? ""
                
                // 앱스토어의 버전을 .을 기준으로 나눈 것
                let splitMarketingVersion = marketingVersion.split(separator: ".").compactMap { Int($0) }
                
                // 현재 기기의 버전을 .을 기준으로 나눈 것
                let splitCurrentProjectVersion = currentProjectVersion.split(separator: ".").compactMap { Int($0) }
                
                if splitCurrentProjectVersion.count == 3 && splitMarketingVersion.count == 3 {
                    // 버전을 순차적으로 비교
                    for (current, marketing) in zip(splitCurrentProjectVersion, splitMarketingVersion) {
                        if current < marketing {
                            showUpdateAlert(version: marketingVersion)
                            return
                        } else if current > marketing {
                            print("현재 최신 버전입니다.")
                            return
                        }
                    }
                    print("현재 최신 버전입니다.")
                } else {
                    print("버전 형식이 올바르지 않습니다.")
                }
            }
        }
    }
    
    func showUpdateAlert(version: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("윈도우 씬을 찾을 수 없습니다.")
            return
        }
        
        let alert = UIAlertController(
            title: "업데이트 알림",
            message: "더 나은 서비스를 위해 DMforU가 수정되었어요.\n업데이트할까요?",
            preferredStyle: .alert
        )
        
        let updateAction = UIAlertAction(title: "업데이트", style: .default) { _ in
            // 업데이트 버튼을 누르면 해당 앱스토어로 이동한다.
            AppStoreCheck().openAppStore()
        }
        
        alert.addAction(updateAction)
        window.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

//MARK: - Firebase Cloud Message
class AppDelegate: NSObject, UIApplicationDelegate {
    
    // 앱이 켜졌을때
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Use Firebase library to configure APIs
        // 파이어베이스 설정
        FirebaseApp.configure()
        
        // 원격 알림 등록
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // 메세징 델리겟
        Messaging.messaging().delegate = self
        
        
        // 푸시 포그라운드 설정
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    // fcm 토큰이 등록 되었을 때
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
}

extension AppDelegate : MessagingDelegate {
    
    // fcm 등록 토큰을 받았을 때
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("AppDelegate - Firebase registration token: \(String(describing: fcmToken))")
        
        // UserSettings에 FCM 토큰 저장
        if let token = fcmToken {
            UserDefaults.standard.set(token, forKey: "fcmToken")
        }
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // 푸시메세지가 앱이 켜져 있을때 나올때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        print("willPresent: userInfo: ", userInfo)
        
        completionHandler([.banner, .sound, .badge])
    }
    
    // 푸시메세지를 받았을 때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        print("didReceive: userInfo: ", userInfo)
        
        // url 추출하기
        if let urlString = userInfo[AnyHashable("url")] as? String,
           let url = URL(string: urlString) {
            // 앱이 실행 중일 때 URL 열기
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        completionHandler()
    }
    
}
