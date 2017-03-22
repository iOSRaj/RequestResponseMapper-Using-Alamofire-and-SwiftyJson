//
//  AppInfoCell.swift
//  NewFAS
//
//  Created by tcs on 3/22/16.
//  Copyright © 2016 Raj. All rights reserved.
//

import UIKit

class AppInfoCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
