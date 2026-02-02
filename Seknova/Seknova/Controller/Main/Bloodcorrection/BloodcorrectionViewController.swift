//
//  BloodcorrectionViewController.swift
//  Seknova
//
//  Created by imac-3282 on 2025/12/18.
//

import UIKit

class BloodcorrectionViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var upImag: UIImageView!
    @IBOutlet weak var downImag: UIImageView!
    @IBOutlet weak var bloodnumLb: UILabel!
    @IBOutlet weak var morebtn: UIButton!
    @IBOutlet weak var savebtn: UIButton!

    // MARK: - Properties
    private let minValue = 55
    private let maxValue = 400
    private var value: Int = 55 {
        didSet { updateLabel() }
    }

    private var repeatTimer: Timer?
    private var repeatStep: Int = 0

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupGestures()
        value = max(minValue, min(maxValue, value))
        
        // 調試：檢查 IBOutlet 是否連接
        print("BloodcorrectionViewController viewDidLoad")
        print("savebtn is nil: \(savebtn == nil)")
        print("morebtn is nil: \(morebtn == nil)")
        print("bloodnumLb is nil: \(bloodnumLb == nil)")
        
        // 如果 savebtn 為 nil，添加程式化按鈕
        if savebtn == nil {
            setupProgrammaticButtons()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRepeat()
    }

    // MARK: - UI Setting
    func setUI() {
        navigationItem.hidesBackButton = true
        title = "血糖校正"
        updateLabel()
    }

    private func updateLabel() {
        bloodnumLb.text = "\(value)"
    }
    
    private func setupProgrammaticButtons() {
        // 程式化創建 save 按鈕
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("保存", for: .normal)
        saveButton.backgroundColor = UIColor.systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveButtonTappedProgrammatic), for: .touchUpInside)
        
        view.addSubview(saveButton)
        
        // 設置約束
        NSLayoutConstraint.activate([
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            saveButton.widthAnchor.constraint(equalToConstant: 120),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        savebtn = saveButton
        print("程式化按鈕創建完成")
    }
    
    @objc private func saveButtonTappedProgrammatic() {
        print("程式化按鈕被點擊")
        saveButtonTapped(savebtn!)
    }

    // MARK: - Gestures
    private func setupGestures() {
        upImag.isUserInteractionEnabled = true
        downImag.isUserInteractionEnabled = true

        let upTap = UITapGestureRecognizer(target: self, action: #selector(handleUpTap))
        upImag.addGestureRecognizer(upTap)

        let downTap = UITapGestureRecognizer(target: self, action: #selector(handleDownTap))
        downImag.addGestureRecognizer(downTap)

        let upLong = UILongPressGestureRecognizer(target: self, action: #selector(handleUpLongPress(_:)))
        upLong.minimumPressDuration = 0.35
        upImag.addGestureRecognizer(upLong)

        let downLong = UILongPressGestureRecognizer(target: self, action: #selector(handleDownLongPress(_:)))
        downLong.minimumPressDuration = 0.35
        downImag.addGestureRecognizer(downLong)
    }

    // MARK: - Actions (arrow)
    @objc private func handleUpTap() {
        change(by: 1)
    }

    @objc private func handleDownTap() {
        change(by: -1)
    }

    @objc private func handleUpLongPress(_ g: UILongPressGestureRecognizer) {
        switch g.state {
        case .began:
            startRepeat(step: 1) // 長按每次
        case .ended, .cancelled, .failed:
            stopRepeat()
        default: break
        }
    }

    @objc private func handleDownLongPress(_ g: UILongPressGestureRecognizer) {
        switch g.state {
        case .began:
            startRepeat(step: -1) // 長按每次
        case .ended, .cancelled, .failed:
            stopRepeat()
        default: break
        }
    }

    private func startRepeat(step: Int) {
        stopRepeat()
        repeatStep = step
        // 速度可調：初始間隔 0.12s，可依需求調整或加速
        repeatTimer = Timer.scheduledTimer(timeInterval: 0.12, target: self, selector: #selector(handleRepeatTick), userInfo: nil, repeats: true)
        // 立即做一次變動，讓使用者感覺不需等待
        change(by: repeatStep)
    }

    @objc private func handleRepeatTick() {
        change(by: repeatStep)
    }

    private func stopRepeat() {
        repeatTimer?.invalidate()
        repeatTimer = nil
        repeatStep = 0
    }

    private func change(by delta: Int) {
        let newValue = value + delta
        value = max(minValue, min(maxValue, newValue))
    }

    // MARK: - IBActions (buttons)
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        let informationVC = BloodInformationViewController()
        
        // 設定為 popover 呈現樣式
        informationVC.modalPresentationStyle = .popover
        
        // 設定 popover 呈現樣式，讓箭頭指向 btnMore 按鈕
        if let popover = informationVC.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            // 設定 delegate 以支援 iPhone 上的 popover 效果
            popover.delegate = self
            
            // 設定 popover 的尺寸
            informationVC.preferredContentSize = CGSize(width: 300, height: 200)
            
            // 添加除錯訊息
            print("Popover 設定完成 - sourceView: \(sender), sourceRect: \(sender.bounds)")
        }
        
        // 呈現 InformationViewController
        present(informationVC, animated: true) {
            print("BloodInformationViewController 已呈現")
        }
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        print("saveButtonTapped 被調用")
        print("當前數值: \(value)")
        print("navigationController 是否存在: \(navigationController != nil)")
        
        // 從 XIB 建立 BloodcorrectionConfirmViewController
        let confirmVC = BloodcorrectionConfirmViewController(nibName: "BloodcorrectionConfirmViewController", bundle: nil)
        confirmVC.correctedValue = value
        print("BloodcorrectionConfirmViewController 創建完成，值: \(value)")
        
        if let nav = navigationController {
            print("使用 navigation controller push")
            nav.pushViewController(confirmVC, animated: true)
        } else {
            print("使用 modal present")
            // 若沒有 navigation controller，以 modal 方式顯示
            confirmVC.modalPresentationStyle = .fullScreen
            present(confirmVC, animated: true, completion: nil)
        }
    }
}
    // MARK: - Extensions

// MARK: - UIPopoverPresentationControllerDelegate
extension BloodcorrectionViewController: UIPopoverPresentationControllerDelegate {
    // 這個方法讓 iPhone 也能顯示 popover（而不是自動轉為 full screen modal）
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

