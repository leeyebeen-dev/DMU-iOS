//
//  ScheduleView.swift
//  DMU-iOS
//
//  Created by 이예빈 on 12/31/23.
//

import SwiftUI

struct ScheduleView: View {
    
    @StateObject var viewModel: ScheduleViewModel
    
    @State private var isDatePickerPresented = false
    
    var body: some View {
        ZStack{
            VStack {
                ScheduleTitleView()
                
                ScheduleMonthNavigationBarView(currentYearMonth: viewModel.currentYearMonth, isDatePickerPresented: $isDatePickerPresented)
                
                SchedulesListView(schedules: viewModel.schedules, loadScheduleData: viewModel.loadScheduleData)
            }
            
            VStack {
                if viewModel.isScheduleLoadingFailed {
                    ScheduleLoadingFailedView(loadScheduleData: viewModel.loadScheduleData)
                } else if viewModel.isScheduleLoading {
                    LoadingView(lottieFileName: "DMforU_Loading_GIF")
                        .frame(width: 100, height: 100)
                }
            }
        }
        .onAppear(perform: viewModel.loadScheduleData)
        .sheet(isPresented: $isDatePickerPresented) {
            ScheduleDatePickerView(viewModel: viewModel, isPresented: $isDatePickerPresented)
                .presentationDetents([
                    .fraction(0.48)
                ])
                .presentationDragIndicator(.hidden)
        }
    }
}

struct ScheduleTitleView: View {
    var body: some View {
        Text("학사일정")
            .font(.SemiBold20)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.Gray500)
            .environment(\.sizeCategory, .large)
            .padding()
    }
}

struct ScheduleMonthNavigationBarView: View {
    let currentYearMonth: String
    
    @Binding var isDatePickerPresented: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Text(currentYearMonth)
                .font(.Medium16)
                .foregroundColor(Color.Gray500)
                .environment(\.sizeCategory, .large)
                .lineLimit(1)
            
            Image(isDatePickerPresented ? "polygon-up" : "polygon-down")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 14)
        }
        .padding(.horizontal, 24)
        .onTapGesture {
            isDatePickerPresented.toggle()
        }
    }
}

struct SchedulesListView: View {
    let schedules: [Schedule]
    let loadScheduleData: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(schedules) { schedule in
                    ScheduleSingleView(for: schedule)
                }
            }
        }
        .refreshable {
            loadScheduleData()
        }
    }
}

struct ScheduleSingleView: View {
    let schedule: Schedule
    
    init(for schedule: Schedule) {
        self.schedule = schedule
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(schedule.scheduleDisplay)
                    .font(.SemiBold14)
                    .lineSpacing(4)
                    .foregroundColor(Color.Gray500)
                    .environment(\.sizeCategory, .large)
                
                Spacer()
                
                Text(schedule.detail)
                    .font(.SemiBold14)
                    .foregroundColor(Color.Gray500)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(nil)
                    .environment(\.sizeCategory, .large)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            Divider()
                .background(Color.gray200)
        }
        .background(Color.clear)
    }
}

struct ScheduleLoadingFailedView: View {
    let loadScheduleData: () -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            Text("학사일정을 불러오지 못했어요")
                .font(.SemiBold20)
                .foregroundColor(Color.Gray600)
                .environment(\.sizeCategory, .large)
                .padding(.bottom, 12)
            Text("네트워크 상태를 확인한 후,\n새로고침 버튼을 눌러 페이지를 불러올 수 있어요.")
                .font(.Medium16)
                .foregroundColor(Color.Gray400)
                .environment(\.sizeCategory, .large)
                .padding(.bottom, 28)
            CustomButton(title: "새로고침", action: {
                loadScheduleData()
            }, isEnabled: true)
        }
        .multilineTextAlignment(.center)
    }
}


#Preview {
    ScheduleView(viewModel: ScheduleViewModel())
}
