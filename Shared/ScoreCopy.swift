import Foundation

enum ScoreCopy {
    static func phrase(for total: Int) -> String {
        switch total {
        case ..<10: return "人还没醒"
        case ..<30: return "眼睛亮了"
        case ..<50: return "气色回来了"
        case ..<70: return "走路有风"
        case ..<90: return "神清气爽"
        default: return "满面春风"
        }
    }

    static func todayLine(for total: Int) -> String {
        if total == 0 { return phrase(for: 0) }
        return "今日 \(total) · \(phrase(for: total))"
    }
}
