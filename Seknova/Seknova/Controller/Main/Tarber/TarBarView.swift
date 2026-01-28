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
    
    /// 設置選中的索引，更新按鈕狀態
    /// - Parameter index: 要選中的按鈕索引 (0-4)
    func setSelectedIndex(_ index: Int) {
        // 重置所有按鈕狀態
        resetAllButtons()
        
        // 設置選中的按鈕狀態
        switch index {
        case 0:
            btnOne?.setSelected(true)
        case 1:
            btnTwo?.setSelected(true)
        case 2:
            btnThree?.setSelected(true)
        case 3:
            btnFour?.setSelected(true)
        case 4:
            btnFive?.setSelected(true)
        default:
            break
        }
    }
    
    /// 重置所有按鈕為未選中狀態
    private func resetAllButtons() {
        btnOne?.setSelected(false)
        btnTwo?.setSelected(false)
        btnThree?.setSelected(false)
        btnFour?.setSelected(false)
        btnFive?.setSelected(false)
    }
}

extension TarBarView: TarBarItemDelegate {
    func didTapButtn(tag: Int) {
        guard tag >= 0 && tag < item.count else { return }
        
        // 立即更新選中狀態
        setSelectedIndex(tag)
        
        // 回調給 MainViewController
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

        // 安全綁定 delegate 與文字、圖示
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

        // 設定圖示
        btnOne?.TabBarImag.image = UIImage(named: "history")?.withRenderingMode(.alwaysTemplate)
        btnTwo?.TabBarImag.image = UIImage(named: "blood-1")?.withRenderingMode(.alwaysTemplate)
        btnThree?.TabBarImag.image = UIImage(named: "trend")?.withRenderingMode(.alwaysTemplate)
        btnFour?.TabBarImag.image = UIImage(named: "calendar-1")?.withRenderingMode(.alwaysTemplate)
        btnFive?.TabBarImag.image = UIImage(named: "user")?.withRenderingMode(.alwaysTemplate)
        
        // 初始化所有按鈕為未選中狀態
        resetAllButtons()
    }
}