//
//  SettingDepartmentView.swift
//  DMU-iOS
//
//  Created by 이예빈 on 1/5/24.
//

import SwiftUI

struct SettingDepartmentView: View {
    
    @ObservedObject var viewModel: SettingViewModel
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var tempSettingDepartment: String? = nil
    
    var body: some View {
        departmentListView()
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("학과 설정", displayMode: .inline)
            .navigationBarItems(leading: SettingDepartmentBackButton, trailing: SettingDepartmentSaveButton)
            .onAppear {
                self.tempSettingDepartment = viewModel.settingDepartment
            }
    }
    
    //MARK: 학과 설정 화면 뒤로가기 버튼
    @ViewBuilder
    var SettingDepartmentBackButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.backward")
                .foregroundColor(Color.Gray500)
        }
    }
    
    //MARK: 학과 설정 화면 학과 저장 버튼
    @ViewBuilder
    var SettingDepartmentSaveButton: some View {
        Button(action: {
            if let department = tempSettingDepartment {
                viewModel.saveDepartment(department: department)
            }
            viewModel.postUpdateDepartment()
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("완료")
                .font(.Medium16)
                .foregroundColor(tempSettingDepartment != nil ? Color.Blue300 : Color.Gray500)
        }
        .disabled(viewModel.settingDepartment == nil)
    }
    
    //MARK: 학과 설정 화면 학과 리스트 뷰
    @ViewBuilder
    func departmentListView() -> some View {
        ScrollView {
            LazyVStack {
                ForEach(Department.departmentlist, id: \.self) { department in
                    departmentSingleView(for: department)
                }
            }
            .padding(20)
            .background(Color.Gray100)
        }
    }
    
    @ViewBuilder
    func departmentSingleView(for department: String) -> some View {
        Text(department)
            .font(.Medium18)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, alignment: .center)
            .padding([.top, .bottom], 8)
            .background(tempSettingDepartment == department ? Color.Blue300 : Color.white)
            .foregroundColor(tempSettingDepartment == department ? Color.white : Color.Gray400)
            .onTapGesture {
                if tempSettingDepartment == department {
                                    tempSettingDepartment = nil
                } else {
                    tempSettingDepartment = department
                }
            }
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(viewModel.settingDepartment == department ? .clear : Color.Gray200, lineWidth: 1)
            )
    }
}

#Preview {
    SettingDepartmentView(viewModel: SettingViewModel(userSettings: UserSettings()))
}
