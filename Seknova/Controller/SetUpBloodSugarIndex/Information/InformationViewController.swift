//
//  InformationViewController.swift
//  Seknova-Practice
//
//  Created by imac-2627 on 2025/10/16.
//

import UIKit

class InformationViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbInfo: UILabel!
    
    // MARK: - Variables
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    // MARK: - UI Settings
    func setUI(){
        
        lbTitle.text = "設定高低血糖值"
        lbInfo.text = "設定高低血糖值，系統會於血糖高於高血糖值或是血糖低於低血糖值時透過通知使用者須進一步處理。通知方式為訊息，鈴聲 (可關掉) 或電子郵件信箱"
    }
    
    // MARK: - IBAction
    
}
// MARK: - Extensions


// MARK: - Protocol
