import Foundation

enum MealFullness: String, Codable, CaseIterable, Identifiable {
    case unset
    case seven
    case eight
    case ninePlus

    var id: String { rawValue }

    var points: Double {
        switch self {
        case .unset: return 0
        case .seven: return 2
        case .eight: return 1
        case .ninePlus: return 0
        }
    }

    var label: String {
        switch self {
        case .unset: return "未记"
        case .seven: return "七分饱"
        case .eight: return "八分饱"
        case .ninePlus: return "九分饱"
        }
    }
}
