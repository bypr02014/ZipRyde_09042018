//
//  PaymentSubDetailTableViewCell.swift
//  ZipRyde
//
//  Created by Ashish jha on 11/4/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit

class PaymentSubDetailTableViewCell : UITableViewCell {

    class var identifier: String { return String.className(self) }
    @IBOutlet var paymentTypeImageView: UIImageView!
    @IBOutlet var paymentTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
