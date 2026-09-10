import Foundation

enum ScoreEngine {
    static func minutesFromMidnight(_ date: Date, calendar: Calendar = .current) -> Int {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        return (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
    }

    /// Bedtime after midnight is later than 23:30, not an early evening.
    static func sleepMinutesForScoring(_ date: Date, calendar: Calendar = .current) -> Int {
        var minutes = minutesFromMidnight(date, calendar: calendar)
        if minutes < 12 * 60 {
            minutes += 24 * 60
        }
        return minutes
    }

    static func sleepPoints(_ date: Date?) -> Double {
        guard let date else { return 0 }
        return decayPoints(
            minutes: sleepMinutesForScoring(date),
            fullAt: 21 * 60 + 30,
            zeroAt: 23 * 60 + 30,
            maxPoints: 12
        )
    }

    static func wakePoints(_ date: Date?) -> Double {
        guard let date else { return 0 }
        return decayPoints(
            minutes: minutesFromMidnight(date),
            fullAt: 5 * 60 + 30,
            zeroAt: 7 * 60 + 30,
            maxPoints: 12
        )
    }

    /// After the full-score time, lose 1 point every 10 minutes until zero.
    private static func decayPoints(minutes: Int, fullAt: Int, zeroAt: Int, maxPoints: Double) -> Double {
        if minutes <= fullAt { return maxPoints }
        if minutes >= zeroAt { return 0 }
        let overdue = Double(minutes - fullAt)
        return max(0, maxPoints - overdue / 10)
    }

    static func zuoPoints(firstMinutes: Double, secondMinutes: Double) -> Double {
        let longer = max(0, firstMinutes, secondMinutes)
        let shorter = max(0, min(firstMinutes, secondMinutes))
        let base = min(15, longer / 90 * 15)
        let fromLongSit: Double
        if longer >= 120 {
            fromLongSit = 5
        } else if longer > 90 {
            fromLongSit = (longer - 90) / 30 * 5
        } else {
            fromLongSit = 0
        }
        let fromShorter = min(5, shorter / 60 * 5)
        let better = min(5, max(fromLongSit, fromShorter))
        return min(20, base + better)
    }

    static func zhanPoints(firstMinutes: Double) -> Double {
        min(12, max(0, firstMinutes) / 60 * 12)
    }

    static func emotionPoints(kuanCount: Int) -> Double {
        min(16, Double(max(kuanCount, 0)) / 40 * 16)
    }

    static func classicPoints(minutes: Double) -> Double {
        min(12, max(0, minutes) / 60 * 12)
    }

    static func dietPoints(
        breakfast: MealFullness,
        lunch: MealFullness,
        dinner: MealFullness,
        noSnacks: Bool,
        noAdditives: Bool
    ) -> Double {
        breakfast.points
            + lunch.points
            + dinner.points
            + (noSnacks ? 2 : 0)
            + (noAdditives ? 2 : 0)
    }

    static func movePoints(minutes: Double) -> Double {
        min(6, max(0, minutes) / 30 * 6)
    }

    static func breakdown(_ day: DayRecord) -> ScoreBreakdown {
        let sleep = sleepPoints(day.sleepAt)
        let wake = wakePoints(day.wakeAt)
        let rest = sleep + wake
        let zuo = zuoPoints(firstMinutes: day.zuoFirstMinutes, secondMinutes: day.zuoSecondMinutes)
        let zhan = zhanPoints(firstMinutes: day.zhanFirstMinutes)
        let emotion = emotionPoints(kuanCount: day.kuanCount)
        let classic = classicPoints(minutes: day.classicMinutes)
        let diet = dietPoints(
            breakfast: day.breakfast,
            lunch: day.lunch,
            dinner: day.dinner,
            noSnacks: day.noSnacks,
            noAdditives: day.noAdditives
        )
        let move = movePoints(minutes: day.moveMinutes)
        let items: [PracticeKind: Double] = [
            .sleep: rest,
            .zuo: zuo,
            .zhan: zhan,
            .emotion: emotion,
            .classic: classic,
            .diet: diet,
            .move: move
        ]
        let total = rest + zuo + zhan + emotion + classic + diet + move
        return ScoreBreakdown(items: items, total: total)
    }

    static func displayTotal(_ total: Double) -> Int {
        Int(total.rounded())
    }

    #if DEBUG
    static func selfCheck() {
        let zuoHalf = zuoPoints(firstMinutes: 45, secondMinutes: 0)
        precondition(abs(zuoHalf - 7.5) < 0.01, "打坐 45 分钟应为 7.5，得到 \(zuoHalf)")
        precondition(abs(zuoPoints(firstMinutes: 90, secondMinutes: 0) - 15) < 0.01)
        precondition(abs(zuoPoints(firstMinutes: 120, secondMinutes: 0) - 20) < 0.01)
        precondition(abs(zuoPoints(firstMinutes: 90, secondMinutes: 60) - 20) < 0.01)
        precondition(abs(zuoPoints(firstMinutes: 60, secondMinutes: 90) - 20) < 0.01)
        precondition(abs(zuoPoints(firstMinutes: 90, secondMinutes: 30) - 17.5) < 0.01)
        precondition(abs(zuoPoints(firstMinutes: 105, secondMinutes: 0) - 17.5) < 0.01)
        precondition(abs(zhanPoints(firstMinutes: 30) - 6) < 0.01)
        precondition(abs(zhanPoints(firstMinutes: 60) - 12) < 0.01)
        precondition(abs(emotionPoints(kuanCount: 20) - 8) < 0.01)
        precondition(abs(emotionPoints(kuanCount: 40) - 16) < 0.01)
        precondition(abs(classicPoints(minutes: 30) - 6) < 0.01)
        precondition(abs(classicPoints(minutes: 60) - 12) < 0.01)
        precondition(abs(movePoints(minutes: 15) - 3) < 0.01)
        precondition(abs(movePoints(minutes: 30) - 6) < 0.01)
        let diet = dietPoints(
            breakfast: .seven,
            lunch: .eight,
            dinner: .eight,
            noSnacks: true,
            noAdditives: true
        )
        precondition(abs(diet - 8) < 0.01, "饮食例题应为 8，得到 \(diet)")
        let sleepFull = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 7, hour: 21, minute: 30))
        let sleepTen = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 7, hour: 22, minute: 0))
        let sleepPastMidnight = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 8, hour: 0, minute: 30))
        let wakeFull = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 7, hour: 5, minute: 30))
        precondition(abs(sleepPoints(sleepFull) - 12) < 0.01)
        precondition(abs(sleepPoints(sleepTen) - 9) < 0.01)
        precondition(abs(sleepPoints(sleepPastMidnight) - 0) < 0.01)
        precondition(abs(wakePoints(wakeFull) - 12) < 0.01)

        let dayStart = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 7))!
        let pickedEvening = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 7, hour: 21, minute: 40))!
        let pickedLate = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 7, hour: 0, minute: 20))!
        let evening = RestClock.normalizedSleep(dayStart: dayStart, picked: pickedEvening)
        let late = RestClock.normalizedSleep(dayStart: dayStart, picked: pickedLate)
        precondition(Calendar.current.component(.day, from: evening) == 6)
        precondition(Calendar.current.component(.hour, from: evening) == 21)
        precondition(Calendar.current.component(.day, from: late) == 7)
        precondition(Calendar.current.component(.hour, from: late) == 0)
    }
    #endif
}

