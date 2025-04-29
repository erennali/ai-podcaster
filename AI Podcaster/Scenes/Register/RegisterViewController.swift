//
//  RegisterViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 29.04.2025.
//

import UIKit

class RegisterViewController: UIViewController {
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "Süre: 5 dakika"
        label.textAlignment = .center
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView2()
        // Do any additional setup after loading the view.
    }
    
    
}
private extension RegisterViewController {
    
    private func configureView2() {
        view.backgroundColor = .systemBackground
        title = "Rehister"
        
        addViews2()
        configureLayout2()
    }
    
    func addViews2() {
        
        
        contentView.addSubview(durationLabel)
        
    }
    
    func configureLayout2() {
        
        durationLabel.snp.makeConstraints { make in
            
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
    }
}
