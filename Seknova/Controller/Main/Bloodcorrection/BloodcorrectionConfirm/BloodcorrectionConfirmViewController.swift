//
//  BloodcorrectionConfirmViewController.swift
//  Seknova
//
//  Created by imac-3282 on 2025/12/24.
//

import UIKit

class BloodcorrectionConfirmViewController: UIViewController {

        // MARK: - IBOutlet
    @IBOutlet weak var confirmnumlb: UILabel!
    @IBOutlet weak var confirmtimelb: UILabel!
    @IBOutlet weak var confirmbtn: UIButton!
    @IBOutlet weak var correctbtn: UIButton!
    
    // MARK: - Property
        var correctedValue: Int?

        // MARK: - LifeCycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupCurrentTime()
            
            if let v = correctedValue {
                confirmnumlb.text = "\(v)"
            } else {
                confirmnumlb.text = "-"
            }
        }
        
        // MARK: - UI Setting
        
        private func setupCurrentTime() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "a HH:mm"
            dateFormatter.locale = Locale(identifier: "zh_TW")
            
            let currentTime = dateFormatter.string(from: Date())
            confirmtimelb.text = currentTime
            
            print("當前時間設置為: \(currentTime)")
        }
        
        // MARK: - IBAction
        @IBAction func confirmButtonTapped(_ sender: UIButton) {
            print("確認按鈕被點擊 - 跳轉到 MainViewController 並顯示 GlycemicIndexViewController")
            
            // 創建 MainViewController
            let mainVC = MainViewController(nibName: "MainViewController", bundle: nil)
            
            if let nav = navigationController {
                // 跳轉到 MainViewController，並清除堆疊中的其他頁面
                nav.setViewControllers([mainVC], animated: true)
                
                // 等待 MainViewController 載入完成後切換到 GlycemicIndexViewController
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    mainVC.pageChange(page: 2) // GlycemicIndexViewController 對應索引 2
                }
            } else {
                // 如果沒有 navigation controller，使用 modal present
                mainVC.modalPresentationStyle = .fullScreen
                present(mainVC, animated: true) {
                    // present 完成後切換到指定頁面
                    mainVC.pageChange(page: 2)
                }
            }
        }
        
        @IBAction func correctButtonTapped(_ sender: UIButton) {
            print("修正按鈕被點擊 - 跳轉到 MainViewController 並顯示 BloodcorrectionViewController")
            
            // 創建 MainViewController
            let mainVC = MainViewController(nibName: "MainViewController", bundle: nil)
            
            if let nav = navigationController {
                // 跳轉到 MainViewController，並清除堆疊中的其他頁面
                nav.setViewControllers([mainVC], animated: true)
                
                // 等待 MainViewController 載入完成後切換到 BloodcorrectionViewController
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    mainVC.pageChange(page: 1) // BloodcorrectionViewController 對應索引 1
                }
            } else {
                // 如果沒有 navigation controller，使用 modal present
                mainVC.modalPresentationStyle = .fullScreen
                present(mainVC, animated: true) {
                    // present 完成後切換到指定頁面
                    mainVC.pageChange(page: 1)
                }
            }
        }
        
        // MARK: - Function
        
    }
    // MARK: - Extexsions
