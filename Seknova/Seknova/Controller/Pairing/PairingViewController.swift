//
//  PairingViewController.swift
//  Seknova
//
//  Created by imac-2627 on 2025/12/3.
//

import UIKit

class PairingViewController: UIViewController {

    // MARK: - IBOutlet

    @IBOutlet weak var lbCNTitle: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var imgvBLE: UIImageView!
    @IBOutlet weak var imgvPhone: UIImageView!
    @IBOutlet weak var imgvDot: UIImageView!
    @IBOutlet weak var imgvDevice: UIImageView!
    @IBOutlet weak var imgvCorrect: UIImageView!
    @IBOutlet weak var btnPair: UIButton!
    @IBOutlet weak var btnCancel: UIButton!

    // MARK: - Variables
    weak var delegate: PairingDelegate?

    // 新增：表示 correct 圖是否已顯示
    private var isCorrectShown: Bool = false
    // 新增：當要前往 LoadingViewController 時會設為 true，回來時觸發倒數
    private var willPresentLoading: Bool = false
    // 新增：排程倒數的 work item，可在需要時取消
    private var countdownWorkItem: DispatchWorkItem?

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("=== PairingVC: viewDidLoad 開始 ===")
        print("PairingVC: delegate = \(String(describing: delegate))")
        
        setUI()
        setInitialUIState()
        
        print("PairingVC: viewDidLoad 完成")
        // 移除：不在 viewDidLoad 就執行 loading 動畫
        // startLoadingAnimation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("=== PairingVC: viewWillAppear 開始 ===")
        print("PairingVC: willPresentLoading = \(willPresentLoading)")

        // 如果是從 Loading 回來（willPresentLoading 為 true），直接顯示 correct 圖案
        if willPresentLoading {
            willPresentLoading = false // 只觸發一次
            print("PairingVC: returned from LoadingViewController, directly showing correct image")
            showCorrectAndHideOthers() // 直接顯示 correct，跳過 loading 動畫
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 離開頁面時取消任何尚未執行的倒數工作
        countdownWorkItem?.cancel()
        countdownWorkItem = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("=== PairingVC: viewDidAppear 開始 ===")
        print("PairingVC: isCorrectShown = \(isCorrectShown)")
        
        // 只有在 correct 還沒顯示時才設置按鈕，避免在顯示 correct 後重新顯示按鈕
        if !isCorrectShown {
            // 在視圖完全顯示後重新設置按鈕，確保可以點擊
            setupButtons()
            
            // 添加手勢識別器作為最後的備用方案
            addTapGestureRecognizers()
        }
    }

    // MARK: - UI Settings
    func setUI() {
        self.title = "Pair Bluetooth"
        navigationItem.hidesBackButton = true
        
        // 確保按鈕可以點擊並添加調試信息
        setupButtons()
    }

    // 初始狀態：隱藏 correct，顯示 loading（假定 imgvDot 為 loading 圖）
    private func setInitialUIState() {
        imgvCorrect?.isHidden = true
        imgvCorrect?.alpha = 0
        // 確保 loading 圖可見
        imgvDot?.isHidden = false
        imgvDot?.transform = .identity
        isCorrectShown = false
        // 取消任何遺留的倒數
        countdownWorkItem?.cancel()
        countdownWorkItem = nil
        willPresentLoading = false
        
        // 清除按鈕的調試背景色
        btnPair?.backgroundColor = UIColor.clear
        btnCancel?.backgroundColor = UIColor.clear
        print("PairingVC: 按鈕背景色已清除")
    }

    // Loading 動畫（示範為 imgvDot 旋轉 2 秒），結束後切換畫面元件顯示隱藏
    private func startLoadingAnimation() {
        guard let loading = imgvDot else {
            // 若沒有 loading 圖，直接切換
            showCorrectAndHideOthers()
            return
        }

        // 旋轉動畫（2 秒）
        UIView.animate(withDuration: 2.0, delay: 0, options: .curveEaseInOut, animations: {
            loading.transform = CGAffineTransform(rotationAngle: .pi * 2)
            loading.alpha = 0.9
        }, completion: { [weak self] _ in
            self?.showCorrectAndHideOthers()
        })
    }

    // 顯示 correct 並隱藏其他除了 background 的元件
    private func showCorrectAndHideOthers() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            print("PairingVC: showCorrectAndHideOthers 開始執行")
            
            // 要隱藏的元件（除了 imgvCorrect 與 background）
            let toHide: [UIView?] = [
                self.lbCNTitle,
                self.lbTitle,
                self.imgvBLE,
                self.imgvPhone,
                self.imgvDot,
                self.imgvDevice,
                self.btnPair,
                self.btnCancel
            ]

            // 隱藏其他元件
            toHide.forEach { view in
                view?.isHidden = true
                if view == self.btnPair {
                    print("PairingVC: btnPair 已隱藏")
                }
                if view == self.btnCancel {
                    print("PairingVC: btnCancel 已隱藏")
                }
            }

