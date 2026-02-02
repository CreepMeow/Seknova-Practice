//
//  ReportViewController.swift
//  Seknova
//
//  Created by imac-3282 on 2026/1/19.
//

import UIKit

class ReportViewController: UIViewController {

    @IBOutlet weak var ReportControl: UISegmentedControl!
    @IBOutlet weak var ReTimeControl: UISegmentedControl!
    
    // 日期範圍顯示 label
    private let dateRangeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.darkGray
        label.backgroundColor = UIColor(white: 0.95, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var selectedDays: Int = 7 // 預設選擇 7 天
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDateRangeLabel()
        
        // 設定 ReportControl 的大小和樣式
        ReportControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ReportControl.heightAnchor.constraint(equalToConstant: 80), // 增加高度
            ReportControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 80),
            ReportControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -80)
        ])
        
        // 設定 ReTimeControl 的大小和樣式
        ReTimeControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ReTimeControl.heightAnchor.constraint(equalToConstant: 50), // 增加高度
            ReTimeControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 80),
            ReTimeControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -80)
        ])
        
        // 添加 Segmented Control 的動作監聽
        ReTimeControl.addTarget(self, action: #selector(timeRangeChanged(_:)), for: .valueChanged)
        
        // 初始化日期範圍顯示
        updateDateRangeLabel()
    }
    
    private func setupUI() {
        title = "報表"
        view.backgroundColor = .systemBackground
        
        // 設置導航欄
        navigationItem.hidesBackButton = false
        
        // 設定返回按鈕的文字為「返回」，保留系統的返回箭頭
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
        
        // 設定返回按鈕顏色為白色
        navigationController?.navigationBar.tintColor = .white
    }
    
    // MARK: - 設置日期範圍 Label
    private func setupDateRangeLabel() {
        view.addSubview(dateRangeLabel)
        
        // 設置約束，讓 label 顯示在 navigationBar 下方
        NSLayoutConstraint.activate([
            dateRangeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dateRangeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dateRangeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dateRangeLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - 更新日期範圍顯示
    private func updateDateRangeLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        // 計算開始日期（當前日期 - 選擇的天數）
        guard let startDate = calendar.date(byAdding: .day, value: -selectedDays, to: currentDate) else {
            return
        }
        
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: currentDate)
        
        // 設置日期範圍文字
        dateRangeLabel.text = "\(startDateString) - \(endDateString)"
        
        print("📅 日期範圍已更新: \(dateRangeLabel.text ?? "")")
    }
    
    // MARK: - Segmented Control 動作處理
    @objc private func timeRangeChanged(_ sender: UISegmentedControl) {
        // 根據選擇的索引更新天數
        switch sender.selectedSegmentIndex {
        case 0:
            selectedDays = 7
        case 1:
            selectedDays = 14
        case 2:
            selectedDays = 30
        default:
            selectedDays = 7
        }
        
        print("⏰ 選擇時間範圍: \(selectedDays) 天")
        
        // 更新日期範圍顯示
        updateDateRangeLabel()
    }
    
}