struct ScoreBreakdown {
    var items: [PracticeKind: Double]
    var total: Double

    func points(for kind: PracticeKind) -> Double {
        items[kind] ?? 0
    }

    var displayTotal: Int {
        ScoreEngine.displayTotal(total)
    }
}

struct DayRecord: Codable, Hashable {
    var dayStart: Date
    var sleepAt: Date?
    var wakeAt: Date?
    var zuoFirstMinutes: Double
    var zuoSecondMinutes: Double
    var zhanFirstMinutes: Double
    var kuanCount: Int
    var classicMinutes: Double
    var breakfast: MealFullness
    var lunch: MealFullness
    var dinner: MealFullness
    var noSnacks: Bool
    var noAdditives: Bool
    var moveMinutes: Double

    static func empty(dayStart: Date) -> DayRecord {
        DayRecord(
            dayStart: dayStart,
            sleepAt: nil,
            wakeAt: nil,
            zuoFirstMinutes: 0,
            zuoSecondMinutes: 0,
            zhanFirstMinutes: 0,
            kuanCount: 0,
            classicMinutes: 0,
            breakfast: .unset,
            lunch: .unset,
            dinner: .unset,
            noSnacks: false,
            noAdditives: false,
            moveMinutes: 0
        )
    }

    var breakdown: ScoreBreakdown {
        ScoreEngine.breakdown(self)
    }
}
