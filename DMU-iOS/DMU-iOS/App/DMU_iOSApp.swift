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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(UserSettings())
        }
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
