//
//  TarBarlten.swift
//  Deletage
//
//  Updated
//

import UIKit

class TarBarlten: UIView {

    // MARK: - IBOutlet
    @IBOutlet weak var TabBarImag: UIImageView!
    @IBOutlet weak var TabBarbut: UIButton!
    @IBOutlet weak var TabBarLabel: UILabel!

    weak var delegate: TarBarItemDelegate?
    var stringTag: Int?
    var buttonTapped: ((Int) -> ())? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        addview()
        // 設定初始狀態為未選中
        setSelected(false)
    }

    func setint(tag: Int, text: String) {
        TabBarbut.tag = tag
        TabBarLabel.text = text
        stringTag = tag
    }
    
    /// 設置按鈕的選中狀態
    /// - Parameter selected: true 為選中，false 為未選中
    func setSelected(_ selected: Bool) {
        DispatchQueue.main.async {
            if selected {
                // 選中狀態：改變文字和圖片顏色為紅色
                self.TabBarLabel.textColor = UIColor(red: 0.69, green: 0.16, blue: 0.17, alpha: 1)
                self.TabBarImag.tintColor = UIColor(red: 0.69, green: 0.16, blue: 0.17, alpha: 1)
            } else {
                // 未選中狀態：使用黑色
                self.TabBarLabel.textColor = UIColor.black
                self.TabBarImag.tintColor = UIColor.black
            }
        }
    }

    @IBAction func didYapBtn(_ sender: Any) {
        delegate?.didTapButtn(tag: TabBarbut.tag)
        print("Button with tag \(TabBarbut.tag)")
        buttonTapped?(TabBarbut.tag)
    }
}

fileprivate extension TarBarlten {
    func addview() {
        if let loadview = Bundle(for: TarBarlten.self).loadNibNamed("TarBarlten", owner: self, options: nil)?.first as? UIView {
            loadview.frame = bounds
            loadview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(loadview)
        }
    }
}

// MARK: - Protocol
protocol TarBarItemDelegate: AnyObject {
    func didTapButtn(tag: Int)
}
