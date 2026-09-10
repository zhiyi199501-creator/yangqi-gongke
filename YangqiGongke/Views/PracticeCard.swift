import SwiftUI
import SwiftData

struct PracticeCard: View {
    var kind: PracticeKind
    @Bindable var day: DayPractice
    var points: Double
    var onChange: () -> Void

    private var intensity: Double {
        min(1, points / kind.maxScore)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Capsule()
                .fill(InkTheme.seal.opacity(0.35 + 0.65 * intensity))
                .frame(width: 5, height: 56)

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Text(kind.title)
                        .font(InkTheme.kaiti(18))
                        .foregroundStyle(InkTheme.ink)
                    Spacer()
                    Text("\(formatScore(points))")
                        .font(.system(.body, design: .rounded, weight: .semibold).monospacedDigit())
                        .foregroundStyle(InkTheme.seal)
                    Text("/ \(formatScore(kind.maxScore))")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(InkTheme.inkSoft)
                }
                content
            }
        }
        .padding(16)
        .background(InkTheme.cardShadow())
    }

    @ViewBuilder
    private var content: some View {
        switch kind {
        case .sleep:
            restContent
        case .emotion:
            emotionContent
        case .diet:
            dietContent
        case .zuo, .zhan, .classic, .move:
            minutesContent
        }
    }

    private var restContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("晚上 21:30 前入睡、早上 5:30 前起床满分")
                .font(.caption)
                .foregroundStyle(InkTheme.inkSoft)
            restRow(
                title: "入睡",
                stored: day.sleepAt,
                binding: sleepBinding,
                placeholder: RestClock.defaultSleep(for: day.dayStart)
            ) {
                day.sleepAt = RestClock.defaultSleep(for: day.dayStart)
                onChange()
            } clear: {
                day.sleepAt = nil
                onChange()
            }
            restRow(
                title: "起床",
                stored: day.wakeAt,
                binding: wakeBinding,
                placeholder: RestClock.defaultWake(for: day.dayStart)
            ) {
                day.wakeAt = RestClock.defaultWake(for: day.dayStart)
                onChange()
            } clear: {
                day.wakeAt = nil
                onChange()
            }
        }
    }

    private var sleepBinding: Binding<Date> {
        Binding(
            get: { day.sleepAt ?? RestClock.defaultSleep(for: day.dayStart) },
            set: { newValue in
                day.sleepAt = RestClock.normalizedSleep(dayStart: day.dayStart, picked: newValue)
                onChange()
            }
        )
    }

    private var wakeBinding: Binding<Date> {
        Binding(
            get: { day.wakeAt ?? RestClock.defaultWake(for: day.dayStart) },
            set: { newValue in
                day.wakeAt = RestClock.normalizedWake(dayStart: day.dayStart, picked: newValue)
                onChange()
            }
        )
    }

    private func restRow(
        title: String,
        stored: Date?,
        binding: Binding<Date>,
        placeholder: Date,
        fillDefault: @escaping () -> Void,
        clear: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 10) {
            Text(title)
                .font(InkTheme.kaiti(16))
                .foregroundStyle(InkTheme.ink)
                .frame(width: 36, alignment: .leading)
            Spacer(minLength: 0)
            if stored == nil {
                Button(action: fillDefault) {
                    HStack(spacing: 6) {
                        Text("未记")
                        Text(timeString(placeholder))
                            .foregroundStyle(InkTheme.inkSoft.opacity(0.7))
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .foregroundStyle(InkTheme.inkSoft)
                    .background(InkTheme.paperDeep, in: Capsule())
                }
                .buttonStyle(.plain)
            } else {
                DatePicker("", selection: binding, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .tint(InkTheme.seal)
                    .environment(\.locale, Locale(identifier: "zh_CN"))
                    .colorScheme(.light)
                Button("清除", action: clear)
                    .font(.caption)
                    .foregroundStyle(InkTheme.inkSoft)
            }
        }
    }

    private var emotionContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("40 次满分")
                .font(.caption)
                .foregroundStyle(InkTheme.inkSoft)
            HStack(spacing: 8) {
                Text("今日")
                    .font(InkTheme.kaiti(14))
                    .foregroundStyle(InkTheme.inkSoft)
                    .frame(width: 48, alignment: .leading)
                TextField("0", text: blankZeroInt($day.kuanCount))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .monospacedDigit()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .foregroundStyle(InkTheme.ink)
                    .background(InkTheme.paperDeep, in: RoundedRectangle(cornerRadius: InkTheme.chipRadius, style: .continuous))
                Text("次")
                    .font(.caption)
                    .foregroundStyle(InkTheme.inkSoft)
            }
        }
    }

    private var dietContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            mealRow("早", value: $day.breakfastRaw)
            mealRow("午", value: $day.lunchRaw)
            mealRow("晚", value: $day.dinnerRaw)
            HStack(spacing: 10) {
                toggleChip("无零食", isOn: $day.noSnacks)
                toggleChip("饮食洁净", isOn: $day.noAdditives)
            }
        }
    }

    private func mealRow(_ title: String, value: Binding<String>) -> some View {
        HStack {
            Text(title)
                .font(InkTheme.kaiti(14))
                .foregroundStyle(InkTheme.inkSoft)
                .frame(width: 22, alignment: .leading)
            ForEach(MealFullness.allCases.filter { $0 != .unset }) { fullness in
                let selected = value.wrappedValue == fullness.rawValue
                Button {
                    value.wrappedValue = fullness.rawValue
                    onChange()
                } label: {
                    Text(fullness.label)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .foregroundStyle(selected ? Color.white : InkTheme.ink)
                        .background(selected ? InkTheme.seal : InkTheme.paperDeep, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .onChange(of: value.wrappedValue) { _, _ in
            onChange()
        }
    }

    private func toggleChip(_ title: String, isOn: Binding<Bool>) -> some View {
        Button {
            isOn.wrappedValue.toggle()
            onChange()
        } label: {
            Text(title)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(isOn.wrappedValue ? Color.white : InkTheme.ink)
                .background(isOn.wrappedValue ? InkTheme.seal : InkTheme.paperDeep, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var minutesContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(minutesCaption)
                .font(.caption)
                .foregroundStyle(InkTheme.inkSoft)
            switch kind {
            case .zuo:
                minutesField("第一次", value: $day.zuoFirstMinutes)
                minutesField("第二次", value: $day.zuoSecondMinutes)
            case .zhan:
                minutesField("今日", value: $day.zhanFirstMinutes)
            case .classic:
                minutesField("今日", value: $day.classicMinutes)
            case .move:
                minutesField("今日", value: $day.moveMinutes)
            default:
                EmptyView()
            }
        }
    }

    private var minutesCaption: String {
        switch kind {
        case .zuo:
            return "120 分钟满分，或 90 分钟加 60 分钟满分"
        case .zhan:
            return "60 分钟满分"
        case .classic:
            return "60 分钟满分"
        case .move:
            return "30 分钟满分"
        default:
            return ""
        }
    }

    private func minutesField(_ title: String, value: Binding<Double>) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(InkTheme.kaiti(14))
                .foregroundStyle(InkTheme.inkSoft)
                .frame(width: 48, alignment: .leading)
            TextField("0", text: blankZero(value))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .monospacedDigit()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .foregroundStyle(InkTheme.ink)
                .background(InkTheme.paperDeep, in: RoundedRectangle(cornerRadius: InkTheme.chipRadius, style: .continuous))
            Text("分钟")
                .font(.caption)
                .foregroundStyle(InkTheme.inkSoft)
        }
    }

    private func blankZero(_ value: Binding<Double>) -> Binding<String> {
        Binding(
            get: {
                let amount = value.wrappedValue
                guard amount != 0 else { return "" }
                if abs(amount.rounded() - amount) < 0.05 {
                    return String(Int(amount.rounded()))
                }
                return String(format: "%.1f", amount)
            },
            set: { newValue in
                let trimmed = newValue
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: ",", with: ".")
                if trimmed.isEmpty {
                    value.wrappedValue = 0
                    onChange()
                    return
                }
                guard let parsed = Double(trimmed) else { return }
                value.wrappedValue = parsed
                onChange()
            }
        )
    }

    private func blankZeroInt(_ value: Binding<Int>) -> Binding<String> {
        Binding(
            get: { value.wrappedValue == 0 ? "" : String(value.wrappedValue) },
            set: { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty {
                    value.wrappedValue = 0
                    onChange()
                    return
                }
                guard let parsed = Int(trimmed) else { return }
                value.wrappedValue = parsed
                onChange()
            }
        )
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
