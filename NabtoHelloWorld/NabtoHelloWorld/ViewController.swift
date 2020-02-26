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
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.nabtoInit()
            } catch let error as NSError {
                self.appendError(error)
            }
        }
    }

    @IBAction func handleRpc(_ sender: Any) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.nabtoInvokeRpc()
            } catch let error as NSError {
                self.appendError(error)
            }
        }
    }

    @IBAction func handleTunnel(_ sender: Any) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.nabtoOpenTunnel()
            } catch let error as NSError {
                self.appendError(error)
            }
        }
    }
    
    func append(_ text: String) {
        DispatchQueue.main.async {
            self.textView.text.append("\(text)\n")
        }
    }

    func appendOk(_ text: String) {
        self.append("OK \(text)")
    }
    
    func appendError(_ error: NSError) {
        let status: NabtoClientStatus = NabtoClientStatus(rawValue: error.code)!
        self.append("ERROR - \(error.domain): API call returned \(error.code) \"\(NabtoClient.nabtoStatusString(status)!)\"")
    }
    
    func nabtoInit() throws {
        DispatchQueue.main.async {
            self.textView.text = ""
        }
        
        let version = nabto.nabtoVersionString()!
        append("Nabto available: SDK version \(version)")

        var status: NabtoClientStatus = nabto.nabtoStartup()
        if (status == NabtoClientStatus.NCS_OK) {
            self.appendOk("nabtoStartup")
        } else {
            throw NSError(domain: "nabtoStartup failed", code: status.rawValue)
        }

        status = nabto.nabtoCreateSelfSignedProfile(self.userId, withPassword: self.password)
        if (status == NabtoClientStatus.NCS_OK) {
            self.appendOk("nabtoCreateSelfSignedProfile")
        } else {
            throw NSError(domain: "nabtoCreateSelfSignedProfile failed", code: status.rawValue)
        }
        
        status = nabto.nabtoOpenSession(self.userId, withPassword: self.password)
        if (status == NabtoClientStatus.NCS_OK) {
            self.appendOk("nabtoOpenSession")
        } else {
            throw NSError(domain: "nabtoOpenSession failed", code: status.rawValue)
        }
    }

    func nabtoInvokeRpc() throws {
        var buffer: UnsafeMutablePointer<Int8>? = nil
        var status: NabtoClientStatus = nabto.nabtoRpcSetDefaultInterface(rpcInterface, withErrorMessage: &buffer)
        if (status == NabtoClientStatus.NCS_OK) {
            self.appendOk("nabtoRpcSetDefaultInterface")
        } else if (status == NabtoClientStatus.NCS_FAILED_WITH_JSON_MESSAGE) {
            throw NSError(domain: "nabtoRpcSetDefaultInterface failed: \n" + String(cString: buffer!), code: status.rawValue)
        } else {
            throw NSError(domain: "nabtoRpcSetDefaultInterface failed", code: status.rawValue)
        }
        
        status = nabto.nabtoRpcInvoke("nabto://\(self.rpcDevice)/wind_speed.json?", withResultBuffer: &buffer)
        if (status == NabtoClientStatus.NCS_OK) {
            self.appendOk("nabtoRpcInvoke")
            self.append(String(cString: buffer!))
        } else if (status == NabtoClientStatus.NCS_FAILED_WITH_JSON_MESSAGE) {
            throw NSError(domain: "nabtoRpcInvoke failed: \n" + String(cString: buffer!), code: status.rawValue)
        } else {
            throw NSError(domain: "nabtoRpcInvoke failed", code: status.rawValue)
        }
    }
    
    func nabtoOpenTunnel() throws {
        var tunnel: NabtoTunnelHandle?
        
        var status = nabto.nabtoTunnelOpenTcp(&tunnel, toHost: self.tunnelDevice, onPort: 80)
        if (status == NabtoClientStatus.NCS_OK) {
            self.appendOk("nabtoTunnelOpenTcp")
        } else {
            throw NSError(domain: "nabtoTunnelOpenTcp failed", code: status.rawValue)
        }
        
        var state: NabtoTunnelState = NabtoTunnelState.NTS_CLOSED
        status = nabto.nabtoTunnelWait(tunnel, pollPeriodMillis: 10, timeoutMillis: 5000, resultingState: &state);
        if (status == NabtoClientStatus.NCS_OK) {
            self.append("OK nabtoTunnelWait - connection: " + NabtoClient.nabtoTunnelInfoString(state))
        } else {
            throw NSError(domain: "nabtoTunnelOpenTcp failed", code: status.rawValue)
        }
        
        if (state != NabtoTunnelState.NTS_CLOSED) {
            let port = nabto.nabtoTunnelPort(tunnel)
            self.performHttpRequest(port)
        }
    }

    func performHttpRequest(_ port: Int32) {
        let url = URL(string: "http://127.0.0.1:\(port)/")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                self.appendOk("HTTP request on tunnel")
                self.append(String(data: data!, encoding: String.Encoding.utf8) ?? "")
            } else {
                self.append("ERROR - HTTP request failed: " + error!.localizedDescription)
            }
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

