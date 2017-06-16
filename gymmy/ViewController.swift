import UIKit
import SwiftSoup

struct GymClass {
    let name, description, time, trainer, studio: String
}

class ViewController: UITableViewController {

    var classes = [GymClass]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        classes = (try? getClasses()) ?? []
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
            for event in try studio.select(".single-event") {
                classes.append(GymClass(
                    name: try event.select("h4").text(),
                    description: try event.select(".event-description-content").text(),
                    time: try event.select(".event-time").text(),
                    trainer: try event.select(".event-trainer").text(),
                    studio: studioName
                ))
            }
        }
        
        return classes
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "event", for: indexPath)
        
        let event = classes[indexPath.row]
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.description
        
        return cell
    }
}

