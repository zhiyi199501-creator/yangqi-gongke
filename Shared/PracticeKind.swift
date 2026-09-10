import Foundation

enum PracticeKind: String, Codable, CaseIterable, Identifiable {
    case sleep
    case zuo
    case zhan
    case emotion
    case classic
    case diet
    case move

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sleep: return "作息"
        case .zuo: return "打坐"
        case .zhan: return "站桩"
        case .emotion: return "宽两秒"
        case .classic: return "读经典"
        case .diet: return "饮食"
        case .move: return "运动"
        }
    }

    var maxScore: Double {
        switch self {
        case .sleep: return 24
        case .zuo: return 20
        case .zhan: return 12
        case .emotion: return 16
        case .classic: return 12
        case .diet: return 10
        case .move: return 6
        }
    }

    var sealCharacter: String {
        switch self {
        case .sleep: return "寐"
        case .zuo: return "坐"
        case .zhan: return "桩"
        case .emotion: return "宽"
        case .classic: return "经"
        case .diet: return "食"
        case .move: return "动"
        }
    }
}
