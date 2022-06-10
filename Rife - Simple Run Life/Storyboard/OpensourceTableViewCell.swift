//
//  OpensourceTableViewCell.swift
//  Rife - Simple Run Life
//
//  Created by 배경원 on 2021/11/29.
//

import UIKit

class OpensourceTableViewCell: UITableViewCell {

    @IBOutlet var makerLabel: UILabel!
    @IBOutlet var nameLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
