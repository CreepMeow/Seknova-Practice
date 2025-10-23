//
//  ActivatedAccountViewController.swift
//  Seknova-Practice
//
//  Created by imac-2156 on 2025/10/6
//

import UIKit

class ActivatedAccountViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var btnNext: UIButton!
    // MARK: - Variables
    weak var delegate: ActivatedAccountDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - UI Settings
    
    
    // MARK: - IBAction
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
            if let loginVC = navigationController.viewControllers.first as? LoginViewController {
                let defaults = UserDefaults.standard
                if let savedEmail = defaults.value(forKey: .userEmail) as? String,
                   let savedPassword = defaults.value(forKey: .userPassword) as? String {
                    DispatchQueue.main.async {
                        loginVC.txfUser.text = savedEmail
                        loginVC.txfPassword.text = savedPassword
                    }
                }
            }
        }
    }
}
// MARK: - Extensions


protocol ActivatedAccountDelegate: AnyObject {
    func didTappedActivatedAccount()
}
