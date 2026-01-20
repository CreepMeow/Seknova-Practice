//
//  BindPhoneViewController.swift
//  Seknova-Practice
//
//  Created by imac-2627 on 2025/10/7.
//

import UIKit

class BindPhoneViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var txfVerify: UITextField!
    @IBOutlet weak var txfPhone: UITextField!
    @IBOutlet weak var btnReturn: UIButton!
    
    // MARK: - Variables
    let maxVerifyLength = 6
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUi()
    }
    
    // MARK: - UI Settings
    func setUi(){
        txfPhone.delegate = self
        txfVerify.delegate = self

        txfPhone.keyboardType = .numberPad
        txfVerify.keyboardType = .numberPad
    }
    
    // MARK: - IBAction
    
    @IBAction func returnButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
// MARK: - Extensions
extension BindPhoneViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.isEmpty {
            return true
        }
        
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        guard allowedCharacters.isSuperset(of: characterSet) else {
            return false
        }
        
        guard let currentText = textField.text else {
            return true
        }
        
        let newLength = currentText.count + string.count - range.length

        if textField == txfVerify {
            return newLength <= maxVerifyLength
        }
        return true
    }
}

// MARK: - Protocol

