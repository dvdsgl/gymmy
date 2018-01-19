import UIKit
import Foundation

import AppCenterAnalytics

public extension Sequence {
    func groupBy<U>(_ key: (Iterator.Element) -> U) -> [U: [Iterator.Element]] {
        var dict: [U:[Iterator.Element]] = [:]
        for el in self {
            let key = key(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}

class ClassListViewController: UITableViewController {
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var classes: [GymClass] = [] {
        didSet {
           update()
        }
    }
    
    func update() {
        let studio = studioFilter ?? "All Studios"
        title = "Fitness SF • \(studio)"
        
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
        let expires =  Date().addingTimeInterval(-60 * 30) // Keep classes in list for 30 minutes after they end
        let today = Calendar.current.component(.weekday, from: Date())
        let todaysClasses = classesByDay[today]
        return todaysClasses?.filter { expires < $0.end } ?? []
    }
    
    var sectionToWeekday = [Int]()

    let testerUrl = URL(string: "https://install.appcenter.ms/orgs/appcenter/apps/gymmy")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set back button title to '  ', otherwise the title is long
        let backItem = UIBarButtonItem()
        backItem.title = "  "
        navigationItem.backBarButtonItem = backItem
        
        filterButton.setIcon(icon: .ionicons(.androidFunnel), iconSize: 25)
        studioFilter = Persistence.studioFilter
        
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self,
                                 action: #selector(refreshOptions(sender:)),
                                 for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshAsync {
        }
    }
    
    @objc private func refreshOptions(sender: UIRefreshControl) {
        MSAnalytics.trackEvent("pull to refresh")
        refreshAsync {
            sender.endRefreshing()
        }
    }
    
    func refreshAsync(completed: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            var classes: [GymClass]?
            do {
                classes = try FitnessSF.shared.getClasses(latest: true)
            } catch _ {
                MSAnalytics.trackEvent("getClasses failed")
            }
            DispatchQueue.main.async {
                if let classes = classes {
                    self.classes = classes
                }
                completed()
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if classesByDay.isEmpty {
            return 0
        }
        return Calendar.current.weekdaySymbols.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Today"
        case 1:
            return "Tomorrow"
        default:
            let weekday = sectionToWeekday[section]
            return Calendar.current.weekdaySymbols[weekday - 1]
        }
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
                handler: { _ in
                    MSAnalytics.trackEvent("filter studio", withProperties:[
                        "studio": studio
                    ])
                    self.studioFilter = studio
                }
            )
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(
            title: "All Studios",
            style: .cancel,
            handler: { _ in
                MSAnalytics.trackEvent("filter studio", withProperties:[
                    "studio": "all"
                ])
                self.studioFilter = nil
            }
        ))
        
        present(alert, animated: true)
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        switch motion {
        case .motionShake:
            MSAnalytics.trackEvent("shake")
            UIApplication.shared.open(testerUrl, options: [:])
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let detail as ClassDetailViewController:
            guard let selection = tableView.indexPathForSelectedRow else { return }
            
            switch selection.section {
            case 0:
                detail.gymClass = todaysRemainingClasses[selection.row]
            default:
                let weekday = sectionToWeekday[selection.section]
                let classes = classesByDay[weekday]!
                detail.gymClass = classes[selection.row]
            }
            
            MSAnalytics.trackEvent("view class", withProperties:[
                "name": detail.gymClass.name,
                "studio": detail.gymClass.studio,
                "trainer": detail.gymClass.trainer
            ])
        default:
            break
        }
    }
}

