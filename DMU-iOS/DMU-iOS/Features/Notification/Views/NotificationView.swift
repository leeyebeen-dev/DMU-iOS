//
//  NotificationView.swift
//  DMU-iOS
//
//  Created by 이예빈 on 1/14/24.
//

import SwiftUI

struct NotificationView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject private var viewModel = NotificationViewModel()
    
    @State var isNavigatingToKeywordEditView = false
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.notices) { notice in
                    NotificationListView(notice: notice)
                }
                .padding(.bottom, 8)
            }
            .padding(20)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: NotificationBackButton, trailing: NotificationKeywordEditButton)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("키워드 알림함")
                        .font(.SemiBold20)
                        .foregroundColor(Color.Gray500)
                }
            }
        }
    }
    
    // MARK: 알림함 화면 뒤로가기 버튼
    private var NotificationBackButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.backward")
                .foregroundColor(Color.Gray500)
        }
    }
    
    // MARK: 알림함 화면 키워드 편집 버튼
    private var NotificationKeywordEditButton: some View {
        Button(action: {
            viewModel.editKeywords()
            self.isNavigatingToKeywordEditView.toggle()
        }) {
            Text("편집")
                .font(.Medium16)
                .foregroundColor(Color.Gray500)
        }
        .fullScreenCover(isPresented: $isNavigatingToKeywordEditView) {
            NotificationKeywordEditView(isNavigatingToKeywordEditView: $isNavigatingToKeywordEditView)
        }
    }
}

// MARK: - 알림 내역 리스트뷰
struct NotificationListView: View {
    
    var notice: Notice
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(notice.noticeTitle)
                    .font(.Medium16)
                    .foregroundColor(Color.Gray500)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    Text(notice.noticeType)
                        .font(.SemiBold12)
                        .foregroundColor(Color.Gray400)
                    
                    Divider()
                        .background(Color.Gray300)
                    
                    Text(notice.noticeKeyword)
                        .font(.SemiBold12)
                        .foregroundColor(Color.Gray400)
                }
                .padding(.top, 0)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color.Gray400)
                .frame(width: 24, height: 24)
        }
        .padding(20)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.Gray300, lineWidth: 1)
        )
    }
}


#Preview {
    NotificationView()
}
