import Foundation
import SwiftData

@MainActor
final class PracticeController {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func day(for date: Date = .now) -> DayPractice {
        let start = DayCalendar.startOfDay(for: date)
        var descriptor = FetchDescriptor<DayPractice>(
            predicate: #Predicate { $0.dayStart == start }
        )
        descriptor.fetchLimit = 1
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let created = DayPractice(dayStart: start)
        context.insert(created)
        save(created)
        return created
    }

    func daysInMonth(_ month: Date) -> [DayPractice] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let start = interval.start
        let end = interval.end
        let descriptor = FetchDescriptor<DayPractice>(
            predicate: #Predicate { $0.dayStart >= start && $0.dayStart < end },
            sortBy: [SortDescriptor(\.dayStart)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func save(_ day: DayPractice) {
        try? context.save()
        WidgetSnapshotStore.save(day.record)
    }
}
