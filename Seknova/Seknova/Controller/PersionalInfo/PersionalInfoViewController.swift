//
//  PersionalInfoViewController.swift
//  Seknova-Practice
//
//  Created by imac-2627 on 2025/10/7.
//

import UIKit
import RealmSwift

class PersionalInfoViewController: UIViewController, UITextFieldDelegate {

    // MARK: - IBOutlet
    
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var tbvValue: UITableView!
    
    // MARK: - Variables
    private let sections = ["個人資訊", "身體數值"]
    private let persionalInfoItems = ["名", "姓", "出生日期", "電子信箱", "手機號碼", "地址"]
    private let bodyInfoItems = ["性別", "身高", "體重", "種族", "飲酒", "抽菸"]
    private var datePicker: UIDatePicker!
    private var dateToolBar: UIToolbar!
    private var selectedCell: PersionalInfoTableViewCell?
    private var dateTextField: UITextField! // 持久化 textField
    
    // 選項資料
    private let genderOptions = ["生理男", "生理女"]
    private let raceOptions = ["亞洲", "非洲", "高加索", "拉丁", "其他"]
    private let smokingOptions = ["有", "無"]
    private let drinkingOptions = ["無", "偶爾", "頻繁", "每天"]
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupTableView()
        setupDatePicker()
    }
    
    // MARK: - UI Settings
    func setUI() {
        navigationItem.hidesBackButton = true
        title = "Persional Information"
    }
    
    private func setupTableView() {
        tbvValue.delegate = self
        tbvValue.dataSource = self
        tbvValue.register(UINib(nibName: "PersionalInfoTableViewCell", bundle: nil),
                         forCellReuseIdentifier: "PersionalInfoTableViewCell")
    }
    
    private func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "zh_TW")
        datePicker.maximumDate = Date() // 不能選擇未來日期
        
        // 創建工具列
        dateToolBar = UIToolbar()
        dateToolBar.sizeToFit()
        
        let cancelBtn = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelDatePicker))
        cancelBtn.tintColor = UIColor.black
        
        let titleBtn = UIBarButtonItem(title: "出生日期", style: .plain, target: nil, action: nil)
        titleBtn.tintColor = UIColor.black

        
        let spaceBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneBtn = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneDatePicker))
        doneBtn.tintColor = UIColor.black
        
        dateToolBar.setItems([cancelBtn, spaceBtn, titleBtn, spaceBtn, doneBtn], animated: false)
        
        // 創建隱藏的 textField 用於顯示日期選擇器
        dateTextField = UITextField(frame: .zero)
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = dateToolBar
        view.addSubview(dateTextField)
    }
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - IBAction
    @IBAction func btnNextTapped(_ sender: UIButton) {
        // 檢查所有必填欄位
        let personalSection = 0
        let bodySection = 1
        let personalCount = persionalInfoItems.count
        let bodyCount = bodyInfoItems.count
        for section in 0..<sections.count {
            let rowCount = section == 0 ? personalCount : bodyCount
            for row in 0..<rowCount {
                let indexPath = IndexPath(row: row, section: section)
                guard let cell = tbvValue.cellForRow(at: indexPath) as? PersionalInfoTableViewCell else { continue }
                // 地址(0,5)與手機號碼(0,4)非必填
                if section == 0 && (row == 4 || row == 5) { continue }
                if section == 0 {
                    // 個人資訊區段
                    if row == 2 { // 出生日期
                        if cell.lbValue.text?.isEmpty ?? true {
                            showAlert(title: "提醒", message: "請填寫出生日期")
                            return
                        }
                    } else {
                        if cell.txfValue.text?.isEmpty ?? true {
                            showAlert(title: "提醒", message: "請填寫\(persionalInfoItems[row])")
                            return
                        }
                    }
                } else {
                    // 身體數值區段
                    if row == 0 || row == 3 || row == 4 || row == 5 {
                        // 性別、種族、飲酒、抽菸
                        if cell.lbValue.text?.isEmpty ?? true {
                            showAlert(title: "提醒", message: "請選擇\(bodyInfoItems[row])")
                            return
                        }
                    } else {
                        // 身高、體重
                        if cell.txfValue.text?.isEmpty ?? true {
                            showAlert(title: "提醒", message: "請填寫\(bodyInfoItems[row])")
                            return
                        }
                        // 檢查是否為整數
                        if Int(cell.txfValue.text ?? "") == nil {
                            showAlert(title: "提醒", message: "請輸入正確的\(bodyInfoItems[row]) (整數)")
                            return
                        }
                    }
                }
            }
        }
        // 所有必填欄位皆有填寫，可進行下一步
        saveUserInfoToRealm()
        let AudiovisualTeachingVC = AudiovisualTeachingViewController(nibName: "AudiovisualTeachingViewController", bundle: nil)
        self.navigationController?.pushViewController(AudiovisualTeachingVC, animated: true)
        
    }

    // 儲存資料進 Realm
    private func saveUserInfoToRealm() {
        let userInfo = UserInformation()
        // 個人資訊
        for row in 0..<persionalInfoItems.count {
            let indexPath = IndexPath(row: row, section: 0)
            guard let cell = tbvValue.cellForRow(at: indexPath) as? PersionalInfoTableViewCell else { continue }
            switch row {
            case 0:
                userInfo.firstName = cell.txfValue.text ?? ""
            case 1:
                userInfo.lastName = cell.txfValue.text ?? ""
            case 2:
                userInfo.birthday = cell.lbValue.text ?? ""
            case 3:
                userInfo.email = cell.txfValue.text ?? ""
            case 4:
                userInfo.phone = cell.txfValue.text ?? ""
            case 5:
                userInfo.address = cell.txfValue.text ?? ""
            default:
                break
            }
        }
        // 身體數值
        for row in 0..<bodyInfoItems.count {
            let indexPath = IndexPath(row: row, section: 1)
            guard let cell = tbvValue.cellForRow(at: indexPath) as? PersionalInfoTableViewCell else { continue }
            switch row {
            case 0:
                userInfo.gender = cell.lbValue.text ?? ""
            case 1:
                userInfo.height = Int(cell.txfValue.text ?? "0") ?? 0
            case 2:
                userInfo.weight = Int(cell.txfValue.text ?? "0") ?? 0
            case 3:
                userInfo.race = cell.lbValue.text ?? ""
            case 4:
                userInfo.liquor = cell.lbValue.text ?? ""
            case 5:
                userInfo.smoke = (cell.lbValue.text == "有")
            default:
                break
            }
        }
        // userId 產生方式可依需求調整
        userInfo.userId = UUID().uuidString
        // 寫入 Realm
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(userInfo, update: .modified)
            }
            print("資料已儲存")
        } catch {
            print("儲存失敗: \(error.localizedDescription)")
        }
    }

    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 只針對身高與體重欄位做整數限制
        guard let indexPath = indexPathForTextField(textField) else { return true }
        if indexPath.section == 1 && (indexPath.row == 1 || indexPath.row == 2) {
            // 僅允許輸入數字
            let allowed = CharacterSet.decimalDigits
            if string.rangeOfCharacter(from: allowed.inverted) != nil {
                return false
            }
        }
        return true
    }
    // 取得 textField 對應的 indexPath
    private func indexPathForTextField(_ textField: UITextField) -> IndexPath? {
        let point = textField.convert(CGPoint.zero, to: tbvValue)
        return tbvValue.indexPathForRow(at: point)
    }
    
    @objc private func cancelDatePicker() {
        dateTextField.resignFirstResponder()
    }
    
    @objc private func doneDatePicker() {
        if let cell = selectedCell {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日"
            cell.lbValue.text = formatter.string(from: datePicker.date)
            cell.lbValue.isHidden = false
            cell.btnValue.isHidden = true
        }
        dateTextField.resignFirstResponder()
    }
    
    // MARK: - Action Sheet Methods
    private func showActionSheet(title: String?, options: [String], indexPath: IndexPath) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        for option in options {
            let action = UIAlertAction(title: option, style: .default) { [weak self] _ in
                self?.handleOptionSelected(option: option, indexPath: indexPath)
            }
            action.setValue(Color.mainRed, forKey: "titleTextColor")
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        cancelAction.setValue(Color.mainRed, forKey: "titleTextColor")
        alertController.addAction(cancelAction)
        
        // 為 iPad 設定 popover
        if let popoverController = alertController.popoverPresentationController {
            if let cell = tbvValue.cellForRow(at: indexPath) as? PersionalInfoTableViewCell {
                popoverController.sourceView = cell.btnValue
                popoverController.sourceRect = cell.btnValue.bounds
            }
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func handleOptionSelected(option: String, indexPath: IndexPath) {
        guard let cell = tbvValue.cellForRow(at: indexPath) as? PersionalInfoTableViewCell else {
            return
        }
        
        cell.lbValue.text = option
        cell.lbValue.isHidden = false
        cell.btnValue.isHidden = true  // 隱藏按鈕，顯示選擇的文字
        //cell.imgvBtn.isHidden = true   // 確保倒三角形隱藏
    }
    
}
// MARK: - Extensions
extension PersionalInfoViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? persionalInfoItems.count : bodyInfoItems.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersionalInfoTableViewCell", for: indexPath) as! PersionalInfoTableViewCell
        
        if indexPath.section == 0 {
            // 個人資訊區段
            cell.lbTitle.text = persionalInfoItems[indexPath.row]
            
            if indexPath.row == 2 { // 出生日期
                //cell.imgvBtn.isHidden = false
                cell.lbValue.isHidden = false
                cell.lbValue.text = cell.lbValue.text?.isEmpty ?? true ? "" : cell.lbValue.text
                cell.btnValue.isHidden = false
                cell.btnValue.addTarget(self, action: #selector(showDatePicker(_:)), for: .touchUpInside)
                cell.btnValue.tag = indexPath.row
                cell.txfValue.isHidden = true
            } else {
                // 其他個人資訊欄位
                cell.txfValue.isHidden = false
                cell.lbValue.isHidden = true
                cell.btnValue.isHidden = true
                //cell.imgvBtn.isHidden = true
                
                if indexPath.row == 3 { // 電子信箱
                    cell.txfValue.keyboardType = .emailAddress
                    cell.txfValue.placeholder = ""
                } else if indexPath.row == 4 { // 手機號碼
                    cell.txfValue.keyboardType = .phonePad
                } else {
                    cell.txfValue.keyboardType = .default
                }
            }
        } else {
            // 身體數值區段
            cell.lbTitle.text = bodyInfoItems[indexPath.row]
            
            if indexPath.row == 0 || indexPath.row >= 3 {
                // 性別、種族、飲酒、抽菸 - 使用按鈕選擇
                cell.btnValue.isHidden = false
                //cell.imgvBtn.isHidden = false
                cell.txfValue.isHidden = true
                cell.lbValue.isHidden = true
                cell.btnValue.addTarget(self, action: #selector(showBodyInfoOptions(_:)), for: .touchUpInside)
                cell.btnValue.tag = indexPath.row
            } else {
                // 身高、體重 - 使用文字欄位輸入
                cell.txfValue.isHidden = false
                cell.btnValue.isHidden = true
                //cell.imgvBtn.isHidden = true
                cell.lbValue.isHidden = true
                
                if indexPath.row == 1 { // 身高
                    cell.txfValue.keyboardType = .decimalPad
                } else if indexPath.row == 2 { // 體重
                    cell.txfValue.keyboardType = .decimalPad
                }
                cell.txfValue.delegate = self
            }
        }
        
        return cell
    }
    
    @objc private func showDatePicker(_ sender: UIButton) {
        if let cell = tbvValue.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? PersionalInfoTableViewCell {
            selectedCell = cell
            dateTextField.becomeFirstResponder()
        }
    }
    
    @objc private func showBodyInfoOptions(_ sender: UIButton) {
        let row = sender.tag
        let indexPath = IndexPath(row: row, section: 1)
        
        switch row {
        case 0: // 性別
            showActionSheet(title: nil, options: genderOptions, indexPath: indexPath)
        case 3: // 種族
            showActionSheet(title: nil, options: raceOptions, indexPath: indexPath)
        case 4: // 飲酒
            showActionSheet(title: nil, options: drinkingOptions, indexPath: indexPath)
        case 5: // 抽菸
            showActionSheet(title: nil, options: smokingOptions, indexPath: indexPath)
        default:
            break
        }
    }
}

// MARK: - Protocol
