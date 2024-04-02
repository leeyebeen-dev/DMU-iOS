//
//  HomeView.swift
//  DMU-iOS
//
//  Created by 이예빈 on 12/29/23.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject var viewModel: NoticeViewModel
    @ObservedObject var userSettings: UserSettings
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HomeTopBarView()
                    
                    NoticeTabBarView(viewModel: viewModel)
                    
                    NoticeTabSwipeView(userSettings: userSettings, viewModel: viewModel)
                }
                
                VStack{
                    if viewModel.isUniversityNoticeLoadingFailed || viewModel.isDepartmentNoticeLoadingFailed {
                        VStack(alignment: .center) {
                            Text("공지를 불러오지 못했어요")
                                .font(.SemiBold20)
                                .foregroundColor(Color.Gray600)
                                .padding(.bottom, 12)
                                .environment(\.sizeCategory, .large)
                            Text("네트워크 상태를 확인한 후,\n새로고침 버튼을 눌러 페이지를 불러올 수 있어요.")
                                .font(.Medium16)
                                .foregroundColor(Color.Gray400)
                                .padding(.bottom, 28)
                                .environment(\.sizeCategory, .large)
                            CustomButton(title: "새로고침", action: {
                                viewModel.resetAndLoadFirstPageOfUniversityNotices()
                                viewModel.resetAndLoadFirstPageOfDepartmentNotices(department: userSettings.selectedDepartment)
                            }, isEnabled: true)
                        }
                        .multilineTextAlignment(.center)
                    } else if viewModel.isDepartmentNoticeLoading || viewModel.isUniversityNoticeLoading {
                        LoadingView(lottieFileName: "DMforU_Loading_GIF")
                            .frame(width: 100, height: 100)
                    }
                }
            }
            .onAppear {
                viewModel.resetAndLoadFirstPageOfUniversityNotices()
                viewModel.resetAndLoadFirstPageOfDepartmentNotices(department: userSettings.selectedDepartment)
            }
        }
    }
}

// MARK: - 공지사항 화면 상단바(로고 및 알림 버튼)
struct HomeTopBarView: View {
        
    var body: some View {
        HStack {
            Image("logo")
                .resizable()
                .frame(width: 128, height: 33)
                .padding(.leading)
            Spacer()
        }
        .padding(.top, 15)
    }
}

// MARK: - 공지사항 화면 상단탭바(대학 공지, 학과 공지)
struct NoticeTabBarView: View {
    
    @ObservedObject var viewModel: NoticeViewModel
    
    var body: some View {
        HStack {
            NoticeTabBarItem(title: .university, viewModel: viewModel)
            NoticeTabBarItem(title: .department, viewModel: viewModel)
        }
        .padding(.top, 13)
        .frame(maxWidth: .infinity)
    }
}

struct NoticeTabBarItem: View {
    
    var title: NoticeTab
    
    @ObservedObject var viewModel: NoticeViewModel
    
    var body: some View {
        VStack {
            Text(title.rawValue)
                .font(.Bold16)
                .foregroundColor(viewModel.selectedTab == title ? Color.Blue300 : Color.Gray400)
                .onTapGesture {
                    viewModel.selectedTab = title
                }
            Rectangle()
                .frame(height: 2)
                .foregroundColor(viewModel.selectedTab == title ? Color.Blue300 : Color.clear)
        }
    }
}

struct NoticeTabSwipeView: View {
    
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var viewModel: NoticeViewModel
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            HomeUniversityNoticeListView(universityNotices: viewModel.universityNotices, viewModel: viewModel)
                .tag(NoticeTab.university)
            HomeDepartmentNoticeListView(userSettings: userSettings, departmentNotices: viewModel.departmentNotices, viewModel: viewModel)
                .tag(NoticeTab.department)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

// MARK: - 대학, 학과 공지사항 리스트뷰
struct HomeUniversityNoticeListView: View {
    
    let universityNotices: [UniversityNotice]
    let viewModel: NoticeViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(universityNotices) { notice in
                    NavigationLink(destination: NoticeWebViewDetail(urlString: notice.noticeURL)){
                        NoticeSingleView(notices: notice)
                    }
                    .onAppear {
                        if self.universityNotices.isLastItem(notice) {
                            self.viewModel.loadNextPageOfUniversityNoticesIfNotLoading()
                        }
                    }
                    Divider().background(Color.Gray200)
                }
            }
        }
        .background(Color.clear)
        .refreshable {
            viewModel.resetAndLoadFirstPageOfUniversityNotices()
        }
    }
}

struct HomeDepartmentNoticeListView: View {
    
    @ObservedObject var userSettings: UserSettings
    
    let departmentNotices: [DepartmentNotice]
    var viewModel: NoticeViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(departmentNotices) { notice in
                    NavigationLink(destination: NoticeWebViewDetail(urlString: notice.noticeURL)){
                        NoticeSingleView(notices: notice)
                    }
                    .onAppear {
                        if self.departmentNotices.isLastItem(notice) {
                            self.viewModel.loadNextPageIfNotLoading(department: userSettings.selectedDepartment)
                        }
                    }
                    Divider().background(Color.Gray200)
                }
            }
        }
        .background(Color.clear)
        .refreshable {
            viewModel.resetAndLoadFirstPageOfDepartmentNotices(department: userSettings.selectedDepartment)
        }
    }
}


struct NoticeSingleView: View {
    let notices: any NoticeProtocol

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(notices.noticeTitle)
                    .font(.Medium16)
                    .multilineTextAlignment(.leading) // 여러 줄 정렬
                    .foregroundColor(Color.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack {
                Text(notices.noticeDate.formattedString)
                    .font(.Regular12)
                    .foregroundColor(Color.Gray400)
                
                Text(notices.noticeStaffName)
                    .font(.Regular12)
                    .foregroundColor(Color.Gray400)
                    .padding(.leading, 12)
            }
            .padding(.top, 1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .cornerRadius(0)
        .shadow(color: Color.gray200, radius: 0, x: 0, y: 0)
    }
}

extension Array where Element: Identifiable {
    func isLastItem(_ item: Element) -> Bool {
        guard let lastItem = self.last else {
            return false
        }
        
        return lastItem.id == item.id
    }
}


#Preview {
    HomeView(viewModel: NoticeViewModel(), userSettings: UserSettings())
}
