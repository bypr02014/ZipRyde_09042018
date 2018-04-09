//
//  UserDetailTableViewCell.swift
//  ZipRyde
//
//  Created by Ashish jha on 9/13/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit

class UserDetailTableViewCell : UITableViewCell {
    
    @IBOutlet var fullNameLabel: UILabel!
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var editProfileButton: UIButton!
    @IBOutlet var riderImageView: UIImageView!

    class var identifier: String { return String.className(self) }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
