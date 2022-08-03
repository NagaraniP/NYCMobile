//
//  CustomTableViewCell.swift
//  NYCMobile
//
//  Created by raniraja on 8/3/22.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
