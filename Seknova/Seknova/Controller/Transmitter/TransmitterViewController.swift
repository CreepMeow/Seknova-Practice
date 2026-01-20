//
//  TransmitterViewController.swift
//  Seknova-Practice
//
//  Created by imac-2627 on 2025/10/15.
//

import UIKit
import AVFoundation
import AudioToolbox

class TransmitterViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnQR: UIButton!
    @IBOutlet weak var btnText: UIButton!
    
    // MARK: - Variables
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        loadBloodSugarSettings()
    }
    
    // MARK: - UI Settings
    func setUI() {
        self.title = "Scanning Transmitter"
        navigationItem.hidesBackButton = true
    }
    
    // MARK: - IBAction
    @IBAction func btnQRScanTapped(_ sender: UIButton) {
        let pairingVC = PairingViewController(nibName: "PairingViewController", bundle: nil)
        pairingVC.delegate = self
        self.navigationController?.pushViewController(pairingVC, animated: true)
    }
    
    @IBAction func btnTextInputTapped(_ sender: UIButton) {
        showTextInputAlert()
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userPassword")
        print("帳號密碼已清除")
        
        // 直接創建新的 LoginViewController 並跳轉
        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        
        // 如果當前是在 navigation controller 中，先跳到根視圖再 present
        if let currentNav = self.navigationController {
            currentNav.present(navController, animated: true)
        } else {
            // 如果沒有 navigation controller，直接 present
            self.present(navController, animated: true)
        }	
    }
    
    // MARK: - UI Settings
    private func loadBloodSugarSettings() {
        let highSugar = UserDefaults.standard.integer(forKey: "HighBloodSugar")
        let lowSugar = UserDefaults.standard.integer(forKey: "LowBloodSugar")
        print("已讀取血糖設定 - 高血糖: \(highSugar), 低血糖: \(lowSugar)")
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startQRScanner()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.startQRScanner()
                    } else {
                        self?.showPermissionDeniedAlert()
                    }
                }
            }
        case .denied, .restricted:
            showPermissionDeniedAlert()
        @unknown default:
            break
        }
    }
    
    private func startQRScanner() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showErrorAlert(message: "無法存取相機")
            return
        }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            showErrorAlert(message: "相機初始化失敗")
            return
        }
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            showErrorAlert(message: "無法添加相機輸入")
            return
        }
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            showErrorAlert(message: "無法添加元數據輸出")
            return
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
    }
    
    private func stopQRScanner() {
        captureSession?.stopRunning()
        previewLayer?.removeFromSuperlayer()
        captureSession = nil
        previewLayer = nil
    }
    
    private func showTextInputAlert() {
        let alert = UIAlertController(title: "輸入裝置ID", message: "請輸入裝置ID後6碼", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "裝置ID後6碼"
            textField.keyboardType = .asciiCapable
            textField.autocapitalizationType = .allCharacters
            textField.isSecureTextEntry = true

            // 加入文字變更監聽
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }

        let confirmAction = UIAlertAction(title: "確認", style: .default) { [weak self] _ in
            guard let textField = alert.textFields?.first,
                  let deviceID = textField.text,
                  !deviceID.isEmpty else {
                self?.showErrorAlert(message: "請輸入有效的裝置ID")
                return
            }

            // 驗證格式
            if !(self?.isValidDeviceID(deviceID) ?? false) {
                self?.showErrorAlert(message: "格式錯誤：第一碼需為A-F，後5碼需為數字")
                return
            }

            self?.saveDeviceIDAndNavigate(deviceID)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        // 限制最多6個字元
        if text.count > 6 {
            textField.text = String(text.prefix(6))
            return
        }
        
        // 格式化輸入
        let formatted = formatDeviceID(text)
        if formatted != text {
            textField.text = formatted
        }
    }

    private func formatDeviceID(_ input: String) -> String {
        var result = ""
        for (index, char) in input.enumerated() {
            if index == 0 {
                // 第一個字元必須是A-F
                if char.isLetter && "ABCDEF".contains(char.uppercased()) {
                    result += char.uppercased()
                }
            } else {
                // 其餘字元必須是數字
                if char.isNumber {
                    result += String(char)
                }
            }
        }
        return result
    }

    private func isValidDeviceID(_ deviceID: String) -> Bool {
        guard deviceID.count == 6 else { return false }
        
        let firstChar = String(deviceID.prefix(1))
        let restChars = String(deviceID.suffix(5))
        
        // 第一個字元必須是A-F，後5碼必須都是數字
        return "ABCDEF".contains(firstChar) && restChars.allSatisfy({ $0.isNumber })
    }
    
    private func saveDeviceIDAndNavigate(_ deviceID: String) {
        // 儲存裝置ID
        UserDefaults.standard.set(deviceID, forKey: "DeviceID")
        
        // 跳轉到 PairingViewController 並設定 delegate
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let pairingVC = PairingViewController(nibName: "PairingViewController", bundle: nil)
            pairingVC.delegate = self
            self.navigationController?.pushViewController(pairingVC, animated: true)
        }
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "需要相機權限",
            message: "請在設定中允許存取相機以掃描QR Code",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "前往設定", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
}
// MARK: - Protocol

extension TransmitterViewController: PairingDelegate {
    func btnPairTapped() {
        print("開始配對，進入 LoadingView")
        let loadingVC = LoadingViewController(nibName: "LoadingViewController", bundle: nil)
        loadingVC.delegate = self
        self.navigationController?.pushViewController(loadingVC, animated: true)
    }
    
    
    func btnCancelTapped() {
        print("配對取消，返回 TransmitterView")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func btnQRScanTapped() {
        print("配對完成")
    }
    

}
