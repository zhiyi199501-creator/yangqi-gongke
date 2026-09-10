import SwiftUI
import SwiftData
import UserNotifications

func formatScore(_ value: Double) -> String {
    if abs(value.rounded() - value) < 0.05 {
        return String(Int(value.rounded()))
    }
    return String(format: "%.1f", value)
}

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var todayRows: [DayPractice]
    @State private var reminderOn = false

    init() {
        let start = DayCalendar.startOfDay()
        _todayRows = Query(
            filter: #Predicate<DayPractice> { $0.dayStart == start }
        )
    }

    private var controller: PracticeController {
        PracticeController(context: modelContext)
    }

    private var day: DayPractice {
        todayRows.first ?? controller.day()
    }

    private var breakdown: ScoreBreakdown {
        day.record.breakdown
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                header
                VStack(spacing: 12) {
                    ForEach(PracticeKind.allCases) { kind in
                        PracticeCard(
                            kind: kind,
                            day: day,
                            points: breakdown.points(for: kind),
                            onChange: { save() }
                        )
                    }
                }
                reminderRow
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 56)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(PaperBackground())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完成") {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
                .foregroundStyle(InkTheme.lamp)
            }
        }
        .onAppear {
            _ = controller.day()
            reminderOn = UserDefaults.standard.bool(forKey: "nineReminder")
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(dayLabel)
                    .font(InkTheme.kaiti(16))
                    .foregroundStyle(InkTheme.inkSoft)
                    .tracking(3)
                Text("\(breakdown.displayTotal)")
                    .font(InkTheme.score)
                    .foregroundStyle(InkTheme.ink)
                    .contentTransition(.numericText())
                Text(scoreLine)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(scoreLineColor)
            }
            Spacer(minLength: 0)
            InkQiView(score: breakdown.displayTotal)
                .frame(width: 96, height: 96)
                .fixedSize()
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var scoreLine: String {
        ScoreCopy.todayLine(for: breakdown.displayTotal)
    }

    private var scoreLineColor: Color {
        let total = breakdown.displayTotal
        if total < 10 { return InkTheme.inkSoft }
        if total >= 90 { return InkTheme.lamp }
        return InkTheme.seal
    }

    private var dayLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M 月 d 日"
        return formatter.string(from: day.dayStart)
    }

    private var reminderRow: some View {
        Toggle(isOn: $reminderOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text("九点将至")
                    .font(InkTheme.cardTitle)
                    .foregroundStyle(InkTheme.ink)
                Text("轻提醒，好赶上 21:30")
                    .font(.caption)
                    .foregroundStyle(InkTheme.inkSoft)
            }
        }
        .tint(InkTheme.seal)
        .padding(16)
        .background(InkTheme.cardShadow(12))
        .padding(.top, 4)
        .onChange(of: reminderOn) { _, on in
            UserDefaults.standard.set(on, forKey: "nineReminder")
            NineReminder.setEnabled(on)
        }
    }

    private func save() {
        controller.save(day)
    }
}

enum NineReminder {
    static func setEnabled(_ enabled: Bool) {
        let center = UNUserNotificationCenter.current()
        if !enabled {
            center.removePendingNotificationRequests(withIdentifiers: ["nineReminder"])
            return
        }
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "九点将至"
            content.body = "亥时将入。若能早歇，作息可满。"
            content.sound = .default
            var date = DateComponents()
            date.hour = 21
            date.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
            let request = UNNotificationRequest(identifier: "nineReminder", content: content, trigger: trigger)
            center.add(request)
        }
    }
}
