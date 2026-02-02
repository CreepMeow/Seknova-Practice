//
//  BindPhoneViewController.swift
//  Seknova
//
//  Created by imac-3282 on 2025/12/18.
//

import UIKit

class BindPhoneViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var btnReturn: UIButton!
    @IBOutlet weak var txfPhone: UITextField!
    @IBOutlet weak var txfVerify: UITextField!
    
    // MARK: - Property
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    // MARK: - UI Setting
    
    private func setUI() {
        title = "綁定手機"
        navigationItem.hidesBackButton = false
    }
    
    // MARK: - IBAction
    
    @IBAction func btnReturnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Function
    
}
