import UIKit
import Foundation

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

class Persistence {
    static let defaults = UserDefaults.standard
    static var studioFilter: String? {
        get {
            return defaults.string(forKey: "studioFilter")
        }
        set(newValue) {
            defaults.set(newValue, forKey: "studioFilter")
        }
    }
}

class ViewController: UITableViewController {
    var classes: [GymClass] = [] {
        didSet {
           update()
        }
    }
    
    func update() {
        let studio = studioFilter ?? "All Studios"
        title = "\(filteredClasses.count) classes • \(studio)"
        
        let today = Calendar.current.component(.weekday, from: Date())
        sectionToWeekday = (today ... today+6).map { $0 <= 7 ? $0 : $0 - 7 }
        
        classesByDay = filteredClasses.groupBy { Calendar.current.component(.weekday, from: $0.start) }
        
        tableView.reloadData()
    }
    
    private var filteredClasses: [GymClass] {
        if let studio = studioFilter {
            return classes.filter { $0.studio == studio }
        } else {
            return classes
        }
    }
    
    var classesByDay = [Int: [GymClass]]()
    
    var todaysRemainingClasses: [GymClass] {
        let now =  Date()
        let today = Calendar.current.component(.weekday, from: now)
        let todaysClasses = classesByDay[today]
        return todaysClasses?.filter { now < $0.start } ?? []
    }
    
    var sectionToWeekday = [Int]()

    let testerUrl = URL(string: "https://install.mobile.azure.com/orgs/mobile-center/apps/gymmy")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classes = (try? FitnessSF.shared.getClasses()) ?? []
        studioFilter = Persistence.studioFilter
        
        update()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Calendar.current.weekdaySymbols.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let weekday = sectionToWeekday[section]
        return Calendar.current.weekdaySymbols[weekday - 1]

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return todaysRemainingClasses.count
        }
        
        let weekday = sectionToWeekday[section]
        let classes = classesByDay[weekday] ?? []
        return classes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "event", for: indexPath) as! ClassTableViewCell
        
        let weekday = sectionToWeekday[indexPath.section]
        let classes = indexPath.section == 0 ? todaysRemainingClasses : classesByDay[weekday]!
        let event = classes[indexPath.row]
        
        cell.event = event
        
        return cell
    }
    
    var studioFilter: String? {
        didSet {
            Persistence.studioFilter = studioFilter
            update()
        }
    }
    
    @IBAction func filter(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let studios = classes.groupBy { $0.studio }.values.map { $0.first!.studio }
        for studio in studios {
            let action = UIAlertAction(
                title: studio,
                style: .default,
                handler: { _ in self.studioFilter = studio }
            )
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(
            title: "All Studios",
            style: .cancel,
            handler: { _ in self.studioFilter = nil }
        ))
        
        present(alert, animated: true)
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

