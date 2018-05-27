//
//  ClientViewController.swift
//  testSocket
//
//  Created by BobChang on 18/05/2017.
//  Copyright © 2017 iirlab. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ClientViewController: UIViewController {

    
    var socket: GCDAsyncSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.infoTV.text = ""
        
        // 讓指定的 textFiled 可以吃 UITextFieldDelegate
        self.ipTF.delegate   = self
        self.portTF.delegate = self
        self.msgTF.delegate  = self
        
    }
    
    func addText(_ text: String) {
        infoTV.text = infoTV.text.appendingFormat("%@\n", text)
    }
    
    //IP地址
    @IBOutlet weak var ipTF: UITextField!
    
    //端口
    @IBOutlet weak var portTF: UITextField!
    
    //消息
    @IBOutlet weak var msgTF: UITextField!
    
    //信息显示
    @IBOutlet weak var infoTV: UITextView!
    
    
    
    //连接
    @IBAction func connectionAct(sender: AnyObject) {
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        do {
            try socket?.connect(toHost: ipTF.text!, onPort: UInt16(portTF.text!)!)
            addText("连接成功")
        }catch _ {
            addText("连接失败")
        }
    }
    
    //断开
    @IBAction func disconnectAct(sender: AnyObject) {
        socket?.disconnect()
        addText("断开连接")
    }
    
    //发送
    @IBAction func sendMsgAct(sender: AnyObject) {
        socket?.write((msgTF.text?.data(using: String.Encoding.utf8))!, withTimeout: -1, tag: 0)
    }

}

extension ClientViewController: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        addText("连接服务器" + host)
        self.socket?.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let message = String(data: data,encoding: String.Encoding.utf8)
        addText(message!)
        //再次准备读取Data,以此来循环读取Data
        sock.readData(withTimeout: -1, tag: 0)
    }
    
}

// 讓 textField 可以實現 return 按鈕，隱藏鍵盤
extension ClientViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
}
