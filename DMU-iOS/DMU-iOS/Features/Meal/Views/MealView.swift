//
//  MealView.swift
//  DMU-iOS
//
//  Created by 이예빈 on 12/31/23.
//

import SwiftUI

struct MealView: View {
    
    @StateObject var viewModel: MealViewModel
    
    @State private var selectedDate = Date()
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                MealTitleView()
                
                WeeklyCalendarView(selectedDate: $selectedDate, startDate: viewModel.startOfWeek(date: Date()))
                
                RestaurantInfomationView()
                
                WeeklyMenuView(viewModel: viewModel, selectedDate: selectedDate)
                
                Spacer()
            }
            VStack {
                if viewModel.isMenuLoadingFailed {
                    VStack(alignment: .center) {
                        Text("식단을 불러오지 못했어요")
                            .font(.SemiBold20)
                            .foregroundColor(Color.Gray600)
                            .padding(.bottom, 12)
                            .environment(\.sizeCategory, .large)
                        Text("네트워크 상태를 확인한 후,\n새로고침 버튼을 눌러 페이지를 불러올 수 있어요.")
                            .font(.Medium16)
                            .foregroundColor(Color.Gray400)
                            .padding(.bottom, 28)
                            .environment(\.sizeCategory, .large)
                        CustomButton(title: "새로고침", action: {
                            viewModel.loadMenuData()
                        }, isEnabled: true)
                    }
                    .multilineTextAlignment(.center)
                } else if viewModel.isMenuLoading {
                    LoadingView(lottieFileName: "DMforU_Loading_GIF")
                        .frame(width: 100, height: 100)
                }
            }
        }
        .onAppear(perform: viewModel.loadMenuData)
    }
}

// MARK: - 금주의 식단 타이틀 뷰
struct MealTitleView: View {
    var body: some View {
        Text("금주의 식단")
            .font(.SemiBold20)
            .foregroundColor(Color.Gray500)
            .environment(\.sizeCategory, .large)
            .padding()
    }
}

// MARK: - 금주의 캘린더 뷰
struct WeeklyCalendarView: View {
    
    @Binding var selectedDate: Date
    
    var startDate: Date
    
    var body: some View {
        HStack {
            ForEach(0..<5) { offset in
                let date = Calendar.current.date(byAdding: .day, value: offset, to: startDate)!
                WeeklyCalendarSingleDateView(selectedDate: $selectedDate, date: date)
            }
        }
    }
}

struct WeeklyCalendarSingleDateView: View {
    
    @Binding var selectedDate: Date
    
    var date: Date
    
    var body: some View {
        
        let calendar: Calendar = {
            var cal = Calendar.current
            cal.locale = Locale(identifier: "ko_KR")
            return cal
        }()
        
        let weekday = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
        
        VStack(alignment: .center) {
            Text("\(Calendar.current.component(.month, from: date))월")
                .font(.Medium12)
                .foregroundColor(Color.Gray500)
                .frame(width: 30)
                .padding(.bottom, 10)
                .lineLimit(1)
                .environment(\.sizeCategory, .large)
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.Medium16)
                .foregroundColor(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.white : Color.Gray500)
                .frame(width: 30, height: 30, alignment: .center)
                .background(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.Blue300 : Color.clear)
                .cornerRadius(10)
                .lineLimit(1)
                .environment(\.sizeCategory, .large)
            Text(weekday)
                .font(.Medium12)
                .padding(.top, 10)
                .foregroundColor(Color.Gray500)
                .frame(width: 30)
                .lineLimit(1)
                .environment(\.sizeCategory, .large)
        }
        .padding(.horizontal, 18)
        .onTapGesture {
            self.selectedDate = self.date
        }
    }
}

// MARK: - 식당 정보 뷰
struct RestaurantInfomationView: View {
    
    var body: some View {
        HStack(alignment: .center) {
            InfomationSingleView(imageName: "map", text: "8호관 3층")
                .padding(.trailing, 20)
            InfomationSingleView(imageName: "clock", text: "11:30 - 14:00, 16:30 - 18:00")
        }
        .padding(.top, 20)
    }
}

struct InfomationSingleView: View {
    
    var imageName: String
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(Color.Gray400)
            Text(text)
                .font(.Medium14)
                .foregroundColor(Color.Gray400)
                .environment(\.sizeCategory, .large)
        }
    }
}

// MARK: - 금주의 식단(한식, 일품) 메뉴 뷰
struct WeeklyMenuView: View {
    
    @ObservedObject var viewModel: MealViewModel
    
    var selectedDate: Date
    
    var body: some View {

        
        if viewModel.isWeekend(selectedDate){
            VStack {
                Text("⛔️ 주말은 식당을 운영하지 않아요.")
                    .font(.Medium16)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.Blue100)
                    .foregroundColor(Color.Gray600)
                    .cornerRadius(20)
            }
            .padding(.top, 20)
        }
        else if viewModel.getMenuForDate(for: selectedDate) != nil {
            WeeklyMenuDetailView(viewModel: viewModel, selectedDate: selectedDate)
        }
    }
}

struct WeeklyMenuDetailView: View {
    
    @ObservedObject var viewModel: MealViewModel
    
    var selectedDate: Date
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    if let menu = viewModel.getMenuForDate(for: selectedDate) {
                        MenuDetailSingleView(category: "🍚 한식", details: menu.details, width: geometry.size.width)
                    }
                    Spacer(minLength: 20)
                    MenuDetailSingleView(category: "🍛 일품", details: [], width: geometry.size.width)
                }
                .padding(.top, 30)
                .padding(.horizontal, 20)
            }
        }
    }
}

struct MenuDetailSingleView: View {
    
    var category: String
    var details: [String]
    var width: CGFloat
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(category)
                .font(.Bold20)
                .foregroundColor(Color.Gray500)
            
            LazyVGrid(columns: [GridItem(.flexible(), alignment: .center)]) {
                ForEach(details.isEmpty ? ["😂 등록된 메뉴가 없어요."] : details, id: \.self) { detail in
                    Text(detail)
                        .font(.Medium16)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.Blue100)
                        .foregroundColor(Color.Gray600)
                        .cornerRadius(20)
                        .lineLimit(1)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .frame(width: width - 40)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.Blue300, lineWidth: 2)
        )
    }
}

#Preview {
    MealView(viewModel: MealViewModel())
}
