//
//  ExSlideMenuController.swift
//  
//
//  Created by Ashish jha on 9/13/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit

class ExSlideMenuController: SlideMenuController {

    override func isTagetViewController() -> Bool {
        if let vc = UIApplication.topViewController() {
            if vc is HomeScreenViewController || vc is ScheduleRydesViewController ||
                vc is PastRydesViewController || vc is HelpViewController {
                return true
            }
        }
        return false
    }
}
