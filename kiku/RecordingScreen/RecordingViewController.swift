//
//  RecordingViewController.swift
//  kiku
//
//  Created by Kevin Leong on 12/15/18.
//  Copyright © 2018 Orangemako. All rights reserved.
//

import UIKit

class RecordingViewController: UIViewController {
    var recordButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("Record", for: .normal)
        recordButton.setTitleColor(UIColor.blue, for: .normal)
        recordButton.addTarget(self, action: #selector(didTapRecord), for: .touchUpInside)
        
        view.addSubview(recordButton)
        
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
    
    @objc private func didTapRecord() {
        print("record tapped")
    }
}
