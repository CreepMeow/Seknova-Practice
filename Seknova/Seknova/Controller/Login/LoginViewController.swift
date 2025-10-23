//
//  LoginViewController.swift
//  Seknova
//
//  Created by imac-3282 on 2025/9/24.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var ForgetPasswordbtn: UIButton!
    @IBOutlet weak var Registerbtn: UIButton!
    @IBOutlet weak var Loginbtn: UIButton!
    @IBOutlet weak var FBLoginbtn: UIButton!
    @IBOutlet weak var AppleLoginbtn: UIButton!
    @IBOutlet weak var GoogleLoginbtn: UIButton!
    @IBOutlet weak var txfUser: UITextField!
    @IBOutlet weak var txfPassword: UITextField!
    // MARK: - Proprtty
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let defaults = UserDefaults.standard.value(forKey: .userEmail) as? String {
                txfUser.text = defaults
                txfPassword.text = UserDefaults.standard.value(forKey: .userPassword) as? String
            }
        }
    // MARK: - UI Setting
    func setUI() {
        navigationItem.title = "Login"
    }
    // MARK: - IBAcion
    @IBAction func btnSignUpTapped(_ sender: UIButton) {
        let SignUpVC = SignUpViewController(nibName: "SignUpViewController", bundle: nil)
        SignUpVC.delegate = self
        self.navigationController?.pushViewController(SignUpVC, animated: true)
            }
    
    @IBAction func btnForgetTapped(_ sender: Any) {
    let ForgetVC = ForgetViewController(nibName: "ForgetViewController", bundle: nil)
        ForgetVC.delegate = self
        self.navigationController?.pushViewController(ForgetVC, animated: true)

    }
    
    @IBAction func btnLoginTapped(_ sender: Any) {
         guard let account = txfUser.text, !account.isEmpty,
               let password = txfPassword.text, !password.isEmpty else {
             return
         }

         let accountKey = "account_\(account)_first_login"
         let isFirstLogin = !UserDefaults.standard.bool(forKey: accountKey)

         if isFirstLogin {
             let privateAgreeVC = PrivateAgreeViewController(nibName: "PrivateAgreeViewController", bundle: nil)
             //privateAgreeVC.userAccount = account // 傳遞帳號資訊
             privateAgreeVC.modalPresentationStyle = .fullScreen
             present(privateAgreeVC, animated: true)
         } else {
             let glycemicIndexVC = GlycemicIndexViewController()
             let navController = UINavigationController(rootViewController: glycemicIndexVC)
             navController.modalPresentationStyle = .fullScreen
             glycemicIndexVC.navigationItem.hidesBackButton = true
             present(navController, animated: true)
         }
    }

    // MARK: - Function
}
// MARK: - Extensions
extension LoginViewController: SignUpDelegate {
    func didTappedSignUp() {  // 移除參數
        print("註冊按鈕被點擊")
    }
}
extension LoginViewController: ForgetDelegate {
    func didTappedForget() {
        print("忘記密碼按鈕被點擊")
    }
}

