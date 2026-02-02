//
//  ActivatedAccountViewController.swift
//  Seknova-Practice
//
//  Created by imac-2627 on 2025/10/7.
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
                        loginVC.txfUserId.text = savedEmail
                        loginVC.txfPassword.text = savedPassword
                    }
                }
            }
        }
    }
}
// MARK: - Extensions


// MARK: - Protocol
protocol ActivatedAccountDelegate: AnyObject {
    func didTappedActivatedAccount()
}
