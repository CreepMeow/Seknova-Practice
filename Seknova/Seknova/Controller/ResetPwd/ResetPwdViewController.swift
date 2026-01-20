//
//  ResetPwdViewController.swift
//  Seknova-Practice
//
//  Created by imac-2627 on 2025/10/7.
//

import UIKit

class ResetPwdViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var btnSent: UIButton!
    @IBOutlet weak var txfNewPwdAgain: UITextField!
    @IBOutlet weak var txfNewPwd: UITextField!
    @IBOutlet weak var txfOldPwd: UITextField!
    @IBOutlet weak var txfEmail: UITextField!
    
    // MARK: - Variables
    weak var delegate: ResetPwdDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - UI Settings
    
    
    // MARK: - IBAction
    
    @IBAction func sentButtonTapped(_ sender: Any) {
        if validateInputs() {
                    saveUserData(email: txfEmail.text!, password: txfNewPwd.text!)
                    self.navigationController?.popToRootViewController(animated: true)
                }
    }
}
// MARK: - Extensions
extension ResetPwdViewController {
    private func saveUserData(email: String, password: String) {
        let defaults = UserDefaults.standard
        defaults.setValue(email, forKey: .userEmail)
        defaults.setValue(password, forKey: .userPassword)
        defaults.synchronize()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z]).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    private func validateInputs() -> Bool {
        guard let email = txfEmail.text, !email.isEmpty,
              let newPassword = txfNewPwd.text, !newPassword.isEmpty,
              let confirmPassword = txfNewPwdAgain.text, !confirmPassword.isEmpty else {
            showAlert(title: "錯誤", message: "請填寫所有欄位")
            return false
        }
        
        guard isValidEmail(email) else {
            showAlert(title: "錯誤", message: "請輸入有效的電子郵件地址")
            return false
        }
        
        guard isValidPassword(newPassword) else {
            showAlert(title: "錯誤", message: "密碼必須至少8個字元，且包含至少一個大寫和一個小寫字母")
            return false
        }
        
        guard newPassword == confirmPassword else {
            showAlert(title: "錯誤", message: "兩次輸入的密碼不相符")
            return false
        }
        
        return true
    }
}


// MARK: - Protocol

protocol ResetPwdDelegate: AnyObject {
    func didTappedResetPwd()
}
