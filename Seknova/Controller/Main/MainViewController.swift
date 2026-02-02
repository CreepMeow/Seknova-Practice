//
//  MainViewController.swift
//  Seknova
//
//  Created by imac-3282 on 2025/12/18.
//
import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var tarbar: TarBarView!
    @IBOutlet weak var mainbiew: UIView!
    
    private var onev = HistoricalViewController()
    private var twov = BloodcorrectionViewController()
    private var threev = GlycemicIndexViewController()
    private var fourv = DailyroutineViewController()
    private var fivev = PersonalViewController()
    private var vc: [UIViewController] = []
    private(set) var nowVC: Int = BottomItems.HistoricalViewController.rawValue
    private var isMenuVisible = false // 追蹤選單狀態
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 確保包含所有頁面
        vc = [onev, twov, threev, fourv, fivev]
        updateView(nowVC)
        tarbar?.buttonTapped = { [weak self] page in
            guard let self = self else { return }
            if page != self.nowVC {
                self.pageChange(page: page)
            }
        }
        setUI()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        // 確保 navigationBar 為不透明，避免內容延伸到上方
        if let navBar = navigationController?.navigationBar {
            navBar.isTranslucent = false
            
            // 設置導航欄外觀
            if #available(iOS 13.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(red: 0.78, green: 0.12, blue: 0.23, alpha: 1) // 紅色背景
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                
                navBar.standardAppearance = appearance
                navBar.scrollEdgeAppearance = appearance
                navBar.compactAppearance = appearance
            } else {
                navBar.barTintColor = UIColor(red: 0.78, green: 0.12, blue: 0.23, alpha: 1)
                navBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            }
            
            navBar.tintColor = .white
        }
    }
    
    func setUI() {
        navigationItem.hidesBackButton = true
    }
    
    func pageChange(page: Int) {
        updateView(page)
    }
    
    // MARK: - Navigation Actions
    @objc private func menuButtonTapped() {
        print("選單按鈕被點擊")
        
        // 如果選單已經顯示，則關閉它
        if isMenuVisible {
            closeSideMenu()
        } else {
            showSideMenu()
        }
    }
    
    private func showSideMenu() {
        // 如果選單已經顯示，不要創建新的
        guard !isMenuVisible else { return }
        
        // 創建小型選單容器，完全貼齊NavigationBar
        let menuWidth: CGFloat = 120
        let menuHeight: CGFloat = 180
        
        // 計算導航欄底部位置，並向上偏移更多以確保完全貼合
        
        let menuView = UIView(frame: CGRect(
            x: 0, // 完全貼齊左邊
            y: 0, // 調整後的位置，完全貼合導航欄
            width: menuWidth,
            height: menuHeight
        ))
        menuView.backgroundColor = .white
        menuView.tag = 998 // 用於後續移除
        menuView.layer.cornerRadius = 0 // 保持方正，完全貼合
        
        // 添加邊框，讓它看起來更像導航欄的一部分
        menuView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        menuView.layer.borderWidth = 0.5
        
        // 調整陰影，讓它不會干擾貼合效果
        menuView.layer.shadowColor = UIColor.black.cgColor
        menuView.layer.shadowOpacity = 0.2
        menuView.layer.shadowOffset = CGSize(width: 1, height: 1)
        menuView.layer.shadowRadius = 3
        
        view.addSubview(menuView)
        
        // ...existing code...
        // 創建選單項目
        let menuItems = [
            ("報表", #selector(reportItemTapped)),
            ("日誌", #selector(logsItemTapped)),
            ("設定", #selector(settingsItemTapped))
        ]
        
        let itemHeight: CGFloat = menuHeight / CGFloat(menuItems.count)
        
        for (index, (title, action)) in menuItems.enumerated() {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 0, y: CGFloat(index) * itemHeight, width: menuWidth, height: itemHeight)
            button.setTitle(title, for: .normal)
            button.setTitleColor(.darkGray, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            button.backgroundColor = .clear
            
            button.addTarget(self, action: action, for: .touchUpInside)
            
            // 添加分隔線（除了最後一個）
            if index < menuItems.count - 1 {
                let separator = UIView(frame: CGRect(x: 10, y: button.frame.maxY - 1, width: menuWidth - 20, height: 0.5))
                separator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
                menuView.addSubview(separator)
            }
            
            menuView.addSubview(button)
        }
        
        // 設置初始狀態並添加動畫
        menuView.alpha = 0
        menuView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) {
            menuView.alpha = 1
            menuView.transform = .identity
        }
        
        isMenuVisible = true
    }
    
    @objc private func closeSideMenu() {
        guard let menuView = view.viewWithTag(998), isMenuVisible else { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            menuView.alpha = 0
            menuView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            menuView.removeFromSuperview()
        }
        
        isMenuVisible = false
    }
    
    @objc private func reportItemTapped() {
        closeSideMenu()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.navigateToReport()
        }
    }
    
    @objc private func logsItemTapped() {
        closeSideMenu()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.navigateToLogs()
        }
    }
    
    @objc private func settingsItemTapped() {
        closeSideMenu()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.navigateToSettings()
        }
    }
    
    // MARK: - Navigation Methods
    private func navigateToReport() {
        print("導航到報表頁面")
        let reportVC = ReportViewController(nibName: "ReportViewController", bundle: nil)
        
        if let nav = navigationController {
            nav.pushViewController(reportVC, animated: true)
        } else {
            reportVC.modalPresentationStyle = .fullScreen
            present(reportVC, animated: true, completion: nil)
        }
    }
    
    private func navigateToLogs() {
        print("導航到日誌頁面")
        let logsVC = LogsViewController(nibName: "LogsViewController", bundle: nil)
        
        if let nav = navigationController {
            nav.pushViewController(logsVC, animated: true)
        } else {
            logsVC.modalPresentationStyle = .fullScreen
            present(logsVC, animated: true, completion: nil)
        }
    }
    
    private func navigateToSettings() {
        print("導航到設定頁面")
        let settingsVC = SettingViewController(nibName: "SettingViewController", bundle: nil)
        
        if let nav = navigationController {
            nav.pushViewController(settingsVC, animated: true)
        } else {
            settingsVC.modalPresentationStyle = .fullScreen
            present(settingsVC, animated: true, completion: nil)
        }
    }
    
    @objc private func linkButtonTapped() {
        print("連結按鈕被點擊")
        checkDeviceStatusAndShowAlert()
    }
    
    // MARK: - Device Status Check
    private func checkDeviceStatusAndShowAlert() {
        // 檢查發射器和感測器的啟用狀態
        let isTransmitterEnabled = UserDefaults.standard.bool(forKey: "TransmitterEnabled")
        let isSensorEnabled = UserDefaults.standard.bool(forKey: "SensorEnabled")
        
        var title: String
        var message: String
        var shouldNavigateToSetup = false
        
        // 根據不同的狀態組合決定顯示內容和行為
        if !isTransmitterEnabled && !isSensorEnabled {
            // 發射器未啟用 ＋ 感測器未啟用
            title = "發射器未啟用"
            message = "發射器尚未啟用，請使用者啟用後才可以進一步顯示資料"
            shouldNavigateToSetup = true
            
        } else if isTransmitterEnabled && !isSensorEnabled {
            // 發射器已啟用 ＋ 感測器未啟用
            title = "感測器未啟用"
            message = "感測器尚未啟用，請使用者先行啟用後才可以顯示資料"
            shouldNavigateToSetup = true
            
        } else if !isTransmitterEnabled && isSensorEnabled {
            // 發射器未啟用 ＋ 感測器已啟用（理論上不應該出現此狀態）
            title = "設備狀態異常"
            message = "檢測到異常狀態，請重新設定設備"
            shouldNavigateToSetup = true
            
        } else {
            // 發射器已啟用 ＋ 感測器已啟用
            title = "感測器已啟用"
            message = "感測器運作正常"
            shouldNavigateToSetup = false
        }
        
        // 創建彈出視窗
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if shouldNavigateToSetup {
            // 需要跳轉到設定頁面的情況
            let setupAction = UIAlertAction(title: "前往設定", style: .default) { [weak self] _ in
                self?.navigateToPairingSetup()
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            alertController.addAction(setupAction)
            alertController.addAction(cancelAction)
            
        } else {
            // 感測器已啟用的情況，只顯示確認按鈕
            let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
            alertController.addAction(okAction)
        }
        
        // 顯示彈出視窗
        present(alertController, animated: true, completion: nil)
        
        print("設備狀態檢查完成 - 發射器: \(isTransmitterEnabled ? "已啟用" : "未啟用"), 感測器: \(isSensorEnabled ? "已啟用" : "未啟用")")
    }
    
    // MARK: - Navigation to Setup
    private func navigateToPairingSetup() {
        print("導航到配對設定頁面")
        
        // 創建 PairingViewController 實例
        let pairingVC = PairingViewController(nibName: "PairingViewController", bundle: nil)
        
        // 使用 navigationController 進行頁面跳轉
        if let nav = navigationController {
            nav.pushViewController(pairingVC, animated: true)
        } else {
            // 如果沒有 navigationController，使用 modal 方式呈現
            pairingVC.modalPresentationStyle = .fullScreen
            present(pairingVC, animated: true, completion: nil)
        }
    }
    
    private func updateView(_ index: Int) {
        // 範圍檢查，避免 out of range
        guard index >= 0 && index < vc.count else {
            print("updateView: index \(index) out of range")
            return
        }
        
        // 如果同一個 vc 已經是 child，就不重複加入，但仍更新 navigationBar
        let target = vc[index]
        if children.contains(where: { $0 === target }) {
            nowVC = index
            applyNavigationFromChild(target)
            configureNavigationForIndex(index, child: target)
            return
        }
        
        // 移除現有 child（如果有）
        if let current = children.first {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }
        
        // 加入新 child
        addChild(target)
        target.view.frame = mainbiew.bounds
        target.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainbiew.addSubview(target.view)
        target.didMove(toParent: self)
        
        // 更新 navigationBar 為該 child 的設定
        applyNavigationFromChild(target)
        configureNavigationForIndex(index, child: target)
        
        nowVC = index
    }
    
    // 把 child 的 navigationItem 反映到父 VC（MainViewController）的 navigationItem
    private func applyNavigationFromChild(_ child: UIViewController) {
        // 優先使用 child.title 或 child.navigationItem.title
        navigationItem.title = child.title ?? child.navigationItem.title
        
        // 合併左側按鈕：MainViewController 的按鈕 + 子頁面的按鈕
        var leftItems: [UIBarButtonItem] = []
        
        // 創建 MainViewController 的按鈕（ThreeLineSmall 和 link）
        if let menuImage = UIImage(named: "ThreeLineSmall") {
            let resizedMenuImage = menuImage.resized(to: CGSize(width: 20, height: 20))
            let menuItem = UIBarButtonItem(
                image: resizedMenuImage?.withRenderingMode(.alwaysTemplate),
                style: .plain,
                target: self,
                action: #selector(menuButtonTapped)
            )
            menuItem.tintColor = .white
            leftItems.append(menuItem)
        }
        
        if let linkImage = UIImage(named: "link") {
            let resizedLinkImage = linkImage.resized(to: CGSize(width: 20, height: 20))
            let linkItem = UIBarButtonItem(
                image: resizedLinkImage?.withRenderingMode(.alwaysTemplate),
                style: .plain,
                target: self,
                action: #selector(linkButtonTapped)
            )
            linkItem.tintColor = .white
            
            // 創建一個負間距的spacer來讓按鈕貼得更近
            let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            negativeSpacer.width = -10 // 負數值會讓按鈕更靠近
            
            leftItems.append(negativeSpacer)
            leftItems.append(linkItem)
        }
        
        // 如果沒有圖片，使用系統圖標作為備用
        if leftItems.count == 0 { // 檢查是否沒有添加任何按鈕
            let menuItem = UIBarButtonItem(
                image: UIImage(systemName: "line.horizontal.3"),
                style: .plain,
                target: self,
                action: #selector(menuButtonTapped)
            )
            let linkItem = UIBarButtonItem(
                image: UIImage(systemName: "link"),
                style: .plain,
                target: self,
                action: #selector(linkButtonTapped)
            )
            menuItem.tintColor = .white
            linkItem.tintColor = .white
            
            // 創建負間距的spacer讓系統圖標也貼得更近
            let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            negativeSpacer.width = -10
            
            leftItems.append(menuItem)
            leftItems.append(negativeSpacer)
            leftItems.append(linkItem)
        }
        
        // 然後添加子頁面的左側按鈕（如果有）
        if let childLeftItems = child.navigationItem.leftBarButtonItems {
            leftItems.append(contentsOf: childLeftItems)
        }
        
        // 設置合併後的左側按鈕
        navigationItem.leftBarButtonItems = leftItems
        navigationItem.rightBarButtonItems = child.navigationItem.rightBarButtonItems
        navigationItem.hidesBackButton = child.navigationItem.hidesBackButton
        
        print("導航欄設置完成 - 標題: \(navigationItem.title ?? "nil"), 左側按鈕數量: \(leftItems.count)")
    }
    
    // 根據 index 調整 nav bar
    private func configureNavigationForIndex(_ index: Int, child: UIViewController) {
        // 若是即時血糖頁面
        if index == BottomItems.GlycemicIndexViewController.rawValue {
            navigationItem.title = "即時血糖"
            // 保留子頁面的右側按鈕（圓環進度條）
            if let childRightItems = child.navigationItem.rightBarButtonItems {
                navigationItem.rightBarButtonItems = childRightItems
            } else if let childRightItem = child.navigationItem.rightBarButtonItem {
                navigationItem.rightBarButtonItem = childRightItem
            }
        }
        // 其他頁面保持子頁面的設置，左側按鈕已在 applyNavigationFromChild 中處理
    }
}

// MARK: - UIImage Extension
extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
