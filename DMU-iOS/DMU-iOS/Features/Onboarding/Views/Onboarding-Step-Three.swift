//
//  Onboarding-Step-Three.swift
//  DMU-iOS
//
//  Created by 이예빈 on 12/29/23.
//

import SwiftUI

struct Onboarding_Step_Three: View {
    
    @State private var isNotificationOn = false
    @State private var isMainViewActive = false
    
    @ObservedObject var viewModel: NotificationViewModel
    
    @StateObject private var userSettings = UserSettings()
    
    @Binding var isFirstLanching: Bool
    
    var body: some View {
        
        OnboardingStepThreeTitleView()
        
        OnboardingStepThreeProgressBarView()
        
        OnboardingStepThreeSetNotificationView(isOn: $isNotificationOn, userSettings: userSettings)
        
        Spacer()
        
        CustomButton(title: "시작하기", action: {
            if self.isNotificationOn {
                viewModel.initToken()
            }
            self.isMainViewActive = true
            isFirstLanching.toggle()
        }, isEnabled: true)
        .padding(.bottom, 20)
        .fullScreenCover(isPresented: $isMainViewActive){
            TabBarView(viewModel: TabBarViewModel())
        }
    }
}

// MARK: - 온보딩 화면 3단계 타이틀 뷰
struct OnboardingStepThreeTitleView: View {
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 0){
                        Text("키워드 알림 설정")
                            .font(.Bold32)
                            .foregroundColor(Color.Blue300)
                            .environment(\.sizeCategory, .large)
                        
                        Text("으로")
                            .font(.Bold32)
                            .foregroundColor(Color.Gray500)
                            .environment(\.sizeCategory, .large)
                    }
                    Text("중요한 공지사항을 놓치지 마세요!")
                        .font(.Bold24)
                        .foregroundColor(Color.Gray500)
                        .environment(\.sizeCategory, .large)
                }
            }
            .padding(.leading, -20)
        }
        .padding(.top, 60)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - 온보딩 화면 3단계 프로그레스바
struct OnboardingStepThreeProgressBarView: View {
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                HStack {
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundColor(Color.Gray300)
                    
                    Spacer()
                    
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundColor(Color.Gray300)
                    
                    Spacer()
                    
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundColor(Color.Blue300)
                }
                .frame(width: geometry.size.width * 0.6, height: 2)
                .background(Color.Gray300)
                
                HStack {
                    Spacer()
                    
                    Text("알림 설정")
                        .foregroundColor(Color.Blue300)
                        .font(.Bold16)
                        .environment(\.sizeCategory, .large)
                        .padding(.top, 10)
                }
                .padding(.trailing, geometry.size.width * 0.14)
                
            }
            .padding(.top, 40)
        }
        .frame(height: 82)
    }
}

// MARK: - 온보딩 화면 3단계 알림 설정 토글 뷰
struct OnboardingStepThreeSetNotificationView: View {
    
    @Binding var isOn : Bool
    
    @Environment(\.openURL) var openURL
    
    @ObservedObject var userSettings: UserSettings
    
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            HStack {
                HStack{
                    Image(systemName: "bell.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(isOn ? Color.Blue300 : Color.Gray400)
                        .padding(.trailing, 16)
                    
                    Text("키워드 알림 설정")
                        .font(.SemiBold20)
                        .foregroundColor(isOn ? Color.Blue300 : Color.Gray400)
                        .environment(\.sizeCategory, .large)
                    
                    Spacer()
                    
                    Toggle(isOn: $isOn) {
                        Text("")
                    }
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: Color.Blue300))
                }
                .frame(width: 240, height: 31)
            }
            .padding()
            .frame(width: 320, height: 80)
            .background(Color.white)
            .cornerRadius(15)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(isOn ? Color.Blue300 : Color.Gray400, lineWidth: 2))
            .shadow(color: isOn ? Color.Blue300.opacity(0.3) : Color.Gray400.opacity(0.3), radius: 30, x: 0, y: 1)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("기기 알림이 꺼져 있습니다."),
                    message: Text("기기 알림(설정 > 알림 > DMforU)을 켜야 공지사항에 대한 키워드 알림을 받을 수 있습니다."),
                    primaryButton: .cancel(Text("닫기")),
                    secondaryButton: .default(Text("설정으로 이동")) {
                        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                )
            }
            .onChange(of: isOn) { newValue in
                if newValue {
                    checkNotificationAuthorization()
                }
                
                userSettings.isDepartmentNotificationOn = newValue
                userSettings.isKeywordNotificationOn = newValue
            }
        }
        .padding(.top, 96)
    }
    
    // MARK: 알림 권한 상태 여부 확인
    private func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus != .authorized {
                DispatchQueue.main.async {
                    self.showingAlert = true
                }
            }
        }
    }
}

#Preview {
    Onboarding_Step_Three(viewModel: NotificationViewModel(userSettings: UserSettings()), isFirstLanching: .constant(true))
}
