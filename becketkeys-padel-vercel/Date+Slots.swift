import Foundation

extension Date {
    private static let slotFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()

    var startOfDayLocal: Date {
        Calendar.current.startOfDay(for: self)
    }

    var slotTimeString: String {
        Self.slotFormatter.string(from: self)
    }

    var displayDayString: String {
        Self.dayFormatter.string(from: self)
    }

    var isMorningSlot: Bool {
        let hour = Calendar.current.component(.hour, from: self)
        return hour < 12
    }

    func addingMinutes(_ minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }

    func atLocalTime(hour: Int, minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self.startOfDayLocal) ?? self
    }

    func bookingRecordID(forCourt court: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "yyyyMMdd-HHmm"
        return "booking-\(formatter.string(from: self))-court-\(court)"
    }

    static func validSlots(for day: Date) -> [Date] {
        var results: [Date] = []

        for window in SchoolConfig.windows {
            let start = day.atLocalTime(hour: window.startHour, minute: window.startMinute)
            let end = day.atLocalTime(hour: window.endHour, minute: window.endMinute)
            var current = start

            while current < end {
                results.append(current)
                current = current.addingMinutes(SchoolConfig.slotLengthMinutes)
            }
        }

        return results
    }
}
