//
//  ClassTableViewCell.swift
//  gymmy
//
//  Created by David SIegel on 7/10/17.
//  Copyright © 2017 David Siegel. All rights reserved.
//

import UIKit

class ClassTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var studioLabel: UILabel!
    
    typealias StudioDetails = (color: UIColor, icon: FontType)
    
    let studioDetails: [String: StudioDetails] = [
        "Studio Escape": (
            color: #colorLiteral(red: 0.5568627451, green: 0.2666666667, blue: 0.6784313725, alpha: 1),
            icon: .ionicons(.leaf)
        ),
        "Studio Cycle": (
            color: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1),
            icon: .ionicons(.androidBicycle)
        ),
        "Studio Energy":(
            color: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1),
            icon: .ionicons(.heart)
        )
    ]
    
    var event: GymClass! {
        didSet {
            titleLabel.text = event.name
            studioLabel.text = event.studio + " • " + event.trainer
            
            let f = DateFormatter()
            f.dateFormat = "h:mma"
            timeLabel.text = f.string(from: event.start).lowercased()
            
            let preferredColor = studioDetails[event.studio]?.color ?? UIColor.darkGray
            let accentColor = event.hasAlreadyStarted ? UIColor.lightGray : preferredColor
            icon.backgroundColor = accentColor
            
            let symbol = studioDetails[event.studio]?.icon ?? .ionicons(.help)
            icon.setIcon(icon: symbol, textColor: .white, backgroundColor: .clear, size: CGSize(width: 34, height: 34))
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
