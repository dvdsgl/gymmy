import UIKit

public extension Sequence {
    func groupBy<U : Hashable>(_ key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var dict: [U:[Iterator.Element]] = [:]
        for el in self {
            let key = key(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}

class ViewController: UITableViewController {

    var classes: [GymClass] = [] {
        didSet {
            classesByDay = classes.groupBy { Calendar.current.component(.weekday, from: $0.start) }
            
            let today = Calendar.current.component(.weekday, from: Date())
            sectionToWeekday = (today ... today+6).map { $0 <= 7 ? $0 : $0 - 7 }
            
            title = "\(classes.count) classes"
        }
    }
    
    var classesByDay = [Int: [GymClass]]()
    
    var sectionToWeekday = [Int]()

    let testerUrl = URL(string: "https://install.mobile.azure.com/orgs/mobile-center/apps/gymmy")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        classes = (try? FitnessSF.shared.getClasses()) ?? []
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Calendar.current.weekdaySymbols.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let weekday = sectionToWeekday[section]
        return Calendar.current.weekdaySymbols[weekday - 1]

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let weekday = sectionToWeekday[section]
        let classes = classesByDay[weekday] ?? []
        return classes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "event", for: indexPath)
        
        let weekday = sectionToWeekday[indexPath.section]
        let classes = classesByDay[weekday]!
        let event = classes[indexPath.row]
        
        let f = DateFormatter()
        f.dateFormat = "h:mma"
        let date = f.string(from: event.start)
        
        cell.textLabel?.text = "\(event.name) \(date)"
        cell.detailTextLabel?.text = event.description
        
        return cell
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        switch motion {
        case .motionShake:
            UIApplication.shared.open(testerUrl, options: [:])
        default:
            break
        }
    }
}

