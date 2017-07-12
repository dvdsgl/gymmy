//
//  ClassDetailViewController.swift
//  gymmy
//
//  Created by David SIegel on 7/11/17.
//  Copyright © 2017 David Siegel. All rights reserved.
//

import UIKit

class ClassDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var gymClass: GymClass! {
        didSet {
            update()
        }
    }
    
    func update() {
        title = gymClass.name
        titleLabel?.text = gymClass.name
        
        descriptionLabel?.text = gymClass.description
        descriptionLabel?.sizeToFit()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
