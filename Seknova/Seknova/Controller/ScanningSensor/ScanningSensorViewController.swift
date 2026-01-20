//
//  ScanningSensorViewController.swift
//  Seknova
//
//  Created by imac-3282 on 2025/12/17.
//
// swift
import UIKit

class ScanningSensorViewController: UIViewController {

    // MARK: - IBOutlet (在 Interface Builder 連接)
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var btnTextInput: UIButton!
    @IBOutlet weak var btnSkip: UIButton!

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        self.title = "Scanning Sensor"
        navigationItem.hidesBackButton = true
        
        [btnTextInput, btnSkip].forEach { btn in
            btn?.layer.cornerRadius = 22
            btn?.layer.borderWidth = 3
            btn?.layer.borderColor = UIColor(red: 0.6, green: 0.0, blue: 0.0, alpha: 1).cgColor
            btn?.clipsToBounds = true
        }
    }

    // MARK: - IBAction
    @IBAction func textInputTapped(_ sender: UIButton) {
        presentInputAlert()
    }

    @IBAction func skipTapped(_ sender: UIButton) {
        // 優先從 storyboard 用 identifier 建立 MainViewController
        let mainVCFromStoryboard: MainViewController? = {
            guard let sb = storyboard else { return nil }
            return sb.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController
        }()

        let mainVC = mainVCFromStoryboard ?? MainViewController()
        
        // 若在 navigation stack，push 到 MainViewController
        if let nav = navigationController {
            nav.pushViewController(mainVC, animated: true)
            return
        }
        
        // 若沒有 navigationController，改為 present (full screen)
        mainVC.modalPresentationStyle = .fullScreen
        present(mainVC, animated: true, completion: nil)
    }

    // MARK: - Input / Validation
    private func presentInputAlert() {
        let alert = UIAlertController(title: "文字輸入", message: "請輸入裝置 ID", preferredStyle: .alert)
        
        alert.addTextField { [weak self] tf in
            guard let self = self else { return }
            tf.placeholder = "輸入裝置ID後六碼"
            tf.isSecureTextEntry = true                      // 密碼隱藏
            tf.autocapitalizationType = .allCharacters       // 自動大寫
            tf.keyboardType = .asciiCapable                  // 可輸入字母與數字
            tf.clearButtonMode = .whileEditing
            tf.addTarget(self, action: #selector(self.alertTextFieldEditingChanged(_:)), for: .editingChanged)
        }

        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let confirm = UIAlertAction(title: "確認", style: .default) { [weak self, weak alert] _ in
            guard let self = self,
                  let text = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            self.handleInput(text)
        }
        confirm.isEnabled = false // 預設不可按，等輸入合法才啟用

        alert.addAction(cancel)
        alert.addAction(confirm)

        present(alert, animated: true, completion: nil)
    }

    // 即時過濾輸入並啟用/停用確認按鈕
    @objc private func alertTextFieldEditingChanged(_ sender: UITextField) {
        // 取得目前 alert 的確認按鈕
        guard let alert = presentedViewController as? UIAlertController,
              let confirmAction = alert.actions.first(where: { $0.title == "確認" }) else { return }

        var text = sender.text ?? ""
        if text.count > 6 {
            text = String(text.prefix(6))
        }

        // 處理第一個字：大寫，且必須為 A-F
        if !text.isEmpty {
            var chars = Array(text)
            let firstChar = String(chars.removeFirst()).uppercased()
            if firstChar.range(of: "^[A-F]$", options: .regularExpression) == nil {
                // 第一個字不合法，清空輸入
                sender.text = ""
                confirmAction.isEnabled = false
                return
            }

            // 後續只保留數字，最多 5 碼
            let rest = String(chars).filter { $0.isNumber }
            let trimmedRest = String(rest.prefix(5))
            let final = firstChar + trimmedRest
            sender.text = final

            // 啟用 confirm 若長度正好為 6，且完全符合格式
            confirmAction.isEnabled = isValidPassword(final)
        } else {
            confirmAction.isEnabled = false
        }
    }

    private func isValidPassword(_ s: String) -> Bool {
        // 格式：首位 A-F（大寫） + 5 個數字
        let pattern = "^[A-F][0-9]{5}$"
        return s.range(of: pattern, options: .regularExpression) != nil
    }

    private func handleInput(_ input: String) {
        // 檢查格式
        guard isValidPassword(input) else {
            showFailAlert(message: "格式錯誤：請輸入 A-F 開頭，後面 5 碼數字")
            return
        }

        // 原有邏輯：如果有已儲存的 DeviceID，檢查後六碼是否相同
        if let stored = UserDefaults.standard.string(forKey: "DeviceID"), stored.count >= 6 {
            let suffix = String(stored.suffix(6))
            if suffix == input {
                showSuccessAndNavigate()
            } else {
                showFailAlert(message: "驗證失敗，後六碼不符")
            }
        } else {
            print("ScanningSensorVC: no stored DeviceID, accepting input as valid")
            showSuccessAndNavigate()
        }
    }

    // MARK: - Alerts & Navigation
    private func showSuccessAndNavigate() {
        let success = UIAlertController(title: "驗證成功", message: nil, preferredStyle: .alert)
        present(success, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak success, weak self] in
                success?.dismiss(animated: true, completion: {
                    self?.navigateToMain()
                })
            }
        }
    }

    private func showFailAlert(message: String) {
        let fail = UIAlertController(title: "驗證失敗", message: message, preferredStyle: .alert)
        fail.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
        present(fail, animated: true, completion: nil)
    }

    private func navigateToMain() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // 如果在 navigation stack，回到 root
            if let nav = self.navigationController {
                nav.popToRootViewController(animated: true)
                return
            }

            // 嘗試用 storyboard id `MainViewController` present（請確認已在 Interface Builder 設定該 ID）
            if let sb = self.storyboard, let mainVC = sb.instantiateViewController(withIdentifier: "MainViewController") as UIViewController? {
                mainVC.modalPresentationStyle = .fullScreen
                self.present(mainVC, animated: true, completion: nil)
                return
            }

            // 嘗試透過 key window 的 rootViewController 做 dismiss
            if let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }), let root = window.rootViewController {
                root.dismiss(animated: true, completion: nil)
                return
            }

            // 最後 fallback dismiss
            self.dismiss(animated: true, completion: nil)
        }
    }
}
