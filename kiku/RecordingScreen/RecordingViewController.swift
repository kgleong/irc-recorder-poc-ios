//
//  RecordingViewController.swift
//  kiku
//
//  Created by Kevin Leong on 12/15/18.
//  Copyright © 2018 Orangemako. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController {
    var recordButton = UIButton()
    var microphonePermissionButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        microphonePermissionButton.translatesAutoresizingMaskIntoConstraints = false
        microphonePermissionButton.setTitle("Request Microphone Access", for: .normal)
        microphonePermissionButton.setTitleColor(UIColor.blue, for: .normal)
        microphonePermissionButton.addTarget(self, action: #selector(didTapRequestMicAccess), for: .touchUpInside)
        
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("Record", for: .normal)
        recordButton.setTitleColor(UIColor.blue, for: .normal)
        recordButton.addTarget(self, action: #selector(didTapRecord), for: .touchUpInside)
        
        view.addSubview(recordButton)
        view.addSubview(microphonePermissionButton)
        
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            microphonePermissionButton.centerXAnchor.constraint(equalTo: recordButton.centerXAnchor),
            microphonePermissionButton.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 20)
            ])
    }
    
    @objc private func didTapRecord() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            print("Mic access granted.")
        case .denied:
            print("Mic access denied.")
        case .undetermined:
            print("Need to request mic access.")
        }
    }
    
    @objc private func didTapRequestMicAccess() {
        AVAudioSession.sharedInstance().requestRecordPermission { allowed in
            print("Permission Granted: \(String(describing: allowed))")
        }
    }
}
