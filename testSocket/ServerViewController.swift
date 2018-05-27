//
//  ServerViewController.swift
//  testSocket
//
//  Created by BobChang on 18/05/2017.
//  Copyright © 2017 iirlab. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ServerViewController: UIViewController {

    
    //服务端和客户端的socket引用
    var serverSocket: GCDAsyncSocket?
    var clientSocket: GCDAsyncSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.infoTV.text = ""
        
        // 讓指定的 textFiled 可以吃 UITextFieldDelegate
        self.portTF.delegate   = self
        self.msgTF.delegate = self
        
    }
    
    //对InfoTextView添加提示内容
    func addText(_ text: String) {
        infoTV.text = infoTV.text.appendingFormat("%@\n", text)
    }
    
    
    //端口
    @IBOutlet weak var portTF: UITextField!
    
    //消息
    @IBOutlet weak var msgTF: UITextField!
    
    //信息显示
    @IBOutlet weak var infoTV: UITextView!
    
    
    
    ///监听
    @IBAction func listeningAct(sender: AnyObject) {
        
        serverSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        do {
            try serverSocket?.accept(onPort: UInt16(portTF.text!)!)
            addText("监听成功")
        }catch _ {
            addText("监听失败")
        }
        
    }
    
    ///发送
    @IBAction func sendAct(sender: AnyObject) {
        let data = msgTF.text?.data(using: String.Encoding.utf8)
        //向客户端写入信息   Timeout设置为 -1 则不会超时, tag作为两边一样的标示
        clientSocket?.write(data!, withTimeout: -1, tag: 0)
    }

}

extension ServerViewController: GCDAsyncSocketDelegate {
    
    //当接收到新的Socket连接时执行
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        
        addText("连接成功")
        addText("连接地址" + newSocket.connectedHost!)
        addText("端口号" + String(newSocket.connectedPort))
        clientSocket = newSocket
        
        //第一次开始读取Data
        clientSocket!.readData(withTimeout: -1, tag: 0)
    }
    
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let message = String(data: data,encoding: String.Encoding.utf8)
        addText(message!)
        //再次准备读取Data,以此来循环读取Data
        sock.readData(withTimeout: -1, tag: 0)
    }
    
}


// 讓 textField 可以實現 return 按鈕，隱藏鍵盤
extension ServerViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
}
