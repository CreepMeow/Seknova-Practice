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
        setUI()
        setInitialUIState()
        startLoadingAnimation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 如果是從 Loading 回來（willPresentLoading 為 true）且 correct 已顯示，才開始 3 秒倒數
        if willPresentLoading {
            willPresentLoading = false // 只觸發一次
            // only schedule if correct already shown
            if isCorrectShown {
                scheduleCountdown()
            } else {
                print("PairingVC: returned from Loading but correct not shown yet; countdown skipped")
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 離開頁面時取消任何尚未執行的倒數工作
        countdownWorkItem?.cancel()
        countdownWorkItem = nil
    }

    // MARK: - UI Settings
    func setUI() {
        self.title = "Pair Bluetooth"
        navigationItem.hidesBackButton = true
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
            toHide.forEach { $0?.isHidden = true }

            // 顯示 imgvCorrect（淡入）
            self.imgvCorrect?.isHidden = false
            self.imgvCorrect?.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.imgvCorrect?.alpha = 1
            }, completion: { _ in
                // 標記 correct 已顯示，但不立即倒數
                self.isCorrectShown = true
                print("PairingVC: imgvCorrect shown (isCorrectShown = true). Countdown will start only after returning from LoadingViewController.")
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

            // 先嘗試用目前 storyboard
            if let sb = self.storyboard,
               let vc = sb.instantiateViewController(withIdentifier: "ScanningSensorViewController") as? ScanningSensorViewController {
                if let nav = self.navigationController {
                    nav.pushViewController(vc, animated: true)
                } else {
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                return
            }

            // fallback：直接以程式化建立（如果 ScanningSensorViewController 是以 code 為主）
            let scanningVC = ScanningSensorViewController()
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
        // 清除儲存的 DeviceID
        UserDefaults.standard.removeObject(forKey: "DeviceID")

        // 使用 delegate 返回到 TransmitterView
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.btnCancelTapped()
        }
    }

    @IBAction func btnPairTapped(_ sender: UIButton) {
        // 設定旗標表示即將前往 Loading，回來後要執行倒數
        willPresentLoading = true

        // 跳轉到 LoadingView（由 delegate 負責）
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.btnPairTapped()
        }
    }
}
// MARK: - Extensions


// MARK: - Protocol

protocol PairingDelegate: AnyObject {
    func btnQRScanTapped()
    func btnCancelTapped()
    func btnPairTapped()
}
