//
//  SetUpBloodSugarIndexViewController.swift
//  Seknova-Practice
//
//  Created by imac-2627 on 2025/10/15.
//

import UIKit

// MARK: - Protocol
protocol SetUpBloodSugarIndexDelegate: AnyObject {
    func didCompleteSetup()
}

class SetUpBloodSugarIndexViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var pkvHighSugar: UIPickerView!
    @IBOutlet weak var pkvLowSugar: UIPickerView!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    // MARK: - Variables
    weak var delegate: SetUpBloodSugarIndexDelegate?
    var bloodSugarHighData: [String] = []
    var bloodSugarLowData: [String] = []
    var selectedHighSugar: Int = 200
    var selectedLowSugar: Int = 70
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    // MARK: - UI Settings
    func setUI() {
        pkvHighSugar.delegate = self
        pkvHighSugar.dataSource = self
        pkvLowSugar.delegate = self
        pkvLowSugar.dataSource = self
        
        // 初始化高血糖數據（150-250）
        for i in 150...250 {
            bloodSugarHighData.append("\(i)")
        }
        
        // 初始化低血糖數據（65-75）
        for i in 65...75 {
            bloodSugarLowData.append("\(i)")
        }
        
        // 設定預設選擇值
        if let highIndex = bloodSugarHighData.firstIndex(of: "\(selectedHighSugar)") {
            pkvHighSugar.selectRow(highIndex, inComponent: 0, animated: false)
        }
        
        if let lowIndex = bloodSugarLowData.firstIndex(of: "\(selectedLowSugar)") {
            pkvLowSugar.selectRow(lowIndex, inComponent: 0, animated: false)
        }
    }
    
    // MARK: - IBAction
    @IBAction func btnMoreTapped(_ sender: UIButton) {
        // 創建 InformationViewController 實例
        let informationVC = InformationViewController(nibName: "InformationViewController", bundle: nil)
        
        // 設定為 popover 呈現樣式
        informationVC.modalPresentationStyle = .popover
        
        // 設定 popover 呈現樣式，讓箭頭指向 btnMore 按鈕
        if let popover = informationVC.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            // 設定 delegate 以支援 iPhone 上的 popover 效果
            popover.delegate = self
            
            // 設定 popover 的尺寸
            informationVC.preferredContentSize = CGSize(width: 300, height: 200)
            
            // 添加除錯訊息
            print("Popover 設定完成 - sourceView: \(sender), sourceRect: \(sender.bounds)")
        }
        
        // 呈現 InformationViewController
        present(informationVC, animated: true) {
            print("InformationViewController 已呈現")
        }
    }
    
    @IBAction func btnSaveTapped(_ sender: UIButton) {
        // 驗證血糖值範圍
        if selectedHighSugar <= selectedLowSugar {
            showAlert(title: "無效的血糖值範圍", message: "請確保高血糖值大於低血糖值")
            return
        }
        
        // 儲存血糖設定到 UserDefaults
        UserDefaults.standard.set(selectedHighSugar, forKey: "HighBloodSugar")
        UserDefaults.standard.set(selectedLowSugar, forKey: "LowBloodSugar")
        UserDefaults.standard.synchronize()
        
        print("血糖設定已儲存到 UserDefaults - 高血糖: \(selectedHighSugar), 低血糖: \(selectedLowSugar)")
        
        // 通知代理設定已完成
        delegate?.didCompleteSetup()
        
        // 跳轉到 TransmitterViewController
        let transmitterVC = TransmitterViewController(nibName: "TransmitterViewController", bundle: nil)
        self.navigationController?.pushViewController(transmitterVC, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

// MARK: - Extensions
extension SetUpBloodSugarIndexViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pkvHighSugar {
            return bloodSugarHighData.count
        } else {
            return bloodSugarLowData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pkvHighSugar {
            return bloodSugarHighData[row]
        } else {
            return bloodSugarLowData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pkvHighSugar {
            selectedHighSugar = Int(bloodSugarHighData[row]) ?? 200
        } else {
            selectedLowSugar = Int(bloodSugarLowData[row]) ?? 70
        }
    }
}

extension SetUpBloodSugarIndexViewController: SetUpBloodSugarIndexDelegate {
    func didCompleteSetup() {
        // 這個方法是空的，因為這個類別本身就是設定頁面
        // 通常這個協議是用來通知其他類別設定已完成
    }
}

extension SetUpBloodSugarIndexViewController: UIPopoverPresentationControllerDelegate {
    // 這個方法是關鍵 - 讓 iPhone 也能顯示 popover 效果
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // 返回 .none 讓 iPhone 也能保持 popover 樣式，而不是退化為全螢幕模態
        return .none
    }
    
    // 可選：當 popover 被點擊外部區域時的處理
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    
    // 可選：popover 被 dismiss 時的回調
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        print("Popover 已被關閉")
    }
}
