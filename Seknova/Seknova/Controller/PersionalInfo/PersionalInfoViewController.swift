//
//  PersionalInfoViewController.swift
//  Seknova-Practice
//
//  Created by imac-2156 on 2025/10/6.
//

import UIKit

class PersionalInfoViewController: UIViewController {

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
        // 創建日期選擇器
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "zh_TW")
        datePicker.maximumDate = Date() // 不能選擇未來日期
        
        // 創建工具列
        dateToolBar = UIToolbar()
        dateToolBar.sizeToFit()
        
        let cancelBtn = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelDatePicker))
        let titleBtn = UIBarButtonItem(title: "出生日期", style: .plain, target: nil, action: nil)
        titleBtn.isEnabled = false
        let spaceBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneDatePicker))
        
        dateToolBar.setItems([cancelBtn, spaceBtn, titleBtn, spaceBtn, doneBtn], animated: false)
        
        // 創建隱藏的 textField 用於顯示日期選擇器
        dateTextField = UITextField(frame: .zero)
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = dateToolBar
        view.addSubview(dateTextField)
    }
    
    // MARK: - IBAction
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
    private func showActionSheet(title: String, options: [String], indexPath: IndexPath) {
        let alertController = UIAlertController(title: title, message: "請選擇", preferredStyle: .actionSheet)
        
        for option in options {
            let action = UIAlertAction(title: option, style: .default) { [weak self] _ in
                self?.handleOptionSelected(option: option, indexPath: indexPath)
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
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
                cell.imgvBtn.isHidden = false
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
                cell.imgvBtn.isHidden = true
                
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
                cell.imgvBtn.isHidden = false
                cell.txfValue.isHidden = true
                cell.lbValue.isHidden = true
                cell.btnValue.addTarget(self, action: #selector(showBodyInfoOptions(_:)), for: .touchUpInside)
                cell.btnValue.tag = indexPath.row
            } else {
                // 身高、體重 - 使用文字欄位輸入
                cell.txfValue.isHidden = false
                cell.btnValue.isHidden = true
                cell.imgvBtn.isHidden = true
                cell.lbValue.isHidden = true
                
                if indexPath.row == 1 { // 身高
                    cell.txfValue.keyboardType = .decimalPad
                } else if indexPath.row == 2 { // 體重
                    cell.txfValue.keyboardType = .decimalPad
                }
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
            showActionSheet(title: "性別", options: genderOptions, indexPath: indexPath)
        case 3: // 種族
            showActionSheet(title: "種族", options: raceOptions, indexPath: indexPath)
        case 4: // 飲酒
            showActionSheet(title: "飲酒", options: drinkingOptions, indexPath: indexPath)
        case 5: // 抽菸
            showActionSheet(title: "抽菸", options: smokingOptions, indexPath: indexPath)
        default:
            break
        }
    }
}

// MARK: - Protocol
