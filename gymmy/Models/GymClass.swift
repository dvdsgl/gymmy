import Foundation

struct GymClass {
    let name, description, trainer, studio: String
    let start, end: Date
}

extension GymClass {
    var hasAlreadyStarted: Bool {
        return Calendar.current.isDateInToday(start) && start < Date()
    }
}
