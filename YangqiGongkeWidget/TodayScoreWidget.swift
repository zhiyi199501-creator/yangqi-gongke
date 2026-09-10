import SwiftUI
import WidgetKit

struct TodayScoreWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: AppConstants.widgetKind, provider: TodaySnapshotProvider()) { entry in
            TodayWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [
                            Color(red: 0.78, green: 0.96, blue: 0.88),
                            InkTheme.paper
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
        .configurationDisplayName("今日功课")
        .description("看今日得分与朝气")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TodayEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}

struct TodaySnapshotProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: .now, snapshot: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        let entry = currentEntry()
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date.now) ?? Date.now.addingTimeInterval(900)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func currentEntry() -> TodayEntry {
        var snapshot = WidgetSnapshotStore.load()
        if let loaded = snapshot, !Calendar.current.isDate(loaded.dayStart, inSameDayAs: Date.now) {
            snapshot = WidgetSnapshot(
                dayStart: DayCalendar.startOfDay(),
                total: 0,
                scores: [:]
            )
        }
        return TodayEntry(date: .now, snapshot: snapshot)
    }
}

struct TodayWidgetView: View {
    var entry: TodayEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        let total = entry.snapshot?.total ?? 0
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .bottom, spacing: 10) {
                SealStamp(character: "", intensity: Double(total) / 100, size: family == .systemSmall ? 28 : 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(total)")
                        .font(.system(size: family == .systemSmall ? 34 : 40, weight: .semibold, design: .rounded))
                        .foregroundStyle(InkTheme.ink)
                    Text(ScoreCopy.phrase(for: total))
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(total < 10 ? InkTheme.inkSoft : (total >= 90 ? InkTheme.lamp : InkTheme.seal))
                }
                Spacer()
            }
            if family == .systemMedium {
                HStack(spacing: 8) {
                    ForEach(PracticeKind.allCases) { kind in
                        let value = entry.snapshot?.scores[kind.rawValue] ?? 0
                        let intensity = kind.maxScore == 0 ? 0 : value / kind.maxScore
                        VStack(spacing: 4) {
                            Capsule()
                                .fill(InkTheme.seal.opacity(0.25 + 0.75 * intensity))
                                .frame(width: 6, height: 20)
                            Text(kind.title)
                                .font(.system(size: 8, weight: .medium, design: .rounded))
                                .foregroundStyle(InkTheme.inkSoft)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}
