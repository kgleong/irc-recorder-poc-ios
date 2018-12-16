//
//  RecordingViewController.swift
//  kiku
//
//  Created by Kevin Leong on 12/15/18.
//  Copyright © 2018 Orangemako. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController, AVAudioRecorderDelegate {
    let recordButton = UIButton()
    let microphonePermissionButton = UIButton()
    let playButton = UIButton()
    
    var recordingSettings = [String: Any]()
    var audioPlayer: AVAudioPlayer?
    var audioSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    
    var isRecording = false
    
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
        
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setTitle("Play", for: .normal)
        playButton.setTitleColor(UIColor.blue, for: .normal)
        playButton.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
        
        view.addSubview(recordButton)
        view.addSubview(microphonePermissionButton)
        view.addSubview(playButton)
        
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            microphonePermissionButton.centerXAnchor.constraint(equalTo: recordButton.centerXAnchor),
            microphonePermissionButton.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 20),
            playButton.centerXAnchor.constraint(equalTo: recordButton.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: microphonePermissionButton.bottomAnchor, constant: 20)
            ])

        audioSession = AVAudioSession.sharedInstance()
    }
    
    @objc private func didTapPlay() {
        print("Play pressed")
        let fileURL = audioFileURL(name: "myaudiofile", fileExtension: "m4a")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    @objc private func didTapRecord() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            print("Mic access granted.")
            if isRecording {
                print("Stopping recording")
                audioRecorder?.stop()
                isRecording = false
                self.audioRecorder = nil
            } else {
                isRecording = true
                print("Starting recording")
                recordAudio()
            }
        case .denied:
            print("Mic access denied.")
        case .undetermined:
            print("Need to request mic access.")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("did finish recording")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error occurred")
        
        if let recordingError = error {
            print(recordingError.localizedDescription)
        }
    }
    
    private func recordAudio() {
        recordingSettings[AVEncoderAudioQualityKey] = AVAudioQuality.min.rawValue
//        recordingSettings[AVEncoderBitRateKey] = 16
        recordingSettings[AVNumberOfChannelsKey] = 1
        recordingSettings[AVSampleRateKey] = 44100
//        recordingSettings[AVFormatIDKey] = Int(kAudioFormatAppleIMA4)
        recordingSettings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC)

        let audioRecordingURL = audioFileURL(name: "myaudiofile", fileExtension: "m4a")
        
        do {
            try audioSession?.setCategory(.playAndRecord, mode: .default, options: [])
            try audioSession?.setActive(true, options: [])
            
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
        
        do {
//            try FileManager.default.removeItem(at: audioRecordingURL)
            
            audioRecorder = try AVAudioRecorder(url: audioRecordingURL, settings: recordingSettings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    private func audioFileURL(name: String, fileExtension: String) -> URL {
        guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Could not find the document directory.")
        }
        
        return documentDirectoryURL.appendingPathComponent("\(name).\(fileExtension)")
    }
    
    @objc private func didTapRequestMicAccess() {
        AVAudioSession.sharedInstance().requestRecordPermission { allowed in
            print("Permission Granted: \(String(describing: allowed))")
        }
    }
}
