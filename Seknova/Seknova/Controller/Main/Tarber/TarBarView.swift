//
//  TarBarView.swift
//  Deletage
//
//  Updated
//

import UIKit

enum BottomItems: Int, CaseIterable {
    case HistoricalViewController = 0
    case BloodcorrectionViewController
    case GlycemicIndexViewController
    case DailyroutineViewController
    case PersonalViewController

    var title: String {
        switch self {
        case .HistoricalViewController:
            return NSLocalizedString("HistoricalViewController", comment: "")
        case .BloodcorrectionViewController:
            return NSLocalizedString("BloodcorrectionViewController", comment: "")
        case .GlycemicIndexViewController:
            return NSLocalizedString("GlycemicIndexViewController", comment: "")
        case .DailyroutineViewController:
            return NSLocalizedString("DailyroutineViewController", comment: "")
        case .PersonalViewController:
            return NSLocalizedString("PersonalViewController", comment: "")
        }
    }
}

class TarBarView: UIView {

    @IBOutlet weak var btnOne: TarBarlten!
    @IBOutlet weak var btnTwo: TarBarlten!
    @IBOutlet weak var btnThree: TarBarlten!
    @IBOutlet weak var btnFour: TarBarlten!
    @IBOutlet weak var btnFive: TarBarlten!

    var buttonTapped: ((Int) -> ())? = nil
    let item = BottomItems.allCases

    override func awakeFromNib() {
        super.awakeFromNib()
        addview()
    }
}

extension TarBarView: TarBarItemDelegate {
    func didTapButtn(tag: Int) {
        guard tag >= 0 && tag < item.count else { return }
        buttonTapped?(item[tag].rawValue)
        print("Button tapped with tag \(tag)")
    }
}

fileprivate extension TarBarView {
    func addview() {
        if let loadview = Bundle(for: TarBarView.self).loadNibNamed("TarBarView", owner: self, options: nil)?.first as? UIView {
            loadview.frame = bounds
            loadview.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            // 加一條頂部線
            let topLine = UIView(frame: CGRect(x: 0, y: 0, width: loadview.bounds.width, height: 1.0))
            topLine.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
            topLine.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
            loadview.addSubview(topLine)

            addSubview(loadview)
        }

        // 安全綁定 delegate 與文字、圖示（請把圖檔加入資源，名稱可改）
        btnOne?.delegate = self
        btnTwo?.delegate = self
        btnThree?.delegate = self
        btnFour?.delegate = self
        btnFive?.delegate = self

        btnOne?.setint(tag: 0, text: "歷史紀錄")
        btnTwo?.setint(tag: 1, text: "血糖校正")
        btnThree?.setint(tag: 2, text: "即時血糖")
        btnFour?.setint(tag: 3, text: "生活作息")
        btnFive?.setint(tag: 4, text: "個人資訊")

        // 範例圖示名稱，請在 Assets.xcassets 新增對應檔案並視需要更改名稱
        btnOne?.TabBarImag.image = UIImage(named: "history")
        btnTwo?.TabBarImag.image = UIImage(named: "blood-1")
        btnThree?.TabBarImag.image = UIImage(named: "trend")
        btnFour?.TabBarImag.image = UIImage(named: "calendar-1")
        btnFive?.TabBarImag.image = UIImage(named: "user")
    }
}
