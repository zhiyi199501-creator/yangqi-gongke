import Foundation
import WidgetKit

enum WidgetSnapshotStore {
    private static let key = "todaySnapshot"

    static func save(_ record: DayRecord) {
        let breakdown = record.breakdown
        let snapshot = WidgetSnapshot(
            dayStart: record.dayStart,
            total: breakdown.displayTotal,
            scores: Dictionary(
                uniqueKeysWithValues: PracticeKind.allCases.map { ($0.rawValue, breakdown.points(for: $0)) }
            )
        )
        guard let defaults = UserDefaults(suiteName: AppConstants.appGroupID),
              let data = try? JSONEncoder().encode(snapshot)
        else { return }
        defaults.set(data, forKey: key)
        WidgetCenter.shared.reloadTimelines(ofKind: AppConstants.widgetKind)
    }

    static func load() -> WidgetSnapshot? {
        guard let defaults = UserDefaults(suiteName: AppConstants.appGroupID),
              let data = defaults.data(forKey: key)
        else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }
}

struct WidgetSnapshot: Codable {
    var dayStart: Date
    var total: Int
    var scores: [String: Double]
}

enum DayCalendar {
    static func startOfDay(for date: Date = .now, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: date)
    }
}

/// Attach clock times to a practice day: last night's sleep, this morning's wake.
enum RestClock {
    static func defaultSleep(for dayStart: Date, calendar: Calendar = .current) -> Date {
        let previous = calendar.date(byAdding: .day, value: -1, to: dayStart) ?? dayStart
        return calendar.date(bySettingHour: 21, minute: 30, second: 0, of: previous) ?? previous
    }

    static func defaultWake(for dayStart: Date, calendar: Calendar = .current) -> Date {
        calendar.date(bySettingHour: 5, minute: 30, second: 0, of: dayStart) ?? dayStart
    }

    /// 12:00–23:59 is the previous evening; 00:00–11:59 is this morning (past midnight).
    static func normalizedSleep(dayStart: Date, picked: Date, calendar: Calendar = .current) -> Date {
        let hour = calendar.component(.hour, from: picked)
        let minute = calendar.component(.minute, from: picked)
        let base: Date
        if hour >= 12 {
            base = calendar.date(byAdding: .day, value: -1, to: dayStart) ?? dayStart
        } else {
            base = dayStart
        }
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? picked
    }

    static func normalizedWake(dayStart: Date, picked: Date, calendar: Calendar = .current) -> Date {
        let hour = calendar.component(.hour, from: picked)
        let minute = calendar.component(.minute, from: picked)
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: dayStart) ?? picked
    }
}
