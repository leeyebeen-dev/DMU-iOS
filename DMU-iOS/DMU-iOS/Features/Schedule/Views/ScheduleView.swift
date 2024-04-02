//
//  ScheduleView.swift
//  DMU-iOS
//
//  Created by 이예빈 on 12/31/23.
//

import SwiftUI

struct ScheduleView: View {
    
    @StateObject var viewModel: ScheduleViewModel
    
    var body: some View {
        ZStack{
            VStack {
                ScheduleTitle
                
                ScheduleMonthNavigationBarView
                
                SchedulesListView
            }
            
            VStack {
                if viewModel.isScheduleLoadingFailed {
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
                            viewModel.loadScheduleData()
                        }, isEnabled: true)
                    }
                    .multilineTextAlignment(.center)
                } else if viewModel.isScheduleLoading {
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
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.Gray500)
            .environment(\.sizeCategory, .large)
            .padding()
    }
    
    // MARK: 학사일정 화면 네비게이션바 뷰
    private var ScheduleMonthNavigationBarView: some View {
        HStack {
            if viewModel.currentYearMonth != "2023년 1월" {
                monthChangeButton(direction: -1, systemName: "chevron.left")
            } else {
                Spacer()
            }
            
            Spacer().frame(minWidth: 100)
            
            Text(viewModel.currentYearMonth)
                .font(.Medium16)
                .foregroundColor(Color.Gray500)
                .environment(\.sizeCategory, .large)
                .lineLimit(1)
            
            Spacer().frame(minWidth: 100)
            
            if viewModel.currentYearMonth != "2025년 2월" {
                monthChangeButton(direction: 1, systemName: "chevron.right")
            } else {
                Spacer()
            }
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
                    .lineSpacing(4)
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
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            Divider()
                .background(Color.gray200)
        }
        .background(Color.clear)
    }
}

#Preview {
    ScheduleView(viewModel: ScheduleViewModel())
}
