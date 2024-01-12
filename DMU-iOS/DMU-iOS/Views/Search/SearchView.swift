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
                SearchBar(viewModel: viewModel)
                if !viewModel.recentSearches.isEmpty && viewModel.searchText.isEmpty {
                    RecentSearchesView(viewModel: viewModel)
                }
                SearchResults(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $viewModel.isNavigating) {
                SearchDetailView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - 검색바 기능 구현
struct SearchBar: View {
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
            .foregroundColor(Color.blue300)
            .background(Color.blue100)
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
                CancelButton(viewModel: viewModel)
            }
        }
    }
}

struct SearchBarOverlay: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.blue300)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 12)
                .padding(.trailing, 12)
            
            if viewModel.isEditing && !viewModel.searchText.isEmpty {
                ClearTextButton(viewModel: viewModel)
            }
        }
    }
}

struct CancelButton: View {
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
                .foregroundColor(Color.blue300)
                .transition(.move(edge: .trailing))
        }
    }
}

struct ClearTextButton: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        Button(action: {
            viewModel.clearText()
        }) {
            Image(systemName: "multiply.circle.fill")
                .foregroundColor(.gray400)
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
                SearchResultsList(viewModel: viewModel)
            }
        }
    }
}

struct SearchResultsList: View {
    @ObservedObject var viewModel: SearchViewModel
    @State private var navigateToDetail = false
    
    var body: some View {
        VStack {
            LazyVStack(alignment: .leading) {
                ForEach(sampleData.filter({ item in
                    viewModel.searchText.isEmpty ||
                    item.noticeTitle.lowercased().contains(viewModel.searchText.lowercased())
                }).prefix(3), id: \.id) { item in
                    SearchResultRow(item: item, viewModel: viewModel)
                }
            }
            
            if sampleData.filter({ item in
                item.noticeTitle.lowercased().contains(viewModel.searchText.lowercased())
            }).count > 3 {
                Button(action: {
                    viewModel.performSearch()
                    self.navigateToDetail = true
                    
                }) {
                    Text("결과 모두 보기")
                        .font(.Bold16)
                        .foregroundColor(Color.blue400)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .navigationDestination(isPresented: $navigateToDetail) {
                    SearchDetailView(viewModel: viewModel)
                }
                .background(.clear)
                .cornerRadius(8)
                .padding(.horizontal, 20)
            }
        }
    }
}

struct SearchResultRow: View {
    var item: Notice
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        NavigationLink(destination: HomeDetailView(detailNotice: item, homeDetailViewNavigationBarTitle: item.noticeType, viewModel: NoticeViewModel(userSettings: UserSettings()))) {
            VStack(alignment: .leading) {
                HStack{
                    Text(item.noticeTitle)
                        .font(.Medium16)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack {
                    Text("\(viewModel.formatDate(item.noticeDate))")
                        .font(.Regular12)
                        .foregroundColor(.gray400)
                    
                    Text(item.noticeStaffName)
                        .font(.Regular12)
                        .foregroundColor(.gray400)
                }
                .padding(.top, 1)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(0)
            .shadow(color: .gray, radius: 0, x: 0, y: 0)
        }
        Divider().background(Color.gray200)
    }
}

// MARK: - 최근 검색어 내역 리스트 뷰
struct RecentSearchesView: View {
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        if !viewModel.recentSearches.isEmpty {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("최근 검색어")
                        .font(.Bold18)
                        .foregroundColor(.blue300)
                        .padding()
                    ForEach(viewModel.recentSearches.reversed(), id: \.self) { search in
                        HStack {
                            Text(search)
                                .foregroundColor(.gray500)
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
                                    .foregroundColor(.gray500)
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
