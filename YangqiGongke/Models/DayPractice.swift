import Foundation
import SwiftData

@Model
final class DayPractice {
    @Attribute(.unique) var dayStart: Date
    var sleepAt: Date?
    var wakeAt: Date?
    var zuoFirstMinutes: Double
    var zuoSecondMinutes: Double
    var zhanFirstMinutes: Double
    var kuanCount: Int
    var classicMinutes: Double
    var breakfastRaw: String
    var lunchRaw: String
    var dinnerRaw: String
    var noSnacks: Bool
    var noAdditives: Bool
    var moveMinutes: Double

    init(dayStart: Date) {
        self.dayStart = dayStart
        self.zuoFirstMinutes = 0
        self.zuoSecondMinutes = 0
        self.zhanFirstMinutes = 0
        self.kuanCount = 0
        self.classicMinutes = 0
        self.breakfastRaw = MealFullness.unset.rawValue
        self.lunchRaw = MealFullness.unset.rawValue
        self.dinnerRaw = MealFullness.unset.rawValue
        self.noSnacks = false
        self.noAdditives = false
        self.moveMinutes = 0
    }

    var breakfast: MealFullness {
        get { MealFullness(rawValue: breakfastRaw) ?? .unset }
        set { breakfastRaw = newValue.rawValue }
    }

    var lunch: MealFullness {
        get { MealFullness(rawValue: lunchRaw) ?? .unset }
        set { lunchRaw = newValue.rawValue }
    }

    var dinner: MealFullness {
        get { MealFullness(rawValue: dinnerRaw) ?? .unset }
        set { dinnerRaw = newValue.rawValue }
    }

    var record: DayRecord {
        DayRecord(
            dayStart: dayStart,
            sleepAt: sleepAt,
            wakeAt: wakeAt,
            zuoFirstMinutes: zuoFirstMinutes,
            zuoSecondMinutes: zuoSecondMinutes,
            zhanFirstMinutes: zhanFirstMinutes,
            kuanCount: kuanCount,
            classicMinutes: classicMinutes,
            breakfast: breakfast,
            lunch: lunch,
            dinner: dinner,
            noSnacks: noSnacks,
            noAdditives: noAdditives,
            moveMinutes: moveMinutes
        )
    }

    func apply(_ record: DayRecord) {
        sleepAt = record.sleepAt
        wakeAt = record.wakeAt
        zuoFirstMinutes = record.zuoFirstMinutes
        zuoSecondMinutes = record.zuoSecondMinutes
        zhanFirstMinutes = record.zhanFirstMinutes
        kuanCount = record.kuanCount
        classicMinutes = record.classicMinutes
        breakfast = record.breakfast
        lunch = record.lunch
        dinner = record.dinner
        noSnacks = record.noSnacks
        noAdditives = record.noAdditives
        moveMinutes = record.moveMinutes
    }
}
