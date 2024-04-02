//
//  SettingView.swift
//  DMU-iOS
//
//  Created by 이예빈 on 12/31/23.
//

import SwiftUI

struct SettingView: View {
    
    @State var isNavigatingSettingToKeywordEditView = false
    @State var isNavigationSettingToDepartmentSettingView = false
    
    @StateObject var viewModel: SettingViewModel
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("설정")
                    .font(.system(size: 20, weight: .semibold))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color.Gray500)
                    .environment(\.sizeCategory, .large)
                
                Text("대학 공지")
                    .font(.SemiBold15)
                    .foregroundColor(Color.Blue300)
                    .padding(.horizontal, 20)
                    .environment(\.sizeCategory, .large)
                
                Toggle(isOn: $viewModel.userSettings.isKeywordNotificationOn) {
                    Text("알림 설정")
                        .font(.Medium18)
                        .foregroundColor(Color.Gray500)
                        .environment(\.sizeCategory, .large)
                }
                .toggleStyle(SwitchToggleStyle(tint: Color.Blue300))
                .padding(.horizontal, 20)
                .onChange(of: viewModel.userSettings.isKeywordNotificationOn) { newValue in
                    if newValue {
                        viewModel.postUpdateKeyword()
                        print("\(UserSettings().selectedKeywordsContents)가 업데이트 되었습니다.")
                    } else {
                        viewModel.postDeleteKeyword()
                    }
                }
                
                Button(action: {
                    self.isNavigatingSettingToKeywordEditView.toggle()
                }) {
                    Text("키워드 설정")
                        .font(.Medium18)
                        .foregroundColor(Color.Gray500)
                        .environment(\.sizeCategory, .large)
                }
                .padding(.horizontal, 20)
                .fullScreenCover(isPresented: $isNavigatingSettingToKeywordEditView) {
                    NotificationKeywordEditView(viewModel: viewModel, isNavigatingToKeywordEditView: $isNavigatingSettingToKeywordEditView)
                }
                
                Divider()
                
                Text("학과 공지")
                    .font(.SemiBold15)
                    .foregroundColor(Color.Blue300)
                    .padding(.horizontal, 20)
                    .environment(\.sizeCategory, .large)
                
                Toggle(isOn: $viewModel.userSettings.isDepartmentNotificationOn) {
                    Text("알림 설정")
                        .font(.Medium18)
                        .foregroundColor(Color.Gray500)
                        .environment(\.sizeCategory, .large)
                }
                .toggleStyle(SwitchToggleStyle(tint: Color.Blue300))
                .padding(.horizontal, 20)
                .onChange(of: viewModel.userSettings.isDepartmentNotificationOn) { newValue in
                    if newValue {
                        viewModel.postUpdateDepartment()
                    } else {
                        viewModel.postDeleteDepartment()
                    }
                }
                
                HStack {
                    Text("학과 설정")
                        .font(.Medium18)
                        .foregroundColor(Color.Gray500)
                        .environment(\.sizeCategory, .large)
                    
                    Spacer()
                    
                    Button(action: {
                        self.isNavigationSettingToDepartmentSettingView.toggle()
                    }) {
                        HStack {
                            Text(viewModel.userSettings.selectedDepartment)
                                .font(.Medium14)
                                .foregroundColor(Color.Gray400)
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.Gray500)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Divider()
                
                Text("앱 정보")
                    .font(.SemiBold15)
                    .foregroundColor(Color.Blue300)
                    .padding(.horizontal, 20)
                    .environment(\.sizeCategory, .large)
                
                Link(destination: URL(string: "https://forms.gle/dKdiLdKwNGmQdb11A")!) {
                    Text("문의하기")
                        .font(.Medium18)
                        .foregroundColor(Color.Gray500)
                        .environment(\.sizeCategory, .large)
                }
                .padding(.horizontal, 20)
                
                NavigationLink(destination:
                                SettingWebViewDetail(urlString: "https://sites.google.com/view/dmforu-privacy-policy/%ED%99%88")){
                    Text("개인정보 처리방침")
                        .font(.Medium18)
                        .foregroundColor(Color.Gray500)
                        .padding(.horizontal, 20)
                        .environment(\.sizeCategory, .large)
                }
                
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                        openURL(url)
                    }
                }, label: {
                    Text("오픈소스 라이선스")
                        .font(.Medium18)
                        .foregroundColor(Color.Gray500)
                        .padding(.horizontal, 20)
                        .environment(\.sizeCategory, .large)
                })
                
                HStack {
                    Text("앱 버전")
                        .font(.Medium18)
                        .foregroundColor(Color.Gray500)
                        .environment(\.sizeCategory, .large)
                    
                    Spacer()
                    
                    Text("1.0.0")
                        .font(.Medium14)
                        .foregroundColor(Color.Gray400)
                        .environment(\.sizeCategory, .large)
                }
                .padding(.horizontal, 20)
                
                Divider()
                
                Spacer()
            }
            .navigationDestination(isPresented: $isNavigationSettingToDepartmentSettingView) {
                SettingDepartmentView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    SettingView(viewModel: SettingViewModel(userSettings: UserSettings()))
}