            // 顯示 imgvCorrect（淡入）
            self.imgvCorrect?.isHidden = false
            self.imgvCorrect?.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.imgvCorrect?.alpha = 1
            }, completion: { _ in
                // 標記 correct 已顯示，並立即開始 3 秒倒數
                self.isCorrectShown = true
                print("PairingVC: imgvCorrect shown, starting 3 second countdown")
                self.scheduleCountdown()
            })
        }
    }

    // 建立並排程 3 秒倒數（只在回來時呼叫）
    private func scheduleCountdown() {
        // 取消先前的排程（保險）
        countdownWorkItem?.cancel()

        let work = DispatchWorkItem { [weak self] in
            self?.navigateToScanningSensor()
        }
        countdownWorkItem = work
        print("PairingVC: scheduling 3s countdown to navigate")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: work)
    }

    // 導頁到 ScanningSensorViewController（會先檢查 isCorrectShown）
    private func navigateToScanningSensor() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // 確保 correct 已經顯示過，否則不跳轉
            guard self.isCorrectShown else {
                print("PairingVC: navigation prevented because correct not shown yet")
                return
            }

            print("PairingVC: navigating to ScanningSensorViewController")
            
            // 使用 XIB 初始化 ScanningSensorViewController
            let scanningVC = ScanningSensorViewController(nibName: "ScanningSensorViewController", bundle: nil)
            
            if let nav = self.navigationController {
                nav.pushViewController(scanningVC, animated: true)
            } else {
                scanningVC.modalPresentationStyle = .fullScreen
                self.present(scanningVC, animated: true, completion: nil)
            }
        }
    }

    // MARK: - IBAction
    @IBAction func btnCancelTapped(_ sender: UIButton) {
        print("=== PairingVC: btnCancelTapped 被觸發 ===")
        print("PairingVC: delegate = \(String(describing: delegate))")
        
        // 清除儲存的 DeviceID
        UserDefaults.standard.removeObject(forKey: "DeviceID")
        print("PairingVC: DeviceID 已清除")

        // 直接返回到 TransmitterViewController（不依賴 delegate）
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("PairingVC: 執行 popViewController 返回 TransmitterViewController")
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func btnPairTapped(_ sender: UIButton) {
        print("=== PairingVC: btnPairTapped 被觸發 ===")
        print("PairingVC: delegate = \(String(describing: delegate))")
        
        // 設定旗標表示即將前往 Loading，回來後要執行動畫和倒數
        willPresentLoading = true
        print("PairingVC: willPresentLoading 設置為 true")

        // 直接跳轉到 LoadingViewController（不依賴 delegate）
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("PairingVC: 直接跳轉到 LoadingViewController")
            let loadingVC = LoadingViewController(nibName: "LoadingViewController", bundle: nil)
            self.navigationController?.pushViewController(loadingVC, animated: true)
            print("PairingVC: LoadingViewController push 完成")
        }
    }
    
    // MARK: - Private Methods
    private func setupButtons() {
        print("=== PairingVC: setupButtons 開始執行 ===")
        print("PairingVC: isCorrectShown = \(isCorrectShown)")
        
        // 確保按鈕可以互動
        btnPair?.isUserInteractionEnabled = true
        btnCancel?.isUserInteractionEnabled = true
        
        // 只有在 correct 還沒顯示時才確保按鈕可見
        if !isCorrectShown {
            btnPair?.isHidden = false
            btnCancel?.isHidden = false
            
            // 確保按鈕在最上層
            btnPair?.superview?.bringSubviewToFront(btnPair!)
            btnCancel?.superview?.bringSubviewToFront(btnCancel!)
        }
        
        // ...existing code...
        print("PairingVC setupButtons:")
        print("  btnPair = \(String(describing: btnPair))")
        print("  btnPair.isUserInteractionEnabled = \(btnPair?.isUserInteractionEnabled ?? false)")
        print("  btnPair.isHidden = \(btnPair?.isHidden ?? true)")
        print("  btnPair.frame = \(btnPair?.frame ?? CGRect.zero)")
        print("  btnCancel = \(String(describing: btnCancel))")
        print("  btnCancel.isUserInteractionEnabled = \(btnCancel?.isUserInteractionEnabled ?? false)")
        print("  btnCancel.isHidden = \(btnCancel?.isHidden ?? true)")
        print("  btnCancel.frame = \(btnCancel?.frame ?? CGRect.zero)")
        print("  delegate = \(String(describing: delegate))")
        
        // 如果按鈕為 nil，輸出警告
        if btnPair == nil {
            print("⚠️ 警告: btnPair 為 nil！XIB 連接可能有問題")
        }
        if btnCancel == nil {
            print("⚠️ 警告: btnCancel 為 nil！XIB 連接可能有問題")
        }
        
        // 作為備用方案，程式化添加按鈕事件（以防 XIB 連接失效）
        btnPair?.removeTarget(nil, action: nil, for: .allEvents) // 先清除舊的
        btnCancel?.removeTarget(nil, action: nil, for: .allEvents)
        
        btnPair?.addTarget(self, action: #selector(btnPairTapped(_:)), for: .touchUpInside)
        btnCancel?.addTarget(self, action: #selector(btnCancelTapped(_:)), for: .touchUpInside)
        
        print("PairingVC: 程式化按鈕事件已添加")
        print("=== PairingVC: setupButtons 完成 ===")
    }
    
    private func addTapGestureRecognizers() {
        print("=== PairingVC: addTapGestureRecognizers 開始執行 ===")
        
        // 為 btnPair 添加點擊手勢識別器
        let pairTapGesture = UITapGestureRecognizer(target: self, action: #selector(btnPairTapped(_:)))
        btnPair?.addGestureRecognizer(pairTapGesture)
        
        // 為 btnCancel 添加點擊手勢識別器
        let cancelTapGesture = UITapGestureRecognizer(target: self, action: #selector(btnCancelTapped(_:)))
        btnCancel?.addGestureRecognizer(cancelTapGesture)
        
        print("=== PairingVC: addTapGestureRecognizers 完成 ===")
    }
}
// MARK: - Extensions


// MARK: - Protocol

protocol PairingDelegate: AnyObject {
    func btnQRScanTapped()
    func btnCancelTapped()
    func btnPairTapped()
}
