//
//  ReportViewController.swift
//  Seknova
//
//  Created by imac-3282 on 2026/1/19.
//

import UIKit

class ReportViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "報表"
        view.backgroundColor = .systemBackground
        
        // 設置導航欄
        navigationItem.hidesBackButton = false
        
        // 添加一個簡單的 label 來顯示頁面內容
        let label = UILabel()
        label.text = "報表頁面"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
