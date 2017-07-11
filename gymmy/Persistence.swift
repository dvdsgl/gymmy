import Foundation

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
    
    static func cachedHTML(for url: String) -> (String, Date)? {
        if let html = defaults.string(forKey: "cached \(url)") {
            if let date = defaults.value(forKey: "cached \(url) date") as? Date {
                return (html, date)
            }
        }
        return nil
    }
    
    static func cacheHTML(for url: String, html: String) {
        defaults.set(html, forKey: "cached \(url)")
        defaults.set(Date(), forKey: "cached \(url) date")
    }
    
    static func cachedOrDownload(url: String, expireAfter: TimeInterval = 60 * 60 * 24) -> String? {
        if let (html, date) = cachedHTML(for: url) {
            if Date() < date.addingTimeInterval(expireAfter) {
                return html
            }
        }
        
        guard let theUrl = URL(string: url) else { return nil }
        
        if let html = try? String(contentsOf: theUrl) {
            cacheHTML(for: url, html: html)
            return html
        }
        
        return nil
    }
}
