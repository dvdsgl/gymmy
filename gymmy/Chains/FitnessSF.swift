import Foundation

import SwiftSoup

class FitnessSF {
    
    static let shared = FitnessSF()
    
    // Get upcoming start and end dates for a weekday and time range (e.g. "1:30pm - 2:45pm")
    private func startAndEndDates(weekday day: String, timeRange: String) -> (start: Date, end: Date)? {
        let cal = Calendar.current
        
        let times = timeRange.components(separatedBy: " - ")
        
        guard times.count == 2 else { return nil }
        
        let f = DateFormatter()
        f.dateFormat = "EEE h:mma"
        
        guard let start = f.date(from: "\(day) \(times[0])") else { return nil }
        guard let end = f.date(from: "\(day) \(times[1])") else { return nil }
        
        let startComponents = cal.dateComponents([.weekday, .hour, .minute], from: start)
        let endComponents = cal.dateComponents([.weekday, .hour, .minute], from: end)
        
        let startOfToday = cal.startOfDay(for: Date())
        
        guard let startDate = cal.nextDate(after: startOfToday,
                                           matching: startComponents,
                                           matchingPolicy: .nextTime,
                                           repeatedTimePolicy: .first,
                                           direction: .forward) else { return nil }
        
        guard let endDate = cal.nextDate(after: startDate,
                                         matching: endComponents,
                                         matchingPolicy: .nextTime,
                                         repeatedTimePolicy: .first,
                                         direction: .forward) else { return nil }
        
        
        return (startDate, endDate)
    }
    
    func getClasses() throws -> [GymClass] {
        let url = URL(string: "https://fitnesssf.com/events/mid-market")!
        let html = try String(contentsOf: url)
        let doc = try SwiftSoup.parse(html)
        var classes = [GymClass]()
        
        let studios = [
            (id: "cycle", name: "Studio Cycle"),
            (id: "escape", name: "Studio Escape"),
            (id: "energy", name: "Studio Energy")
        ]
        
        for (id, name: studioName) in studios {
            let studio = try doc.select("#\(id).schedule")
            for day in try studio.select(".schedule-day-name") {
                for event in try day.siblingElements().select(".single-event") {
                    
                    let day = try day.text()
                    let time = try event.select(".event-time").text()
                    guard let (start, end) = startAndEndDates(weekday: day, timeRange: time) else { continue }
                    
                    classes.append(GymClass(
                        name: try event.select("h4").text(),
                        description: try event.select(".event-description-content").text(),
                        trainer: try event.select(".event-trainer").text(),
                        studio: studioName,
                        start: start,
                        end: end
                    ))
                }
            }
        }
        
        return classes.sorted { $0.start < $1.start }
    }
}
