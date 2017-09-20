//
//  ViewController.swift
//  PBL2017
//
//  Created by Thanh Doi on 9/11/17.
//  Copyright © 2017 Thanh Doi. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {
    
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var detectedTextLabel: UILabel!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer.init(locale: Locale(identifier: "en-US"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false
    
    func sendCommand(_ direction: String) {
        let server = "http://192.168.11.38:3300/robot/\(direction)"
        print(server)
        let url = URL(string: server)
        let dataTask = defaultSession.dataTask(with: url!) {
            data, response, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                do {
                    print(data)
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    print(jsonObject)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        dataTask.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.requestSpeechAuthorization()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.landscapeRight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func straightButtonPressed(_ sender: Any) {
        sendCommand("straight")
    }
    
    @IBAction func turnLeftButtonPressed(_ sender: Any) {
        sendCommand("left")
    }
    
    @IBAction func turnRightButtonPressed(_ sender: Any) {
        sendCommand("right")
    }
    
    @IBAction func rotateButtonPressed(_ sender: Any) {
        sendCommand("rotate")
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if isRecording == true {
            cancelRecording()
            isRecording = false
            startButton.setImage(UIImage(named: "stop"), for: .normal)
        } else {
            self.recordAndRecognizeSpeech()
            isRecording = true
            startButton.setImage(UIImage(named: "start"), for: .normal)
        }
    }
    
    func cancelRecording() {
        audioEngine.stop()
        if let node = audioEngine.inputNode {
            node.removeTap(onBus: 0)
        }
        recognitionTask?.cancel()
    }
    
    func recordAndRecognizeSpeech() {
        guard let node = audioEngine.inputNode else { return }
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.sendAlert(message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                
                let bestString = result.bestTranscription.formattedString
                
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    self.detectedTextLabel.text = lastString
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = bestString.substring(from: indexTo)
                }
                self.checkForDirectionSaid(resultString: lastString)
            } else if let error = error {
                print(error)
            }
        })
    }
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.startButton.isEnabled = true
                case .denied:
                    self.startButton.isEnabled = false
                case .restricted:
                    self.startButton.isEnabled = false
                case .notDetermined:
                    self.startButton.isEnabled = false
                }
            }
        }
    }
    
    func checkForDirectionSaid(resultString: String) {
        let resultString = resultString.lowercased()
        switch resultString {
        case "left":
            sendCommand("left")
        case "right":
            sendCommand("right")
        case "straight":
            sendCommand("straight")
        case "rotate":
            sendCommand("rotate")
        default: break
        }
    }
    
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

