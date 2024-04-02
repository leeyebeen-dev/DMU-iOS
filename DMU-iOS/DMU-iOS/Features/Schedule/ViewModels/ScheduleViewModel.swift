//
//  ScheduleViewModel.swift
//  DMU-iOS
//
//  Created by 이예빈 on 1/3/24.
//

import Foundation

class ScheduleViewModel: ObservableObject {
        
    @Published var currentDate = Date()
    @Published var schedules: [Schedule] = []
    @Published var isScheduleLoading = false
    @Published var isScheduleLoadingFailed = false
    
    private let calendar = Calendar.current
    private let scheduleService = ScheduleService()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd(E)"
        return formatter
    }()
    
    // MARK: 학사일정 데이터 주입
    func loadScheduleData() {
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        
        self.isScheduleLoading = true
        self.isScheduleLoadingFailed = false
        
        scheduleService.getSchedules(year: year, month: month) { [weak self] result in
            switch result {
            case .success(let yearSchedule):
                DispatchQueue.main.async {
                    self?.schedules = yearSchedule.filter { $0.year == year && $0.month == month }
                    self?.isScheduleLoadingFailed = false
                }
            case .failure(let error):
                print("Failed to get schedules: \(error)")
                self?.isScheduleLoadingFailed = true
            }
            self?.isScheduleLoading = false
        }
    }
    
    // MARK: 학사일정 월 이동
    func changeMonth(by increment: Int) {
        guard let newDate = calendar.date(byAdding: .month, value: increment, to: currentDate) else { return }
        
        currentDate = newDate
        
        loadScheduleData()
    }
    
    // MARK: 현재 년월
    var currentYearMonth: String {
        formatDateToYearMonth(currentDate)
    }
    
    // MARK: - Helper Methods
    private func formatDateToYearMonth(_ date: Date) -> String {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        return "\(year)년 \(month)월"
    }
}
