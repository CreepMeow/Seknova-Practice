//
//  WarningSetViewController.swift
//  Seknova
//
//  Created by imac-3282 on 2026/2/2.
//

import UIKit

class WarningSetViewController: UIViewController {
    
    // MARK: - IBOutlet
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .systemGroupedBackground
        return table
    }()
    
    // MARK: - Property
    private var warningItems: [String] = [
        "高血糖警示值",
        "低血糖警示值",
        "警示音量",
        "震動提醒"
    ]
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupTableView()
    }
    
    // MARK: - UI Setting
    private func setUI() {
        title = "警示設定"
        view.backgroundColor = .systemGroupedBackground
        
        // 設定返回按鈕
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WarningCell")
        tableView.rowHeight = 55
    }
    
    // MARK: - Function
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension WarningSetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return warningItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WarningCell", for: indexPath)
        cell.textLabel?.text = warningItems[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alert = UIAlertController(title: warningItems[indexPath.row], message: "此功能尚未實現", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
}


