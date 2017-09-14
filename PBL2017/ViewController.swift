//
//  ViewController.swift
//  PBL2017
//
//  Created by Thanh Doi on 9/11/17.
//  Copyright © 2017 Thanh Doi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    
    func sendCommand(_ direction: String) {
        let server = "http://192.168.11.26:3000/robot/\(direction)"
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
}

