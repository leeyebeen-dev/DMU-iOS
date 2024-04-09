//
//  CustomKeyword.swift
//  DMU-iOS
//
//  Created by 이예빈 on 12/27/23.
//

import SwiftUI

enum Keyword: String, CaseIterable {
    case 시험 = "exam"
    case 수강 = "signup"
    case 특강 = "speciallecture"
    case 계절학기 = "seasonalsemester"
    case 휴학 = "leaveofabsence"
    case 복학 = "returntoschool"
    case 졸업 = "graduate"
    case 전과 = "switchmajors"
    case 학기포기 = "givingupthesemester"
    case 장학 = "scholarship"
    case 국가장학 = "nationalscholarship"
    case 등록 = "registration"
    case 채용 = "employment"
    case 공모전 = "contest"
    case 대회 = "competition"
    case 현장실습 = "fieldtraining"
    case 봉사 = "volunteer"
    case 기숙사 = "dormitory"
    case 동아리 = "group"
    case 학생회 = "studentcouncil"
    
    var displayName: String {
        switch self {
        case .시험: return "시험"
        case .수강: return "수강"
        case .특강: return "특강"
        case .계절학기: return "계절학기"
        case .휴학: return "휴학"
        case .복학: return "복학"
        case .졸업: return "졸업"
        case .전과: return "전과"
        case .학기포기: return "학기포기"
        case .장학: return "장학"
        case .국가장학: return "국가장학"
        case .등록: return "등록"
        case .채용: return "채용"
        case .공모전: return "공모전"
        case .대회: return "대회"
        case .현장실습: return "현장실습"
        case .봉사: return "봉사"
        case .기숙사: return "기숙사"
        case .동아리: return "동아리"
        case .학생회: return "학생회"
        }
    }

    
    var storageKey: String {
        self.rawValue
    }
}


struct CustomKeyword: View {
    
    let titles = ["수업", "학적", "장학금", "취업", "기타"]
    let contents: [[Keyword]] = [
        [.시험, .수강, .특강, .계절학기],
        [.휴학, .복학, .졸업, .전과, .학기포기],
        [.장학, .국가장학, .등록],
        [.채용, .공모전, .대회, .현장실습, .봉사],
        [.기숙사, .동아리, .학생회]
    ]
    
    @Binding var selectedKeywords: [String]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(Array(titles.enumerated()), id: \.element) { index, title in
                    KeywordSection(title: title, items: contents[index].map { $0.displayName }, selectedKeywords: $selectedKeywords)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct KeywordSection: View {
    var title: String
    var items: [String]
    @Binding var selectedKeywords: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.Medium20)
                .foregroundColor(Color.Gray600)
                .environment(\.sizeCategory, .large)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 0, alignment: .leading)], spacing: 16) {
                ForEach(items, id: \.self) { item in
                    SelectableButton(content: item, isSelected: selectedKeywords.contains(where: { Keyword(rawValue: $0)?.displayName == item }), action: {
                        if let keyword = Keyword.allCases.first(where: { $0.displayName == item }) {
                            let rawValue = keyword.rawValue
                            if selectedKeywords.contains(rawValue) {
                                selectedKeywords.removeAll { $0 == rawValue }
                            } else {
                                selectedKeywords.append(rawValue)
                            }
                        }
                    })
                }
            }
            
            Divider().padding(.top, 10)
        }
    }
}

struct SelectableButton: View {
    let content: String
    var isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text(content)
                .font(.SemiBold16)
                .foregroundColor(isSelected ? Color.white : Color.Gray400)
                .environment(\.sizeCategory, .large)
                .frame(minWidth: 70, alignment: .center)
                .padding(.vertical, 5).padding(.horizontal, 16)
                .background(isSelected ? Color.Blue300 : Color.clear)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.Blue300 : Color.Gray400, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomKeyword_Previews: PreviewProvider {
    @State static var selectedKeywords: [String] = ["시험", "복학"]

    static var previews: some View {
        CustomKeyword(selectedKeywords: $selectedKeywords)
    }
}
