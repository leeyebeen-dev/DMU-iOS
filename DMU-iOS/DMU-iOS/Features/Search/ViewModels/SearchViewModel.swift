//
//  SearchViewModel.swift
//  DMU-iOS
//
//  Created by 이예빈 on 1/1/24.
//

import Foundation

class SearchViewModel: ObservableObject {
    
    @Published var searchText = "" {
        didSet {
            if searchText.isEmpty {
                searchedText = ""
            }
        }
    }
    @Published var searchedText = ""
    @Published var isEditing = false
    @Published var searchNotices: [SearchNotice] = []
    
    // MARK: 검색 필드 편집을 시작하는 메서드
    func startSearchEditing() {
        isEditing = true
    }
    
    // MARK: 검색 필드 편집을 종료하는 메서드
    func endSearchEditing() {
        isEditing = false
    }
    
    // MARK: 검색어 삭제 메서드
    func clearText() {
        self.searchText = ""
        self.shouldShowResults = false
    }
    
    // MARK: 검색 기능, 로딩, 페이지네이션 메서드
    @Published var isLoading = false
    @Published var shouldShowResults = false
    
    private let searchNoticeService = SearchNoticeService()
    private let userSettings = UserSettings()
    private var currentPage = 1
    private let itemsPerPage = 10
    
    func setupSearchAndLoadFirstPage() {
        if !searchText.isEmpty {
            self.searchedText = self.searchText
            self.currentPage = 1
            self.searchNotices = []
            loadNextPageOfSearchResults()
            shouldShowResults = true
        }
    }
    
    private func loadNextPageOfSearchResults() {
        self.isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                let department = self.userSettings.selectedDepartment
                
                self.searchNoticeService.getSearchNotices(searchWord: self.searchedText, department: department, page: self.currentPage, size: self.itemsPerPage) { result in
                    switch result {
                    case .success(let notices):
                        self.searchNotices.append(contentsOf: notices)
                    case .failure(let error):
                        print(error)
                    }
                    
                    self.isLoading = false
                }
            }
        }
    }
    
    func loadNextPageIfNotLoading() {
        if !isLoading {
            currentPage += 1
            loadNextPageOfSearchResults()
        }
    }
}
