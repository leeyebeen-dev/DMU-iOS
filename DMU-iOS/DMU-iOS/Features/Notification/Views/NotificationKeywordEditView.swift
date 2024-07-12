//
//  NotificationKeywordEditView.swift
//  DMU-iOS
//
//  Created by 이예빈 on 1/16/24.
//

import SwiftUI

struct NotificationKeywordEditView: View {
    
    @State private var showKeywordBalloon = true
    @State private var tempSettingKeywords: [String] = []
    
    @ObservedObject var userSettings = UserSettings()
    @ObservedObject var viewModel: SettingViewModel
    
    @Binding var isNavigatingToKeywordEditView: Bool
    
    var body: some View {
        VStack {
            NotificationKeywordEditTopBarView(isNavigatingToKeywordEditView: $isNavigatingToKeywordEditView)
            
            ZStack(alignment: .bottom) {
                // 키워드 리스트
                CustomKeyword(selectedKeywords: $tempSettingKeywords)
                
                if showKeywordBalloon {
                    NotificationKeywordEditBalloonView()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showKeywordBalloon = false
                                }
                            }
                        }
                }
            }
            
            Spacer()
            
            // MARK: 키워드 설정 완료 버튼
            CustomButton(
                title: "완료",
                action: {
                    viewModel.saveKeyword(keywords: tempSettingKeywords)
                    viewModel.postUpdateKeyword()
                    isNavigatingToKeywordEditView = false
                },
                isEnabled: !tempSettingKeywords.isEmpty
            )
            
            Spacer()
        }
        .onAppear {
            self.tempSettingKeywords = viewModel.settingKeywordsContents
        }
    }
}

// MARK: -키워드 설정 화면 상단바 뷰
struct NotificationKeywordEditTopBarView: View {
    
    @Binding var isNavigatingToKeywordEditView: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                isNavigatingToKeywordEditView = false
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(Color.black)
                    .padding()
            }
            
            Spacer()
            
            Text("키워드 설정")
                .font(.SemiBold20)
                .foregroundColor(Color.Gray500)
                .environment(\.sizeCategory, .large)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "xmark").hidden()
            }
            .padding()
            .disabled(true)
        }
    }
}

// MARK: -키워드 설정 화면 키워드 말풍선(5초 유지)
struct NotificationKeywordEditBalloonView: View {
    
    var body: some View {
        VStack {
            Text("키워드를 설정하고 키워드 알림을 받아보세요!")
                .font(.SemiBold13)
                .environment(\.sizeCategory, .large)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .foregroundColor(Color.Blue300)
                .background(Color.Blue200)
                .cornerRadius(10)
                .padding(.horizontal)
                .overlay(
                    Triangle()
                        .fill(Color.Blue200)
                        .frame(width: 20, height: 10)
                        .offset(x: 0, y: 10),
                    alignment: .bottom
                )
        }
        .offset(y: -20)
    }
}

// MARK: -키워드 설정 화면 말풍선 밑에 화살표 설정
struct Triangle: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    NotificationKeywordEditView(viewModel: SettingViewModel(userSettings: UserSettings()), isNavigatingToKeywordEditView: .constant(true))
}
