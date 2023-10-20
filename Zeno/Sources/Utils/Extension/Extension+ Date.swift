//
//  Extension+ Date.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/05.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

extension String {
    func toDate() -> Date {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let validDate = dateFormater.date(from: self) else { return Date() }
        
        return validDate
    }
}

extension Date {
    /// 오늘 날짜를 기준으로 상대시간을 계산하여 문자열로 반환한다.
    /// - 예: 12시간 전, 10분 전
    /// - 사용법
    /// let writtenDate = "2023-03-05T15:08:43"
    /// let relativeTimeFromNow = writtenDate.toString().toRelativeString()
    func toRelativeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .short
        let dateToString = formatter.localizedString(for: self, relativeTo: .now)
        return dateToString
    }
}

// MARK: 이건 깃 스페이스 팀에서 썼었던건데 참고용입니다. 요기는 DateValue()를 써서 Date1970을 쓴 저희랑은 조
extension Date {
    private static var formatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    func timeAgoDisplay() -> String {
        Self.formatter.localizedString(for: self, relativeTo: Date())
    }
}
