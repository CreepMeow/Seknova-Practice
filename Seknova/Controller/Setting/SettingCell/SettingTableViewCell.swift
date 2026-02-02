//
//  SettingTableViewCell.swift
//  Seknova
//
//  Created by imac-3282 on 2026/2/2.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    @IBOutlet weak var SetTitl: UILabel!
    @IBOutlet weak var SetSwitch: UISwitch!
    @IBOutlet weak var Setreload: UIImageView!
    @IBOutlet weak var SetArrow: UIImageView!
    @IBOutlet weak var SetName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
