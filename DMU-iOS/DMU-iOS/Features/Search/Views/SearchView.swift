//
//  SearchView.swift
//  DMU-iOS
//
//  Created by 이예빈 on 12/31/23.
//

import SwiftUI

struct SearchView: View {
    
    @StateObject var viewModel: SearchViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    SearchBarView(viewModel: viewModel)
                    
                    if viewModel.shouldShowResults {
                        if viewModel.searchNotices.isEmpty {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color.Gray400)
                                .font(.system(size: 30))
                                .padding(.top, 20)
                                .padding(.bottom, 8)
                            
                            Text("검색 결과를 찾을 수 없어요")
                                .font(.SemiBold20)
                                .foregroundColor(Color.Gray500)
                                .padding(.bottom, 8)
                                .environment(\.sizeCategory, .large)
                            
                            Text("다른 키워드로 검색해보세요.")
                                .font(.Medium16)
                                .foregroundColor(Color.Gray400)
                                .environment(\.sizeCategory, .large)
                        } else {
                            ScrollView {
                                SearchResultsListView(viewModel: viewModel)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .gesture(
                    TapGesture()
                        .onEnded { _ in
                            self.hideKeyboard()
                        }
                )
                
                VStack {
                    if viewModel.isLoading {
                        LoadingView(lottieFileName: "DMforU_Loading_GIF")
                            .frame(width: 100, height: 100)
                    }
                }
            }
            
        }
    }
}

// MARK: - 검색 화면 검색바 뷰
struct SearchBarView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    @State private var textfieldBackgroundColor = Color.Blue100
    @State private var textfieldForegroundColor = Color.Blue300
    @State private var imageForegroundColor = Color.Blue300
    
    var body: some View {
        HStack {
            TextField("검색어를 2글자 이상 입력하세요.", text: $viewModel.searchText, onCommit: {
                if viewModel.searchText.count >= 2 {
                    viewModel.setupSearchAndLoadFirstPage()
                    withAnimation {
                        viewModel.isEditing = false
                        hideKeyboard()
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        textfieldBackgroundColor = Color.Red100
                        textfieldForegroundColor = Color.Red400
                        imageForegroundColor = Color.Red400
                    }
                    // 0.5초 후 원래 색상으로 복귀
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            textfieldBackgroundColor = Color.Blue100
                            textfieldForegroundColor = Color.Blue300
                            imageForegroundColor = Color.Blue300
                        }
                    }
                }
            })
            .padding(EdgeInsets(top: 12, leading: 40, bottom: 12, trailing: 12))
            .background(textfieldBackgroundColor)
            .foregroundColor(textfieldForegroundColor)
            .font(.Medium16)
            .cornerRadius(8)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(imageForegroundColor)
                        .padding(.leading, 12)

                    Spacer()

                    if viewModel.isEditing && !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.clearText()
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(Color.Gray400)
                        }
                        .padding(.trailing, 12)
                    }
                }
            )
            .padding(.horizontal, 20)
            .onTapGesture {
                withAnimation {
                    viewModel.isEditing = true
                }
            }
            
            if viewModel.isEditing {
                Button(action: {
                    viewModel.clearText()
                    withAnimation {
                        viewModel.isEditing = false
                    }
                    hideKeyboard()
                }) {
                    Text("취소")
                        .font(.Medium16)
                        .foregroundColor(Color.Blue300)
                        .transition(.move(edge: .trailing))
                }
                .padding(.trailing, 20)
                .padding(.leading, -10)
            }
        }
        .padding(.top, 15)
    }
}

// MARK: - 검색 결과 리스트 뷰
struct SearchResultsListView: View {
    
    @ObservedObject var viewModel: SearchViewModel
        
    var body: some View {
        VStack {
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.searchNotices, id: \.id) { notice in
                    NavigationLink(destination: NoticeWebViewDetail(urlString: notice.noticeURL)){
                        SearchResultSingleView(notice: notice)
                    }
                    .onAppear {
                        if viewModel.searchNotices.isLastItem(notice) {
                            viewModel.loadNextPageIfNotLoading()
                        }
                    }
                    
                    Divider().background(Color.Gray200)
                }
            }
        }
    }
}

struct SearchResultSingleView: View {
    
    var notice: SearchNotice
    
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
                Text(notice.noticeDate.formattedString)
                    .font(.Regular12)
                    .foregroundColor(Color.Gray400)
                
                Text(notice.noticeStaffName)
                    .font(.Regular12)
                    .foregroundColor(Color.Gray400)
            }
            .padding(.top, 1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(0)
        .shadow(color: .gray, radius: 0, x: 0, y: 0)
    }
}

extension Array where Element == SearchNotice {
    func isLastItem(_ item: SearchNotice) -> Bool {
        guard let lastItem = self.last else {
            return false
        }
        return lastItem.id == item.id
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
