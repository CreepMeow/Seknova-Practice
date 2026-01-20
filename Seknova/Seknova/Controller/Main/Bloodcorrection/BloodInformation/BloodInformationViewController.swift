//
//  BloodInformationViewController.swift
//  Seknova
//
//  Created by imac-3282 on 2025/12/24.
//

import UIKit

class BloodInformationViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var lbBloodInfo: UILabel!
    
    // MARK: - Variables
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    // MARK: - UI Settings
    func setUI(){
        
        lbBloodInfo.text = "系統暖機完後須進行第一次血糖校正，請透過任證的血糖機量測血糖值，並將量測的血糖值輸入在血糖校正的欄位。"
    }
    
    // MARK: - IBAction
    
}
// MARK: - Extensions


// MARK: - Protocol
