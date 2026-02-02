//
//  SettingViewController.swift
//  Seknova
//
//  Created by imac-3282 on 2026/1/19.
//

import UIKit

// MARK: - 設定項目類型
enum SettingItemType {
    case navigation  // 可跳轉的項目
    case toggle      // 開關項目
    case syncButton  // 同步按鈕項目
    case info        // 資訊顯示項目
}

// MARK: - 設定項目模型
struct SettingItem {
    let title: String
    let type: SettingItemType
    var value: String?
    var isOn: Bool?
    let action: (() -> Void)?
}

class SettingViewController: UIViewController {
    
    // MARK: - IBOutlet
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .systemGroupedBackground
        return table
    }()
    
    // MARK: - Property
    private var settingItems: [SettingItem] = []
    
    // 韌體版本（自訂）
    private var firmwareVersion: String {
        get {
            return UserDefaults.standard.string(forKey: "FirmwareVersion") ?? "09/05 02:16:35"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "FirmwareVersion")
        }
    }
    
    // 韌體版號（自訂）
    private var firmwareBuildNumber: String {
        get {
            return UserDefaults.standard.string(forKey: "FirmwareBuildNumber") ?? "1.24.9"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "FirmwareBuildNumber")
        }
    }
    
    // App 版本（自訂）
    private var appVersion: String {
        get {
            return UserDefaults.standard.string(forKey: "AppVersion") ?? "00.00.61"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "AppVersion")
        }
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupTableView()
        loadSettingItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 重新載入數據以更新開關狀態
        tableView.reloadData()
    }
    
    // MARK: - UI Setting
    private func setUI() {
        title = "設定"
        view.backgroundColor = .systemGroupedBackground
        
        // 設定返回按鈕
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
        tableView.rowHeight = 55
    }
    
    private func loadSettingItems() {
        settingItems = [
            SettingItem(title: "警示設定", type: .navigation, value: nil, isOn: nil, action: { [weak self] in
                self?.navigateToWarningSettings()
            }),
            SettingItem(title: "單位切換(mmol/L)", type: .toggle, value: nil, isOn: getUserDefaultBool("UnitSwitch"), action: nil),
            SettingItem(title: "超出高低血糖警示", type: .toggle, value: nil, isOn: getUserDefaultBool("BloodSugarAlert"), action: nil),
            SettingItem(title: "資料同步", type: .syncButton, value: nil, isOn: nil, action: { [weak self] in
                self?.showSyncAnimation()
            }),
            SettingItem(title: "暖機狀態", type: .info, value: getUserDefaultString("WarmUpStatus") ?? "Off", isOn: nil, action: nil),
            SettingItem(title: "韌體版本", type: .info, value: self.firmwareVersion, isOn: nil, action: { [weak self] in
                self?.editFirmwareVersion()
            }),
            SettingItem(title: "韌體版本", type: .info, value: self.firmwareBuildNumber, isOn: nil, action: { [weak self] in
                self?.editFirmwareBuildNumber()
            }),
            SettingItem(title: "App 版本", type: .info, value: self.appVersion, isOn: nil, action: { [weak self] in
                self?.editAppVersion()
            })
        ]
    }
    
    // MARK: - Navigation
    private func navigateToWarningSettings() {
        let warningVC = WarningSetViewController(nibName: "WarningSetViewController", bundle: nil)
        navigationController?.pushViewController(warningVC, animated: true)
    }
    
    // MARK: - Actions
    private func showSyncAnimation() {
        // 顯示同步動畫（無實際功能）
        let alert = UIAlertController(title: "資料同步", message: "此功能暫無作用", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Edit Functions
    private func editFirmwareVersion() {
        showEditAlert(title: "編輯韌體版本", currentValue: firmwareVersion) { [weak self] newValue in
            self?.firmwareVersion = newValue
            self?.loadSettingItems()
            self?.tableView.reloadData()
        }
    }
    
    private func editFirmwareBuildNumber() {
        showEditAlert(title: "編輯韌體版號", currentValue: firmwareBuildNumber) { [weak self] newValue in
            self?.firmwareBuildNumber = newValue
            self?.loadSettingItems()
            self?.tableView.reloadData()
        }
    }
    
    private func editAppVersion() {
        showEditAlert(title: "編輯 App 版本", currentValue: appVersion) { [weak self] newValue in
            self?.appVersion = newValue
            self?.loadSettingItems()
            self?.tableView.reloadData()
        }
    }
    
    private func showEditAlert(title: String, currentValue: String, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: "請輸入新的值", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = currentValue
            textField.placeholder = "請輸入"
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "確定", style: .default) { _ in
            if let newValue = alert.textFields?.first?.text, !newValue.isEmpty {
                completion(newValue)
            }
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Helper Functions
    private func getUserDefaultBool(_ key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    private func getUserDefaultString(_ key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    private func setUserDefaultBool(_ key: String, value: Bool) {
        UserDefaults.standard.set(value, forKey: key)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        let item = settingItems[indexPath.row]
        
        // 清除舊的 accessory view
        cell.accessoryView = nil
        cell.accessoryType = .none
        
        // 設定標題
        cell.textLabel?.text = item.title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.selectionStyle = .none
        
        // 根據類型設定 cell
        switch item.type {
        case .navigation:
            cell.accessoryType = .disclosureIndicator
            cell.detailTextLabel?.text = nil
            
        case .toggle:
            let switchControl = UISwitch()
            switchControl.isOn = item.isOn ?? false
            switchControl.tag = indexPath.row
            switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchControl
            
        case .syncButton:
            // 創建同步按鈕圖標
            let syncButton = UIButton(type: .custom)
            syncButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            
            // 使用系統圖標或自訂圖標
            if let syncImage = UIImage(systemName: "arrow.triangle.2.circlepath") {
                syncButton.setImage(syncImage, for: .normal)
                syncButton.tintColor = .systemGray
            }
            
            syncButton.tag = indexPath.row
            syncButton.addTarget(self, action: #selector(syncButtonTapped(_:)), for: .touchUpInside)
            cell.accessoryView = syncButton
            
        case .info:
            cell.detailTextLabel?.text = item.value
            cell.detailTextLabel?.textColor = .systemGray
            // 可點擊編輯的項目（韌體版本和 App 版本）
            if item.title.contains("版本") || item.title == "App 版本" {
                cell.selectionStyle = .default
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = settingItems[indexPath.row]
        item.action?()
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        let index = sender.tag
        let item = settingItems[index]
        
        // 儲存開關狀態
        if item.title == "單位切換(mmol/L)" {
            setUserDefaultBool("UnitSwitch", value: sender.isOn)
            print("單位切換: \(sender.isOn ? "開啟" : "關閉")")
        } else if item.title == "超出高低血糖警示" {
            setUserDefaultBool("BloodSugarAlert", value: sender.isOn)
            print("血糖警示: \(sender.isOn ? "開啟" : "關閉")")
        }
    }
    
    @objc private func syncButtonTapped(_ sender: UIButton) {
        // 顯示旋轉動畫
        UIView.animate(withDuration: 0.5, animations: {
            sender.transform = CGAffineTransform(rotationAngle: .pi)
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                sender.transform = .identity
            }
        }
        
        let index = sender.tag
        let item = settingItems[index]
        item.action?()
    }
    
    @objc private func syncImageTapped(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else { return }
        
        // 顯示旋轉動畫
        UIView.animate(withDuration: 0.5, animations: {
            imageView.transform = CGAffineTransform(rotationAngle: .pi)
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                imageView.transform = .identity
            }
        }
        
        let index = imageView.tag
        let item = settingItems[index]
        item.action?()
    }
}

