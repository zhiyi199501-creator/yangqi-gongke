import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var month: Date = DayCalendar.startOfDay()
    @State private var selected: Date?

    private var controller: PracticeController {
        PracticeController(context: modelContext)
    }

    var body: some View {
        let map = Dictionary(uniqueKeysWithValues: controller.daysInMonth(month).map { ($0.dayStart, $0) })
        let stats = monthStats(map: map)
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                monthHeader
                statsRow(stats: stats)
                calendar(map: map)
                if let selected, let day = map[DayCalendar.startOfDay(for: selected)] {
                    DayDetailView(day: day)
                } else if selected != nil {
                    Text("这一日还没记")
                        .font(InkTheme.caption)
                        .foregroundStyle(InkTheme.inkSoft)
                        .padding(.top, 8)
                }
            }
            .padding(20)
        }
        .background(PaperBackground())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selected = DayCalendar.startOfDay()
        }
    }

    private var monthHeader: some View {
        HStack {
            Button("上月") { shiftMonth(-1) }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(InkTheme.paperDeep, in: Capsule())
            Spacer()
            Text(monthTitle)
                .font(InkTheme.title)
                .foregroundStyle(InkTheme.ink)
            Spacer()
            Button("下月") { shiftMonth(1) }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(InkTheme.paperDeep, in: Capsule())
                .opacity(canGoToNextMonth ? 1 : 0.35)
                .disabled(!canGoToNextMonth)
        }
        .font(InkTheme.caption)
        .foregroundStyle(InkTheme.ink)
        .buttonStyle(.plain)
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy 年 M 月"
        return formatter.string(from: month)
    }

    private func statsRow(stats: (total: Int, counted: Int, average: Double)) -> some View {
        HStack(spacing: 10) {
            statCard(value: "\(stats.total)", label: "总分")
            statCard(value: "\(stats.counted)", label: "天数")
            statCard(
                value: stats.counted == 0 ? "—" : formatScore(stats.average),
                label: "平均分"
            )
        }
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 28, weight: .semibold, design: .rounded).monospacedDigit())
                .foregroundStyle(InkTheme.ink)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(label)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(InkTheme.inkSoft)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(InkTheme.cardShadow(12))
    }

    private func monthStats(map: [Date: DayPractice]) -> (total: Int, counted: Int, average: Double) {
        let today = DayCalendar.startOfDay()
        let counted = elapsedDaysInShownMonth()
        let total = map.values.reduce(0) { sum, day in
            guard day.dayStart <= today else { return sum }
            return sum + day.record.breakdown.displayTotal
        }
        let average = counted == 0 ? 0 : Double(total) / Double(counted)
        return (total, counted, average)
    }

    private func elapsedDaysInShownMonth() -> Int {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return 0 }
        let today = DayCalendar.startOfDay()
        if today < interval.start { return 0 }
        if today >= interval.end {
            return calendar.dateComponents([.day], from: interval.start, to: interval.end).day ?? 0
        }
        return calendar.component(.day, from: today)
    }

    private func calendar(map: [Date: DayPractice]) -> some View {
        let days = daysInMonthGrid()
        let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
        return VStack(spacing: 8) {
            HStack {
                ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { name in
                    Text(name)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(InkTheme.inkSoft)
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                    if let date {
                        dayCell(date: date, practice: map[date])
                    } else {
                        Color.clear.frame(height: 48)
                    }
                }
            }
        }
        .padding(12)
        .background(InkTheme.cardShadow(12))
    }

    private func dayCell(date: Date, practice: DayPractice?) -> some View {
        let dayNumber = Calendar.current.component(.day, from: date)
        let score = practice?.record.breakdown.displayTotal ?? 0
        let selectedDay = selected.map { DayCalendar.startOfDay(for: $0) } == date
        let isToday = Calendar.current.isDateInToday(date)
        return Button {
            selected = date
        } label: {
            VStack(spacing: 2) {
                Text("\(dayNumber)")
                    .font(.system(size: 11, weight: isToday ? .bold : .medium, design: .rounded))
                    .foregroundStyle(isToday ? InkTheme.seal : InkTheme.inkSoft)
                if score > 0 {
                    Text("\(score)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundStyle(InkTheme.ink)
                } else {
                    Text(" ")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(selectedDay ? InkTheme.sealWash : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    private func daysInMonthGrid() -> [Date?] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let weekday = calendar.component(.weekday, from: interval.start)
        let leading = weekday - 1
        var result: [Date?] = Array(repeating: nil, count: leading)
        var day = interval.start
        while day < interval.end {
            result.append(day)
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return result
    }

    private var canGoToNextMonth: Bool {
        let calendar = Calendar.current
        let current = calendar.dateInterval(of: .month, for: Date())?.start
        let shown = calendar.dateInterval(of: .month, for: month)?.start
        guard let current, let shown else { return false }
        return shown < current
    }

    private func shiftMonth(_ value: Int) {
        guard let next = Calendar.current.date(byAdding: .month, value: value, to: month) else { return }
        if value > 0, !canGoToNextMonth { return }
        let currentStart = Calendar.current.dateInterval(of: .month, for: Date())?.start
        let nextStart = Calendar.current.dateInterval(of: .month, for: next)?.start
        if let currentStart, let nextStart, nextStart > currentStart { return }
        month = DayCalendar.startOfDay(for: next)
        selected = nil
    }
}

struct DayDetailView: View {
    var day: DayPractice

    private var breakdown: ScoreBreakdown {
        day.record.breakdown
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("当日 \(breakdown.displayTotal)")
                .font(InkTheme.cardTitle)
                .foregroundStyle(InkTheme.ink)
            ForEach(PracticeKind.allCases) { kind in
                HStack {
                    Text(kind.title)
                        .foregroundStyle(InkTheme.ink)
                    Spacer()
                    Text("\(formatScore(breakdown.points(for: kind))) / \(formatScore(kind.maxScore))")
                        .foregroundStyle(InkTheme.seal)
                }
                .font(InkTheme.caption)
            }
        }
        .padding(16)
        .background(InkTheme.cardShadow(12))
    }
}
