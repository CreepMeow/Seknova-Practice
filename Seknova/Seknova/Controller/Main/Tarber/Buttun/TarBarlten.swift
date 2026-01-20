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
    }

    func setint(tag: Int, text: String) {
        TabBarbut.tag = tag
        TabBarLabel.text = text
        stringTag = tag
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
