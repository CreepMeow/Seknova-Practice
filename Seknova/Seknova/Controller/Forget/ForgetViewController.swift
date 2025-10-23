//
//  ForgetViewController.swift
//  Seknova
//
//  Created by imac-3282 on 2025/10/17.
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
        let ResetPwdVC = ResetViewController(nibName: "ResetPwdViewController", bundle: nil)
        self.navigationController?.pushViewController(ResetPwdVC, animated: true)
    }
}
// MARK: - Extensions


// MARK: - Protocol
protocol ForgetDelegate: AnyObject {
    func didTappedForget()
}
