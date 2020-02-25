//
//  ViewController.swift
//  NabtoHelloWorld
//
//  Created by Ulrik Gammelby on 24/02/2020.
//  Copyright © 2020 Nabto. All rights reserved.
//

import UIKit
import NabtoClient

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    func nabto() -> NabtoClient {
        return NabtoClient.instance() as! NabtoClient
    }
    
    func append(_ text: String) {
        self.textView.text.append(text)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.text = ""
        let version = nabto().nabtoVersionString()!
        append("Nabto available: SDK version \(version)")
    }


}

