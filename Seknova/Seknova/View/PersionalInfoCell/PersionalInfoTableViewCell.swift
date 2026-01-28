//
//  PersionalInfoTableViewCell.swift
//  Seknova-Practice
//
//  Created by imac-2627 on 2025/10/8.
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
    }
    
    private func setUI(){
        // 隱藏所有元件
        txfValue.isHidden = true
        btnValue.isHidden = true
        imgvBtn.isHidden = true
        lbValue.isHidden = true
        
        // 清空內容
        txfValue.text = ""
        lbValue.text = ""
        
        // 設定所有文字右對齊
        txfValue.textAlignment = .right
        lbValue.textAlignment = .right
        btnValue.contentHorizontalAlignment = .right
        
        // 設定所有文字顏色為紅色
        let redColor = UIColor(red: 0.69, green: 0.16, blue: 0.17, alpha: 1)
        txfValue.textColor = redColor
        lbValue.textColor = redColor
        btnValue.setTitleColor(redColor, for: .normal)
        
        // 其他設定
        txfValue.borderStyle = .none
        txfValue.isUserInteractionEnabled = false
        btnValue.backgroundColor = UIColor.clear
    }
    
    // 配置 cell 顯示類型的方法
    func configure(title: String, value: String, cellType: String) {
        lbTitle.text = title
        
        // 根據類型配置顯示元件
        switch cellType {
        case "textField":
            showTextField(with: value)
        case "selector":
            showLabelOnly(with: value)
        case "button_simple":
            showButton(with: title)
        case "button_label":
            showLabel(with: value)
        default:
            showTextField(with: value)
        }
    }
    
    private func showTextField(with value: String) {
        hideAllComponents()
        txfValue.isHidden = false
        txfValue.text = value
        txfValue.placeholder = "點擊進行編輯"
        txfValue.textAlignment = .right
        txfValue.textColor = UIColor(red: 0.69, green: 0.16, blue: 0.17, alpha: 1)
    }
    
    private func showLabelOnly(with value: String) {
        hideAllComponents()
        lbValue.isHidden = false
        lbValue.text = value
        lbValue.textAlignment = .right
        lbValue.textColor = UIColor(red: 0.69, green: 0.16, blue: 0.17, alpha: 1)
    }
    
    private func showButton(with title: String) {
        hideAllComponents()
        btnValue.isHidden = false
        btnValue.setTitle(title, for: .normal)
        btnValue.contentHorizontalAlignment = .right
        btnValue.setTitleColor(UIColor(red: 0.69, green: 0.16, blue: 0.17, alpha: 1), for: .normal)
    }
    
    private func showLabel(with value: String) {
        hideAllComponents()
        lbValue.isHidden = false
        lbValue.text = value
        lbValue.textAlignment = .right
        lbValue.textColor = UIColor(red: 0.69, green: 0.16, blue: 0.17, alpha: 1)
    }
    
    private func hideAllComponents() {
        txfValue.isHidden = true
        btnValue.isHidden = true
        lbValue.isHidden = true
        imgvBtn.isHidden = true
    }
}