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
            let cal = Calendar.current
            classesByDay = classes.groupBy { c in
                let day = cal.component(.weekday, from: c.start)
                let dayName = cal.weekdaySymbols[day - 1]
                return dayName
            }
        }
    }
    
    var classesByDay = [String: [GymClass]]()

    let testerUrl = URL(string: "https://install.mobile.azure.com/orgs/mobile-center/apps/gymmy")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        classes = (try? FitnessSF.shared.getClasses()) ?? []
        
        title = "\(classes.count) classes"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Calendar.current.weekdaySymbols.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let days = Calendar.current.weekdaySymbols
        let day = days[section]
        return day
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let day = Calendar.current.weekdaySymbols[section]
        let classes = classesByDay[day] ?? []
        return classes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "event", for: indexPath)
        
        let day = Calendar.current.weekdaySymbols[indexPath.section]
        
        let event = classesByDay[day]![indexPath.row]
        
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

