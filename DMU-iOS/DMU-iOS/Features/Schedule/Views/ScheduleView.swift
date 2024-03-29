//
//  ScheduleView.swift
//  DMU-iOS
//
//  Created by 이예빈 on 12/31/23.
//

import SwiftUI

struct ScheduleView: View {
    
    @ObservedObject var viewModel: ScheduleViewModel
    
    var body: some View {
        ZStack{
            VStack {
                ScheduleTitle
                
                ScheduleMonthNavigationBarView
                
                SchedulesListView
            }
            
            VStack {
                if viewModel.isScheduleLoading {
                    LoadingView(lottieFileName: "DMforU_Loading_GIF")
                        .frame(width: 100, height: 100)
                }
            }
        }
        .onAppear(perform: viewModel.loadScheduleData)
    }
    
    // MARK: 학사일정 화면 타이틀 뷰
    private var ScheduleTitle: some View {
        Text("학사일정")
            .font(.SemiBold20)
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.Gray500)
    }
    
    // MARK: 학사일정 화면 네비게이션바 뷰
    private var ScheduleMonthNavigationBarView: some View {
        HStack {
            monthChangeButton(direction: -1, systemName: "chevron.left")
            
            Spacer().frame(minWidth: 100)
            
            Text(viewModel.currentYearMonth)
                .font(.Medium16)
                .foregroundColor(Color.Gray500)
            
            Spacer().frame(minWidth: 100)
            
            monthChangeButton(direction: 1, systemName: "chevron.right")
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: 학사일정 화면 월 이동 버튼
    private func monthChangeButton(direction: Int, systemName: String) -> some View {
        Button(action: {
            viewModel.changeMonth(by: direction)
        }) {
            Image(systemName: systemName)
                .resizable()
                .frame(width: 12, height: 20)
                .foregroundColor(Color.blue300)
        }
    }
    
    // MARK: 학사일정 화면 일정 리스트 뷰
    private var SchedulesListView: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(viewModel.schedules) { schedule in
                    ScheduleSingleView(for: schedule)
                }
            }
        }
        .refreshable {
            viewModel.loadScheduleData()
        }
    }
    
    private func ScheduleSingleView(for schedule: Schedule) -> some View {
        VStack {
            HStack {
                Text(schedule.scheduleDisplay)
                    .font(.SemiBold14)
                    .foregroundColor(Color.Gray500)
                    .environment(\.sizeCategory, .large)
                
                Spacer()
                
                Text(schedule.detail)
                    .font(.SemiBold14)
                    .foregroundColor(Color.Gray500)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .environment(\.sizeCategory, .large)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            Divider()
                .background(Color.gray200)
        }
        .background(Color.clear)
    }
}

#Preview {
    ScheduleView(viewModel: ScheduleViewModel())
}
