import UIKit
import SwiftSoup

struct GymClass {
    let name, description, day, time, trainer, studio: String
}

class ViewController: UITableViewController {

    var classes = [GymClass]()
    
    var classesByDay = [String: [GymClass]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        classes = (try? getClasses()) ?? []
        
        classesByDay.removeAll()
        for c in classes {
            var cs = classesByDay[c.day] ?? []
            cs.append(c)
            classesByDay[c.day] = cs
        }
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
            for day in try doc.select(".schedule-day-name") {
                for event in try day.siblingElements().select(".single-event") {
                    classes.append(GymClass(
                        name: try event.select("h4").text(),
                        description: try event.select(".event-description-content").text(),
                        day: try day.text(),
                        time: try event.select(".event-time").text(),
                        trainer: try event.select(".event-trainer").text(),
                        studio: studioName
                    ))
                }
            }
        }
        
        return classes
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return classesByDay.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let days = [String](classesByDay.keys)
        let day = days[section]
        return day
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let days = [String](classesByDay.keys)
        let day = days[section]
        let classes = classesByDay[day] ?? []
        return classes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "event", for: indexPath)
        
        let days = [String](classesByDay.keys)
        let day = days[indexPath.section]
        
        let event = classesByDay[day]![indexPath.row]
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.description
        
        return cell
    }
}

