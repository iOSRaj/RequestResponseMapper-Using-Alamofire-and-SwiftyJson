//
//  AppInfoCell.swift
//  NewFAS
//
//  Created by tcs on 3/22/16.
//  Copyright © 2016 Raj. All rights reserved.
//

import UIKit

class UserInfoCell: UITableViewCell {

    @IBOutlet var name: UILabel!
    @IBOutlet var email: UILabel!
    @IBOutlet weak var avatar: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatar.layer.cornerRadius = 30
        self.avatar.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        name.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
