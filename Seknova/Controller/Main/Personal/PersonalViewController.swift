//
//  PersonalViewController.swift
//  Seknova
//
//  Created by imac-3282 on 2025/12/18.
//

import UIKit

class PersonalViewController: UIViewController {
  
    // MARK: - IBOutlet
    
    @IBOutlet weak var Perstbv: UITableView!
    
    // MARK: - Property
    
    // 個人資訊數據模型
    private var personalInfoData: [PersonalInfoModel] = []
    
    // 追蹤是否從 MainViewController 跳轉過來
    var isFromMainViewController: Bool = false
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupTableView()
        loadPersonalData()
    }
    
    // MARK: - UI Setting
    
    func setUI() {
        navigationItem.hidesBackButton = true
        title = "個人資訊"
        
        // 只有從 MainViewController 跳轉過來才顯示更新按鈕
        if isFromMainViewController {
            setupUpdateButton()
        }
    }
    
    private func setupUpdateButton() {
        let updateButton = UIBarButtonItem(
            title: "更新",
            style: .plain,
            target: self,
            action: #selector(updateButtonTapped)
        )
        updateButton.tintColor = .white
        
        // 設置字體大小和樣式
        updateButton.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 17, weight: .medium),
            .foregroundColor: UIColor.white
        ], for: .normal)
        
        navigationItem.rightBarButtonItem = updateButton
        
        print("更新按鈕已添加到導航欄右側")
    }
    
    @objc private func updateButtonTapped() {
        showConfirmAlert(title: "更新資料", message: "確定要將修改內容更新至本地資料庫嗎？") { [weak self] in
            self?.updateLocalDatabase()
        }
    }
    
    private func setupTableView() {
        // 註冊 cell
        let nib = UINib(nibName: "PersionalInfoTableViewCell", bundle: nil)
        Perstbv.register(nib, forCellReuseIdentifier: "PersionalInfoTableViewCell")
        
        // 設定 delegate 和 dataSource
        Perstbv.delegate = self
        Perstbv.dataSource = self
        
        // 設定行高和外觀
        Perstbv.rowHeight = 50
        Perstbv.separatorStyle = .singleLine
        Perstbv.backgroundColor = UIColor.systemGroupedBackground
    }
    
    // MARK: - Data Loading
    
    private func loadPersonalData() {
        personalInfoData = [
            // 個人資訊區塊
            PersonalInfoModel(section: "個人資訊", title: "名", value: getUserData("firstName") ?? "a", type: .textField, action: .editName),
            PersonalInfoModel(section: "個人資訊", title: "姓", value: getUserData("lastName") ?? "a", type: .textField, action: .editLastName),
            PersonalInfoModel(section: "個人資訊", title: "出生日期", value: getUserData("birthDate") ?? "2023-09-10", type: .button, action: .cancelSensor),
            PersonalInfoModel(section: "個人資訊", title: "電子信箱", value: getUserData("email") ?? "123456@gmail.com", type: .textField, action: .editEmail),
            PersonalInfoModel(section: "個人資訊", title: "手機號碼", value: getUserData("phone") ?? "+886967111111", type: .button, action: .bindPhone),
            PersonalInfoModel(section: "個人資訊", title: "地址", value: getUserData("address") ?? "點擊進行編輯", type: .textField, action: .editAddress),
            
            // 身體數值區塊
            PersonalInfoModel(section: "身體數值", title: "性別", value: getUserData("gender") ?? "生理男", type: .selector, action: .selectGender),
            PersonalInfoModel(section: "身體數值", title: "身高", value: getUserData("height") ?? "1", type: .textField, action: .editHeight),
            PersonalInfoModel(section: "身體數值", title: "體重", value: getUserData("weight") ?? "1", type: .textField, action: .editWeight),
            PersonalInfoModel(section: "身體數值", title: "種族", value: getUserData("race") ?? "亞洲", type: .selector, action: .selectRace),
            PersonalInfoModel(section: "身體數值", title: "飲酒", value: getUserData("drinking") ?? "無", type: .selector, action: .selectDrinking),
            PersonalInfoModel(section: "身體數值", title: "抽菸", value: getUserData("smoking") ?? "無", type: .selector, action: .selectSmoking),
            
            // 系統設定區塊
            PersonalInfoModel(section: "系統設定", title: "發射器裝置", value: "配對 / 取消發射器", type: .button, action: .deviceTransmitter),
            PersonalInfoModel(section: "系統設定", title: "感測器裝置", value: "啟用 / 取消感應器", type: .button, action: .deviceSensor),
            PersonalInfoModel(section: "系統設定", title: "修改密碼", value: "", type: .button, action: .resetPassword),
            PersonalInfoModel(section: "系統設定", title: "登出", value: "", type: .button, action: .logout)
        ]
    }
    
    private func getUserData(_ key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    // MARK: - Function
    
    private func handleCellAction(_ action: PersonalInfoAction, at indexPath: IndexPath) {
        switch action {
        case .editName:
            showTextEditAlert(title: "修改姓名", currentValue: personalInfoData[indexPath.row].value) { [weak self] newValue in
                self?.updateUserData("firstName", value: newValue)
                self?.personalInfoData[indexPath.row].value = newValue
                self?.Perstbv.reloadRows(at: [indexPath], with: .none)
            }
            
        case .editLastName:
            showTextEditAlert(title: "修改姓氏", currentValue: personalInfoData[indexPath.row].value) { [weak self] newValue in
                self?.updateUserData("lastName", value: newValue)
                self?.personalInfoData[indexPath.row].value = newValue
                self?.Perstbv.reloadRows(at: [indexPath], with: .none)
            }
            
        case .cancelSensor:
            showConfirmAlert(title: "出生日期", message: "點擊修改出生日期") { [weak self] in
                // 處理出生日期修改
            }
            
        case .bindPhone:
            let bindPhoneVC = BindPhoneViewController(nibName: "BindPhoneViewController", bundle: nil)
            navigationController?.pushViewController(bindPhoneVC, animated: true)
            
        case .editAddress:
            showTextEditAlert(title: "修改地址", currentValue: personalInfoData[indexPath.row].value) { [weak self] newValue in
                self?.updateUserData("address", value: newValue)
                self?.personalInfoData[indexPath.row].value = newValue
                self?.Perstbv.reloadRows(at: [indexPath], with: .none)
            }
            
        case .editEmail:
            showTextEditAlert(title: "修改電子信箱", currentValue: personalInfoData[indexPath.row].value) { [weak self] newValue in
                self?.updateUserData("email", value: newValue)
                self?.personalInfoData[indexPath.row].value = newValue
                self?.Perstbv.reloadRows(at: [indexPath], with: .none)
            }
            
        case .selectGender:
            showSelectionAlert(title: "選擇性別", options: ["生理男", "生理女"], currentValue: personalInfoData[indexPath.row].value) { [weak self] selectedValue in
                self?.updateUserData("gender", value: selectedValue)
                self?.personalInfoData[indexPath.row].value = selectedValue
                self?.Perstbv.reloadRows(at: [indexPath], with: .none)
            }
            
        case .editHeight:
            showTextEditAlert(title: "修改身高 (cm)", currentValue: personalInfoData[indexPath.row].value, keyboardType: .numberPad) { [weak self] newValue in
                self?.updateUserData("height", value: newValue)
                self?.personalInfoData[indexPath.row].value = newValue
                self?.Perstbv.reloadRows(at: [indexPath], with: .none)
            }
            
        case .editWeight:
            showTextEditAlert(title: "修改體重 (kg)", currentValue: personalInfoData[indexPath.row].value, keyboardType: .numberPad) { [weak self] newValue in
                self?.updateUserData("weight", value: newValue)
                self?.personalInfoData[indexPath.row].value = newValue
                self?.Perstbv.reloadRows(at: [indexPath], with: .none)
            }
            
        case .selectRace:
            showSelectionAlert(title: "選擇種族", options: ["亞洲", "非洲", "高加索", "拉丁", "其他"], currentValue: personalInfoData[indexPath.row].value) { [weak self] selectedValue in
                self?.updateUserData("race", value: selectedValue)
                self?.personalInfoData[indexPath.row].value = selectedValue
                self?.Perstbv.reloadRows(at: [indexPath], with: .none)
            }
            
        case .selectDrinking:
            showSelectionAlert(title: "飲酒習慣", options: ["無", "偶爾", "頻繁", "每天"], currentValue: personalInfoData[indexPath.row].value) { [weak self] selectedValue in
                self?.updateUserData("drinking", value: selectedValue)
                self?.personalInfoData[indexPath.row].value = selectedValue
                self?.Perstbv.reloadRows(at: [indexPath], with: .none)
            }
            
        case .selectSmoking:
            showSelectionAlert(title: "抽菸習慣", options: ["有", "無"], currentValue: personalInfoData[indexPath.row].value) { [weak self] selectedValue in
                self?.updateUserData("smoking", value: selectedValue)
                self?.personalInfoData[indexPath.row].value = selectedValue
                self?.Perstbv.reloadRows(at: [indexPath], with: .none)
            }
            
        case .deviceTransmitter:
            showConfirmAlert(title: "發射器裝置", message: "前往配對發射器頁面？") { [weak self] in
                let pairingVC = PairingViewController(nibName: "PairingViewController", bundle: nil)
                self?.navigationController?.pushViewController(pairingVC, animated: true)
            }
            
        case .deviceSensor:
            showConfirmAlert(title: "感測器裝置", message: "前往啟用感測器頁面？") { [weak self] in
                let sensorVC = ScanningSensorViewController(nibName: "ScanningSensorViewController", bundle: nil)
                self?.navigationController?.pushViewController(sensorVC, animated: true)
            }
            
        case .resetPassword:
            let resetPwdVC = ResetPwdViewController(nibName: "ResetPwdViewController", bundle: nil)
            navigationController?.pushViewController(resetPwdVC, animated: true)
            
        case .logout:
            showConfirmAlert(title: "登出", message: "確定要登出嗎？所有個人資料將被清除。") { [weak self] in
                self?.performLogout()
            }
            
        case .updateData:
            // 這個案例不應該被調用，因為更新按鈕現在在 navigationBar 中
            // 但為了保持 switch 完整性，我們保留它
            showConfirmAlert(title: "更新資料", message: "確定要將修改內容更新至本地資料庫嗎？") { [weak self] in
                self?.updateLocalDatabase()
            }
        }
    }
    
    private func showTextEditAlert(title: String, currentValue: String, keyboardType: UIKeyboardType = .default, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = currentValue
            textField.keyboardType = keyboardType
        }
        
        let confirmAction = UIAlertAction(title: "確認", style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                completion(text)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showSelectionAlert(title: String, options: [String], currentValue: String, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        for option in options {
            let action = UIAlertAction(title: option, style: .default) { _ in
                completion(option)
            }
            if option == currentValue {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alert.addAction(cancelAction)
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        
        present(alert, animated: true)
    }
    
    private func showConfirmAlert(title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "確認", style: .default) { _ in
            completion()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func updateUserData(_ key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    private func performLogout() {
        let userDefaults = UserDefaults.standard
        let keysToRemove = ["firstName", "lastName", "birthDate", "email", "phone", "address", 
                           "gender", "height", "weight", "race", "drinking", "smoking", 
                           "DeviceID", "SensorEnabled", "isLoggedIn"]
        
        for key in keysToRemove {
            userDefaults.removeObject(forKey: key)
        }
        
        let alert = UIAlertController(title: "登出成功", message: "個人資料已清除", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func updateLocalDatabase() {
        let alert = UIAlertController(title: "更新成功", message: "資料已更新至本地資料庫", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Extensions

extension PersonalViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // 個人資訊、身體數值、系統設定
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName = getSectionName(for: section)
        return personalInfoData.filter { $0.section == sectionName }.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getSectionName(for: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersionalInfoTableViewCell", for: indexPath) as! PersionalInfoTableViewCell
        
        let sectionName = getSectionName(for: indexPath.section)
        let sectionData = personalInfoData.filter { $0.section == sectionName }
        let data = sectionData[indexPath.row]
        
        // 使用新的簡化配置方法，會自動處理右對齊和紅色文字
        var cellType = ""
        switch data.type {
        case .textField:
            cellType = "textField"
        case .selector:
            cellType = "selector"
        case .button:
            // 系統設定區塊的修改密碼和登出使用 button_simple，其他使用 button_label
            if data.action == .resetPassword || data.action == .logout {
                cellType = "button_simple"
            } else {
                cellType = "button_label"
            }
        }
        
        cell.configure(title: data.title, value: data.value, cellType: cellType)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sectionName = getSectionName(for: indexPath.section)
        let sectionData = personalInfoData.filter { $0.section == sectionName }
        let data = sectionData[indexPath.row]
        
        if let originalIndex = personalInfoData.firstIndex(where: { $0.title == data.title && $0.section == data.section }) {
            handleCellAction(data.action, at: IndexPath(row: originalIndex, section: 0))
        }
    }
    
    private func getSectionName(for section: Int) -> String {
        let sections = ["個人資訊", "身體數值", "系統設定"]
        return sections[section]
    }
}

// MARK: - Data Models
struct PersonalInfoModel {
    let section: String
    let title: String
    var value: String
    let type: PersonalInfoCellType
    let action: PersonalInfoAction
}

enum PersonalInfoCellType {
    case textField
    case selector
    case button
}

enum PersonalInfoAction {
    case editName
    case editLastName
    case cancelSensor
    case bindPhone
    case editAddress
    case editEmail
    case selectGender
    case editHeight
    case editWeight
    case selectRace
    case selectDrinking
    case selectSmoking
    case deviceTransmitter
    case deviceSensor
    case resetPassword
    case logout
    case updateData
}
