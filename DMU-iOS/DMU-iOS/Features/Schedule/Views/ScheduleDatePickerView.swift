//
//  ScheduleDatePickerView.swift
//  DMU-iOS
//
//  Created by 이예빈 on 7/10/24.
//

import SwiftUI

struct ScheduleDatePickerView: View {
    
    @StateObject var viewModel: ScheduleViewModel
    @Binding var isPresented: Bool
    
    @State private var tempSelectedYear: Int = 0
    @State private var tempSelectedMonth: Int = 0
    
    var body: some View {
        VStack {
            HStack {
                Picker("년도", selection: $tempSelectedYear) {
                    Text("2024년").tag(2024)
                    Text("2025년").tag(2025)
                }
                .pickerStyle(WheelPickerStyle())
                
                Picker("월", selection: $tempSelectedMonth) {
                    ForEach(1..<13) { month in
                        Text("\(month)월").tag(month)
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
            
            CustomButton(title: "완료", action: {
                viewModel.selectedYear = tempSelectedYear
                viewModel.selectedMonth = tempSelectedMonth
                viewModel.selectYearMonth()
                isPresented = false
            }, isEnabled: true)
        }
        .onAppear {
            tempSelectedYear = viewModel.selectedYear
            tempSelectedMonth = viewModel.selectedMonth
        }
    }
}

#Preview {
    ScheduleDatePickerView(viewModel: ScheduleViewModel(), isPresented: .constant(true))
}
