//
//  Onboarding-Step-One.swift
//  DMU-iOS
//
//  Created by 이예빈 on 12/27/23.
//

import SwiftUI

struct Onboarding_Step_One: View {
    
    @State private var searchText = ""
    @State private var isListVisible = true
    @State private var isTextInList = false
    @State private var isStepTwoViewActive = false
    
    @EnvironmentObject var userSettings: UserSettings
    
    @Binding var isFirstLanching: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                OnboardingStepOneTitleView()
                
                OnboardingStepOneProgressBarView()
                
                OnboardingStepOneSearchDepartmentView(searchText: $searchText, isListVisible: $isListVisible, isTextInList: $isTextInList)
                
                Spacer()
                
                CustomButton(title: "다음", action: {
                    if Department.departmentlist.contains(searchText) {
                        userSettings.selectedDepartment = searchText
                        self.isStepTwoViewActive = true
                    }
                }, isEnabled: Department.departmentlist.contains(searchText))
                .padding(.bottom, 20)
                .navigationDestination(isPresented: $isStepTwoViewActive) {
                    Onboarding_Step_Two(isFirstLanching: $isFirstLanching)
                }
            }
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        self.hideKeyboard()
                    }
            )
        }
    }
}

// MARK: - 온보딩 화면 1단계 타이틀 뷰
struct OnboardingStepOneTitleView: View {
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 0){
                    Text("소속학과")
                        .font(.Bold32)
                        .foregroundColor(Color.Blue300)
                        .environment(\.sizeCategory, .large)
                    
                    Text("를 선택하면,")
                        .font(.Bold32)
                        .foregroundColor(Color.Gray500)
                        .environment(\.sizeCategory, .large)
                }
                
                Text("해당 학과의 공지만 바로 알려줘요.")
                    .font(.Bold24)
                    .foregroundColor(Color.Gray500)
                    .environment(\.sizeCategory, .large)
            }
            .padding(.top, 60)
        }
        .padding(.leading, -20)
    }
}

// MARK: - 온보딩 화면 1단계 프로그레스바
struct OnboardingStepOneProgressBarView: View {
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                HStack {
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundColor(Color.Blue300)
                    
                    Spacer()
                    
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundColor(Color.Gray300)
                    
                    Spacer()
                    
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundColor(Color.Gray300)
                }
                .frame(width: geometry.size.width * 0.6, height: 2)
                .background(Color.Gray300)
                
                HStack {
                    Text("학과 선택")
                        .foregroundColor(Color.Blue300)
                        .font(.Bold16)
                        .environment(\.sizeCategory, .large)
                        .padding(.top, 10)
                    
                    Spacer()
                }
                .padding(.leading, geometry.size.width * 0.14)
            }
            .padding(.top, 40)
        }
        .frame(height: 82)
    }
}

// MARK: - 온보딩 화면 1단계 소속 학과 검색 뷰
struct OnboardingStepOneSearchDepartmentView: View {
    
    @Binding var searchText: String
    @Binding var isListVisible: Bool
    @Binding var isTextInList: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Department.departmentlist.firstIndex(of: searchText) != nil ? Color.Blue300 : Color.Gray300)
                    .frame(width: 30, height: 30)
                
                TextField("소속 학과를 검색해주세요.", text: $searchText)
                    .foregroundColor(isTextInList ? Color.Blue300 : Color.Gray300)
                    .environment(\.sizeCategory, .large)
                    .onChange(of: searchText, perform: { value in
                        self.isListVisible = !searchText.isEmpty && !(Department.departmentlist.contains(searchText))
                        self.isTextInList = Department.departmentlist.contains(searchText)
                    })
                if !searchText.isEmpty {
                    Button(action: {
                        self.searchText = ""
                    }) {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(Color.Gray300)
                            .frame(width: 30, height: 30)
                    }
                    .padding(.trailing, 16)
                }
            }
            .frame(height: 52)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Department.departmentlist.firstIndex(of: searchText) != nil ? Color.Blue300 : Color.Gray300, lineWidth: 2)
            )
            .padding(.horizontal, 20)
            
            if isListVisible {
                List {
                    ForEach(Department.departmentlist.filter({ "\($0)".contains(searchText) }), id: \.self) { department in
                        Text(department).onTapGesture {
                            self.searchText = department
                            self.isListVisible = false
                        }
                        .foregroundColor(.gray300)
                        .environment(\.sizeCategory, .large)
                        .listRowSeparator(.hidden)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
                .padding(.horizontal, 20)
                .padding(.leading, -20)
                .frame(maxHeight: 200)
            }
        }
        .padding(.top, 40)
    }
}

#Preview {
    Onboarding_Step_One(isFirstLanching: .constant(true))
        .environmentObject(UserSettings())
}
