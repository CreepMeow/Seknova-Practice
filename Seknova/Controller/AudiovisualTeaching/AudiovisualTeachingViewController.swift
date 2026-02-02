//
//  AudiovisualTeachingViewController.swift
//  Seknova-Practice
//
//  Created by imac-2627 on 2025/10/15.
//

import UIKit
import WebKit

class AudiovisualTeachingViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var wbvView: WKWebView!
    @IBOutlet weak var btnNext: UIButton!
    
    // MARK: - Variables
    
    weak var delegate: AudiovisualTeachingDelegate?
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    // MARK: - UI Settings
    func setUI() {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        let embedHTML = """
        <html><body style='margin:0;padding:0;'>
        <iframe width='100%' height='100%' src='https://www.youtube.com/embed/Tzmisk385aw?si=9Gp_cn2A31boV8en' frameborder='0' allow='accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share' allowfullscreen></iframe>
        </body></html>
        """
        wbvView.loadHTMLString(embedHTML, baseURL: nil)
    }
    
    // MARK: - IBAction
    
    @IBAction func didBtnNextTapped(_ sender: Any) {
        let SetUpBloodSugarIndexVC = SetUpBloodSugarIndexViewController(nibName: "SetUpBloodSugarIndexViewController", bundle: nil)
        self.navigationController?.pushViewController(SetUpBloodSugarIndexVC, animated: true)
    }
    
}

// MARK: - Extensions

// MARK: - Protocol

protocol AudiovisualTeachingDelegate: AnyObject {
    func btnNextTapped()
}

