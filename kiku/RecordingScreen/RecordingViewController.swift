//
//  RecordingViewController.swift
//  kiku
//
//  Created by Kevin Leong on 12/15/18.
//  Copyright © 2018 Orangemako. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

class RecordingViewController: UIViewController, AVAudioRecorderDelegate {
    let googleOAuthClientID = "122138472817-fp0d6ep1n2phs1gvt2v74m5bu2pibl8i.apps.googleusercontent.com"
    let googleSignInButton = GIDSignInButton()
    let googleDriveService = GTLRDriveService()
    
    let consoleLabel = UILabel()
    let recordButton = UIButton()
    let microphonePermissionButton = UIButton()
    let playButton = UIButton()
    let googleDriveUploadButton = UIButton()
    
    var recordingSettings = [String: Any]()
    var audioPlayer: AVAudioPlayer?
    var audioSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGoogleSignIn()
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
        
        consoleLabel.translatesAutoresizingMaskIntoConstraints = false
        consoleLabel.text = "Debug messages will appear here..."
        consoleLabel.textColor = .black
        consoleLabel.textAlignment = .center
        consoleLabel.numberOfLines = 0
        
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        
        googleDriveUploadButton.translatesAutoresizingMaskIntoConstraints = false
        googleDriveUploadButton.setTitle("Upload to google Drive", for: .normal)
        googleDriveUploadButton.setTitleColor(.blue, for: .normal)
        googleDriveUploadButton.addTarget(self, action: #selector(didTapUpload), for: .touchUpInside)
        
        view.addSubview(recordButton)
        view.addSubview(microphonePermissionButton)
        view.addSubview(playButton)
        view.addSubview(googleSignInButton)
        view.addSubview(googleDriveUploadButton)
        view.addSubview(consoleLabel)
        
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            microphonePermissionButton.centerXAnchor.constraint(equalTo: recordButton.centerXAnchor),
            microphonePermissionButton.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 20),
            playButton.centerXAnchor.constraint(equalTo: recordButton.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: microphonePermissionButton.bottomAnchor, constant: 20),
            googleSignInButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
            googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleDriveUploadButton.topAnchor.constraint(equalTo: googleSignInButton.bottomAnchor, constant: 20),
            googleDriveUploadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            consoleLabel.topAnchor.constraint(equalTo: googleDriveUploadButton.bottomAnchor, constant: 20),
            consoleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            consoleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])

        audioSession = AVAudioSession.sharedInstance()
    }
    
    @objc private func didTapUpload() {
        consoleLabel.setTextAndPrint("Google Drive Upload Button pressed.")
    }
    
    @objc private func didTapPlay() {
        consoleLabel.setTextAndPrint("Play button pressed")
        let fileURL = audioFileURL(name: "myaudiofile", fileExtension: "m4a")
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            consoleLabel.setTextAndPrint("Could not play file at \(fileURL.path)")
        }
    }
    
    @objc private func didTapRecord() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            consoleLabel.setTextAndPrint("Mic access granted.")
            if isRecording {
                recordButton.setTitle("Record", for: .normal)
                consoleLabel.setTextAndPrint("Stopping recording")
                audioRecorder?.stop()
                isRecording = false
                self.audioRecorder = nil
            } else {
                isRecording = true
                recordButton.setTitle("Stop Recording", for: .normal)
                consoleLabel.setTextAndPrint("Starting recording")
                recordAudio()
            }
        case .denied:
            consoleLabel.setTextAndPrint("Mic Access Denied")
        case .undetermined:
            consoleLabel.setTextAndPrint("Need to request mic access")
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
        recordingSettings[AVEncoderBitRateKey] = 64000
        recordingSettings[AVNumberOfChannelsKey] = 1
        recordingSettings[AVSampleRateKey] = 44100
        recordingSettings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC)

        let audioRecordingURL = audioFileURL(name: "myaudiofile", fileExtension: "m4a")
        
        do {
            try audioSession?.setCategory(.playAndRecord, mode: .default, options: [])
            try audioSession?.setActive(true, options: [])
            
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
        
        do {
            if FileManager.default.fileExists(atPath: audioRecordingURL.path) {
                consoleLabel.setTextAndPrint("Removing file at \(audioRecordingURL)")
                try FileManager.default.removeItem(at: audioRecordingURL)
            }
            
            audioRecorder = try AVAudioRecorder(url: audioRecordingURL, settings: recordingSettings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            consoleLabel.setTextAndPrint("Recording")
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
            self.consoleLabel.setTextAndPrint("Permission Granted: \(String(describing: allowed))")
        }
    }
}

extension UILabel {
    func setTextAndPrint(_ text: String?) {
        DispatchQueue.main.async {
            self.text = text
            if let newText = text {
                print(newText)
            }
        }
    }
}

extension RecordingViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            googleDriveService.authorizer = user.authentication.fetcherAuthorizer()
            consoleLabel.setTextAndPrint("Successfuly Google Sign In")
            googleSignInButton.isHidden = true
        } else {
            googleDriveService.authorizer = nil
            consoleLabel.setTextAndPrint("Failed Google Sign In. \(error.localizedDescription)")
            googleSignInButton.isHidden = false
        }
    }
    
    func setupGoogleSignIn() {
        GIDSignIn.sharedInstance()?.clientID = googleOAuthClientID

        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.scopes = [kGTLRAuthScopeDrive]
        GIDSignIn.sharedInstance()?.signInSilently()
    }
}
