//
//  SignUpViewController.swift
//  Seknova-Practice
//
//  Created by imac-2627 on 2025/10/1.
//

import UIKit

class SignUpViewController: UIViewController {

    // MARK: - IBOutlet
    
    
    @IBOutlet weak var txfPwdAgain: UITextField!
    @IBOutlet weak var txfPwd: UITextField!
    @IBOutlet weak var txfEmail: UITextField!
    @IBOutlet weak var btnCountry: UIButton!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var btnTerms: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var lbCountry: UILabel!
    
    // MARK: - Variables
    weak var delegate: SignUpDelegate?
    var isChecked = false
    let countries = [ "Taiwan(台灣)", "China(中國)", "America(美國)", "Japan(日本)" ]
    var selectedCountry: String?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUi()
    }
    
    // MARK: - UI Settings
    func setUi() {
        btnCheck.setTitle("", for: .normal)
        btnCheck.layer.cornerRadius = 13
        btnCheck.layer.borderWidth = 1
        btnCheck.layer.borderColor = UIColor.gray.cgColor
        btnCheck.backgroundColor = .clear
        
        
        btnTerms.setTitle("條件與條款", for: .normal)
        btnTerms.setTitleColor(Color.signUpBlue, for: .normal)
        
        lbCountry.text = "Taiwan(台灣)"
        
        navigationItem.title = "Register"
    }
        
    
    // MARK: - IBAction
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        isChecked.toggle()
        if isChecked {
            btnCheck.backgroundColor = .systemBlue
        } else {
            btnCheck.backgroundColor = .clear
        }
    }
    
    @IBAction func termButtonTapped(_ sender: Any) {
        let PrivateAgreeVC = PrivateAgreeViewController(nibName: "PrivateAgreeViewController", bundle: nil)
        self.navigationController?.pushViewController(PrivateAgreeVC, animated: true)
    }
    @IBAction func countryButtonTapped(_ sender: Any) {
        showCountryPicker()
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        if validateInputs() {
             let ActivatedAccountVC = ActivatedAccountViewController(nibName: "ActivatedAccountViewController", bundle: nil)
             self.navigationController?.pushViewController(ActivatedAccountVC, animated: true)
         }

    }
    
    
}
// MARK: - Extensions
extension SignUpViewController: PrivateAgreeDelegate {
    func didTappedPrivateAgree() {
        print("隱私條款被點擊")
    }
}

extension SignUpViewController: ActivatedAccountDelegate {
    func didTappedActivatedAccount() {
        print("啟動帳號被點擊")
    }
}
extension SignUpViewController {
    func showCountryPicker() {
        let alert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: alert.view.bounds.width - 20, height: 200))
        picker.dataSource = self
        picker.delegate = self
        alert.view.addSubview(picker)
        alert.addAction(UIAlertAction(title: "完成", style: .default, handler: { _ in
            if let country = self.selectedCountry {
                self.lbCountry.text = country
            }
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
}
    
extension SignUpViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        countries.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        countries[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCountry = countries[row]
    }
}

extension SignUpViewController {
    
    private func saveUserData(email: String, password: String) {
        let defaults = UserDefaults.standard
        defaults.setValue(email, forKey: .userEmail)
        defaults.setValue(password, forKey: .userPassword)
        defaults.setValue(lbCountry.text, forKey: .userCountry)
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
              let password = txfPwd.text, !password.isEmpty,
              let passwordAgain = txfPwdAgain.text, !passwordAgain.isEmpty else {
            showAlert(title: "錯誤", message: "請填寫所有欄位")
            return false
        }
        

        guard isValidEmail(email) else {
            showAlert(title: "錯誤", message: "請輸入有效的電子郵件地址")
            return false
        }
        

        guard isValidPassword(password) else {
            showAlert(title: "錯誤", message: "密碼必須至少8個字元，且包含至少一個大寫和一個小寫字母")
            return false
        }
        
  
        guard password == passwordAgain else {
            showAlert(title: "錯誤", message: "兩次輸入的密碼不相符")
            return false
        }
        saveUserData(email: email, password: password)
        return true
    }
}

extension UserDefaults {
    enum Keys: String {
        case userEmail
        case userPassword
        case userCountry
    }
    
    func setValue(_ value: Any?, forKey key: Keys) {
        setValue(value, forKey: key.rawValue)
    }
    
    func value(forKey key: Keys) -> Any? {
        return value(forKey: key.rawValue)
    }
}




// MARK: - Protocol
protocol SignUpDelegate: AnyObject {
    func didTappedSignUp()
}
