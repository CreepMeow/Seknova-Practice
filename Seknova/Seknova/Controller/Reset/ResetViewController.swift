//
//  ResetViewController.swift
//  Seknova
//
//  Created by imac-3282 on 2025/10/17.
//

import UIKit

class ResetViewController: UIViewController, UITextFieldDelegate {

    // MARK: - IBOutlet
    
    @IBOutlet weak var newPasswordTextFed: UITextField!
    @IBOutlet weak var oldPasswordTextFed: UITextField!
    @IBOutlet weak var EmailFed: UITextField!
    @IBOutlet weak var confirmPasswordTextFed: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    
    // MARK: - Property
    // 用來控制是否可以送出
    private var isFormValid: Bool {
        // 舊密碼可以為任意字串（非必填檢查視需求），但這裡要求新密碼與確認密碼符合條件
        guard let newPwd = newPasswordTextFed.text, let confirm = confirmPasswordTextFed.text else { return false }
        return Self.isValidNewPassword(newPwd) && newPwd == confirm
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupActions()
    }
    
    // MARK: - UI Setting
    
    func setUI() {
        // 設定樣式
        navigationItem.title = ""
        view.backgroundColor = .systemBackground
        submitBtn.layer.cornerRadius = 22
        submitBtn.layer.borderWidth = 2
        submitBtn.layer.borderColor = UIColor.systemRed.cgColor
        submitBtn.setTitleColor(UIColor.systemRed, for: .normal)
        submitBtn.setTitleColor(.lightGray, for: .disabled)
        submitBtn.backgroundColor = .white
        submitBtn.isEnabled = false
        
        oldPasswordTextFed.isSecureTextEntry = true
        newPasswordTextFed.isSecureTextEntry = true
        confirmPasswordTextFed.isSecureTextEntry = true
        
        oldPasswordTextFed.delegate = self
        newPasswordTextFed.delegate = self
        confirmPasswordTextFed.delegate = self
        
        // 若使用 Storyboard/XIB 可在 Interface Builder 設置 placeholder
        oldPasswordTextFed.placeholder = "舊密碼"
        newPasswordTextFed.placeholder = "請輸入新密碼（至少8位，含大小寫字母）"
        confirmPasswordTextFed.placeholder = "再次輸入新密碼"
    }
    
    func setupActions() {
        // 改用 editingChanged 監聽內容變化
        oldPasswordTextFed.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        newPasswordTextFed.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        confirmPasswordTextFed.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        
        // Tap to dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        // 每次編輯都更新按鈕狀態
        submitBtn.isEnabled = isFormValid
        updateSubmitAppearance()
    }
    
    private func updateSubmitAppearance() {
        if submitBtn.isEnabled {
            submitBtn.layer.borderColor = UIColor.systemRed.cgColor
            submitBtn.setTitleColor(UIColor.systemRed, for: .normal)
            submitBtn.alpha = 1.0
        } else {
            submitBtn.layer.borderColor = UIColor.lightGray.cgColor
            submitBtn.setTitleColor(UIColor.lightGray, for: .normal)
            submitBtn.alpha = 0.6
        }
    }
    
    // MARK: - IBActions
    @IBAction func submitTapped(_ sender: UIButton) {
        view.endEditing(true)
        guard let newPwd = newPasswordTextFed.text, let confirm = confirmPasswordTextFed.text else { return }
        guard Self.isValidNewPassword(newPwd) else {
            showAlert(title: "密碼格式錯誤", message: "新密碼需至少8位，且包含大小寫字母。")
            return
        }
        guard newPwd == confirm else {
            showAlert(title: "密碼不一致", message: "新密碼與確認密碼不相符，請重新輸入。")
            return
        }
        
        // 這裡可呼叫後端 API 更改密碼，成功後回到登入頁
        // 模擬成功
        navigateToLogin()
    }
    
    // MARK: - Function
    private func navigateToLogin() {
        // 建立 LoginViewController，並以此為新的 navigation stack，避免左上角出現返回
        let loginVC = LoginViewController()
        loginVC.navigationItem.hidesBackButton = true
        if let nav = navigationController {
            nav.setViewControllers([loginVC], animated: true)
        } else {
            // 若沒有 navigation controller，直接 present 並在 loginVC hide back button
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true, completion: nil)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    // 密碼驗證：至少8位，包含大小寫字母
    static func isValidNewPassword(_ pwd: String) -> Bool {
        let pattern = "^(?=.*[a-z])(?=.*[A-Z]).{8,}$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let range = NSRange(location: 0, length: pwd.utf16.count)
        return regex.firstMatch(in: pwd, options: [], range: range) != nil
    }
}

// MARK: - Extensions
extension ForgetViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

