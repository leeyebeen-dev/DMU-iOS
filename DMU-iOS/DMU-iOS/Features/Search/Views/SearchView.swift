//
//  SearchView.swift
//  DMU-iOS
//
//  Created by 이예빈 on 12/31/23.
//

import SwiftUI

struct SearchView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBarView(viewModel: viewModel)
                
                if !viewModel.recentSearches.isEmpty && viewModel.searchText.isEmpty {
                    RecentSearchesListView(viewModel: viewModel)
                }
                
                SearchResults(viewModel: viewModel)
            }
        }
    }
}

// MARK: - 검색 화면 검색바 뷰
struct SearchBarView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        HStack {
            TextField("검색어를 입력하세요.", text: $viewModel.searchText, onCommit: {
                viewModel.performSearch()
                withAnimation {
                    viewModel.isEditing = false
                    hideKeyboard()
                }
            })
            .padding(12)
            .padding(.horizontal, 28)
            .font(.Medium16)
            .foregroundColor(Color.Blue300)
            .background(Color.Blue100)
            .cornerRadius(8)
            .overlay(
                SearchBarOverlay(viewModel: viewModel)
            )
            .padding(.horizontal, 20)
            .onTapGesture {
                withAnimation {
                    viewModel.isEditing = true
                }
            }
            
            if viewModel.isEditing {
                SearchCancelButton(viewModel: viewModel)
            }
        }
    }
}

struct SearchBarOverlay: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.Blue300)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 12)
                .padding(.trailing, 12)
            
            if viewModel.isEditing && !viewModel.searchText.isEmpty {
                SearchClearTextButton(viewModel: viewModel)
            }
        }
    }
}

// MARK: - 검색창 텍스트 삭제 및 키워드 내리는 버튼
struct SearchCancelButton: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        Button(action: {
            viewModel.clearText()
            hideKeyboard()
            withAnimation {
                viewModel.isEditing = false
            }
        }) {
            Text("취소")
                .padding(.trailing, 20)
                .padding(.leading, -10)
                .font(.Medium16)
                .foregroundColor(Color.Blue300)
                .transition(.move(edge: .trailing))
        }
    }
}

// MARK: - 검색바 뷰 내부 텍스트 삭제 버튼
struct SearchClearTextButton: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        Button(action: {
            viewModel.clearText()
        }) {
            Image(systemName: "multiply.circle.fill")
                .foregroundColor(Color.Gray400)
                .padding(.trailing, 12)
        }
    }
}

// MARK: - 검색 결과 리스트 뷰
struct SearchResults: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        ScrollView {
            if !viewModel.searchText.isEmpty {
                SearchResultsListView(viewModel: viewModel)
            }
        }
    }
}

struct SearchResultsListView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    @State private var navigateToSearchDetail = false
    
    var body: some View {
        VStack {
            let universityNotices = viewModel.universityNotices.filter { notice in
                viewModel.searchText.isEmpty ||
                notice.noticeTitle.lowercased().contains(viewModel.searchText.lowercased())
            }

            let departmentNotices = viewModel.departmentNotices.filter { notice in
                viewModel.searchText.isEmpty ||
                notice.noticeTitle.lowercased().contains(viewModel.searchText.lowercased())
            }

            LazyVStack(alignment: .leading) {
                ForEach(universityNotices, id: \.id) { notice in
                    SearchResultSingleView(universityNotice: notice, viewModel: viewModel)
                }

                ForEach(departmentNotices, id: \.id) { notice in
                    SearchResultSingleView(departmentNotice: notice, viewModel: viewModel)
                }
            }

            
            if sampleData.filter({ item in
                item.noticeTitle.lowercased().contains(viewModel.searchText.lowercased())
            }).count > 3 {
                Button(action: {
                    viewModel.performSearch()
                    self.navigateToSearchDetail = true
                    
                }) {
                    Text("결과 모두 보기")
                        .font(.Bold16)
                        .foregroundColor(Color.Blue400)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(.clear)
                .cornerRadius(8)
                .padding(.horizontal, 20)
            }
        }
    }
}

struct SearchResultSingleView: View {
    
    var universityNotice: UniversityNotice?
    var departmentNotice: DepartmentNotice?
    
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text(notice.noticeTitle)
                    .font(.Medium16)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Text("\(viewModel.formatDate(notice.noticeDate))")
                    .font(.Regular12)
                    .foregroundColor(Color.Gray400)
                
                Text(notice.noticeStaffName)
                    .font(.Regular12)
                    .foregroundColor(Color.Gray400)
            }
            .padding(.top, 1)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(0)
        .shadow(color: .gray, radius: 0, x: 0, y: 0)
        
        Divider().background(Color.Gray200)
    }
    
    private var notice: any NoticeProtocol {
        if let universityNotice = universityNotice {
            return universityNotice
        } else if let departmentNotice = departmentNotice {
            return departmentNotice
        } else {
            fatalError("Fatal Error.")
        }
    }

}

// MARK: - 최근 검색어 내역 리스트 뷰
struct RecentSearchesListView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        if !viewModel.recentSearches.isEmpty {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("최근 검색어")
                        .font(.Bold18)
                        .foregroundColor(Color.Blue300)
                        .padding()
                    
                    ForEach(viewModel.recentSearches.reversed(), id: \.self) { search in
                        HStack {
                            Text(search)
                                .foregroundColor(Color.Gray500)
                                .onTapGesture {
                                    viewModel.searchText = search
                                    viewModel.isEditing = true
                                    viewModel.performSearch()
                                }
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.removeRecentSearch(search)
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(Color.Gray500)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, -10)
                        .padding(.bottom, 12)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}

// MARK: - 키보드 숨기기
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SearchView(viewModel: SearchViewModel())
}
