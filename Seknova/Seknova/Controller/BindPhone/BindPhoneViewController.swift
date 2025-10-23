//
//  BindPhoneViewController.swift
//  Seknova
//
//  Created by imac-3282 on 2025/10/14.
//

import UIKit

class BindPhoneViewController: UIViewController, UITextFieldDelegate {
    // MARK: - IBOutlet
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var getCodeButton: UIButton!
    @IBOutlet weak var inputCodeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        phoneTextField.delegate = self
        codeTextField.delegate = self
    }
    // MARK: - UI Setting
    func setUI() {
        navigationItem.title = "綁定手機"
        phoneTextField.keyboardType = .numberPad
        codeTextField.keyboardType = .numberPad
        phoneTextField.placeholder = "請輸入您的電話號碼"
        codeTextField.placeholder = "請輸入您的驗證碼"
        getCodeButton.setTitle("獲取驗證碼", for: .normal)
        inputCodeButton.setTitle("輸入驗證碼", for: .normal)
        backButton.setTitle("返回", for: .normal)
    }
    // MARK: - IBAction
    @IBAction func getCodeTapped(_ sender: UIButton) {
        // 這裡可加上發送驗證碼的邏輯
    }
    @IBAction func inputCodeTapped(_ sender: UIButton) {
        // 這裡可加上驗證碼驗證的邏輯
    }
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneTextField {
            // 只允許數字
            let allowed = CharacterSet.decimalDigits
            return string.rangeOfCharacter(from: allowed.inverted) == nil
        } else if textField == codeTextField {
            // 只允許一個數字
            let allowed = CharacterSet.decimalDigits
            let current = (textField.text ?? "") as NSString
            let newString = current.replacingCharacters(in: range, with: string)
            return newString.count <= 1 && string.rangeOfCharacter(from: allowed.inverted) == nil
        }
        return true
    }
}
