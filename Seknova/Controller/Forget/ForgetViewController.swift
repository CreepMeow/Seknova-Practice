//
//  ForgetViewController.swift
//  Seknova-Practice
//
//  Created by imac-2627 on 2025/10/1.
//

import UIKit

class ForgetViewController: UIViewController {

    // MARK: - IBOutlet
    
    
    @IBOutlet weak var btnSent: UIButton!
    
    // MARK: - Variables
    weak var delegate: ForgetDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - UI Settings
    
    
    // MARK: - IBAction
    
    @IBAction func sentButtonTapped(_ sender: Any) {
        let ResetPwdVC = ResetPwdViewController(nibName: "ResetPwdViewController", bundle: nil)
        self.navigationController?.pushViewController(ResetPwdVC, animated: true)
    }
}
// MARK: - Extensions


// MARK: - Protocol
protocol ForgetDelegate: AnyObject {
    func didTappedForget()
}
