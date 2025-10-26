//
//  PersionalInfoTableViewCell.swift
//  Seknova-Practice
//
//  Created by imac-2156 on 2025/10/8.
//

import UIKit

class PersionalInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lbValue: UILabel!
    @IBOutlet weak var btnValue: UIButton!
    @IBOutlet weak var imgvBtn: UIImageView!
    @IBOutlet weak var txfValue: UITextField!
    @IBOutlet weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setUI(){
        txfValue.isHidden = true
        btnValue.isHidden = true
        imgvBtn.isHidden = true
        lbValue.isHidden = true
        txfValue.text = ""
        lbValue.text = ""
    }
}


