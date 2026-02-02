//
//  LoadingViewController.swift
//  Seknova-Practice
//
//  Created by imac-2627 on 2025/12/3.
//


import UIKit

class LoadingViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var imgvLoad: UIImageView!
    
    // MARK: - Variables
    weak var delegate: PairingDelegate?
    private var timer: Timer?
    private var currentImageIndex = 0
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startLoadingAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        stopLoadingAnimation()
    }
    // MARK: - UI Settings
    func setUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    // MARK: - IBAction
    private func startLoadingAnimation() {
        currentImageIndex = 0
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateLoadingImage), userInfo: nil, repeats: true)
    }
    
    @objc private func updateLoadingImage() {
        imgvLoad.image = UIImage(named: "connecting_\(currentImageIndex)")
        
        if currentImageIndex >= 11 {
            stopLoadingAnimation()
            returnToPairingView()
        } else {
            currentImageIndex += 1
        }
    }
    
    private func stopLoadingAnimation() {
        timer?.invalidate()
        timer = nil
    }
    
    private func returnToPairingView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
    }
}
// MARK: - Extensions


// MARK: - Protocol

extension LoadingViewController: PairingDelegate {
    func btnQRScanTapped() {
        print("QR 掃描完成")
    }
    
    func btnCancelTapped() {
        print("取消配對")
    }
    
    func btnPairTapped() {
        print("配對完成")
    }
}
