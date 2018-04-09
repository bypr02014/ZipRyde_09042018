//
//  RideDetailCell.swift
//  ZipRyde
//
//  Created by Ashish jha on 10/14/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit

class RideDetailCell : UITableViewCell {
    @IBOutlet var zipStatusLabel: UILabel!
    @IBOutlet var suggestedFareLabel: UILabel!
    @IBOutlet var destinationAddressLabel: UILabel!
    @IBOutlet var sourceAddressLabel: UILabel!
    @IBOutlet var driverImageView: UIImageView!
    @IBOutlet var offerFareLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var cabTypeImageView: UIImageView!
    @IBOutlet var crnLabel: UILabel!
    class var identifier: String { return String.className(self) }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
