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
    
    let userId = "some-user-id"
    let password = "password-for-encrypting-generated-private-key"
    let rpcDevice = "demo.nabto.net"
    let tunnelDevice = "streamdemo.nabto.net"
    let rpcInterface =  "<unabto_queries>" +
               "  <query name='wind_speed.json' id='2'>" +
               "    <request></request>" +
               "    <response format='json'>" +
               "      <parameter name='rpc_speed_m_s_swift' type='uint32'/>" +
               "    </response>" +
               "  </query>" +
               "</unabto_queries>"
    let nabto = { return NabtoClient.instance() as! NabtoClient }()

    @IBOutlet weak var textView: UITextView!
    
    @IBAction func handleInit(_ sender: Any) {
        do {
            try nabtoInit()
        } catch let error as NSError {
            appendError(error)
        }
    }

    @IBAction func handleRpc(_ sender: Any) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.nabtoRpc()
            } catch let error as NSError {
                self.bgAppendError(error)
            }
        }
    }
    
    func append(_ text: String) {
        self.textView.text.append("\(text)\n")
    }

    func bgAppend(_ text: String) {
        DispatchQueue.main.async {
            self.append(text)
        }
    }

    func appendOk(_ text: String) {
        self.append("\(text) completed OK")
    }

    func bgAppendOk(_ text: String) {
        DispatchQueue.main.async {
            self.appendOk(text)
        }
    }
    
    func appendError(_ error: NSError) {
        append("ERROR: API call returned \(error.code): \(error.domain)")
    }
    
    func bgAppendError(_ error: NSError) {
        DispatchQueue.main.async {
            self.appendError(error)
        }
    }
    
    func nabtoInit() throws {
        self.textView.text = ""

        var status: NabtoClientStatus = nabto.nabtoStartup()
        if (status == NabtoClientStatus.NCS_OK) {
            appendOk("nabtoStartup")
        } else {
            throw NSError(domain: "Startup failed", code: status.rawValue)
        }
        
        status = nabto.nabtoCreateSelfSignedProfile(self.userId, withPassword: self.password)
        if (status == NabtoClientStatus.NCS_OK) {
            appendOk("nabtoCreateSelfSignedProfile")
        } else {
            throw NSError(domain: "nabtoCreateSelfSignedProfile failed", code: status.rawValue)
        }
        
        status = nabto.nabtoOpenSession(self.userId, withPassword: self.password)
        if (status == NabtoClientStatus.NCS_OK) {
            appendOk("nabtoOpenSession")
        } else {
            throw NSError(domain: "nabtoOpenSession failed", code: status.rawValue)
        }
    }

    func nabtoRpc() throws {
        var buffer: UnsafeMutablePointer<Int8>? = nil
        var status: NabtoClientStatus = nabto.nabtoRpcSetDefaultInterface(rpcInterface, withErrorMessage: &buffer)
        if (status == NabtoClientStatus.NCS_OK) {
            bgAppendOk("nabtoRpcSetDefaultInterface")
        } else if (status == NabtoClientStatus.NCS_FAILED_WITH_JSON_MESSAGE) {
            throw NSError(domain: "nabtoRpcSetDefaultInterface failed: \n" + String(cString: buffer!), code: status.rawValue)
        } else {
            throw NSError(domain: "nabtoRpcSetDefaultInterface failed", code: status.rawValue)
        }
        
        status = nabto.nabtoRpcInvoke("nabto://\(self.rpcDevice)/wind_speed.json?", withResultBuffer: &buffer)
        if (status == NabtoClientStatus.NCS_OK) {
            bgAppendOk("nabtoRpcInvoke")
            bgAppend(String(cString: buffer!))
        } else if (status == NabtoClientStatus.NCS_FAILED_WITH_JSON_MESSAGE) {
            throw NSError(domain: "nabtoRpcInvoke failed: \n" + String(cString: buffer!), code: status.rawValue)
        } else {
            throw NSError(domain: "nabtoRpcInvoke failed", code: status.rawValue)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let version = nabto.nabtoVersionString()!
        append("Nabto available: SDK version \(version)")
    }


}

