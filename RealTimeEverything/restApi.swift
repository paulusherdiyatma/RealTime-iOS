//
//  restApi.swift
//  RealTimeEverything
//
//  Created by MTMAC17 on 6/10/16.
//  Copyright © 2016 paulusherdiyatma. All rights reserved.
//

import Foundation
import SocketIOClientSwift
class SocketIOManager : NSObject {
    static let sharedInstance = SocketIOManager();
    let socket:SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://172.19.12.39:3000")!, options: ["log": true,"ForcePolling":true]);
    
    //SocketIOClient(socketURL: NSURL(string: "http://172.19.12.39:3000")!);
    
    override init() {
        super.init();
    }
    
    func establishConnection() {
        socket.on("connect") {
            data, ack in
            self.socket.emit("chat message", ["test":"sss"]);
        }
        
        self.socket.connect();
    }
    
    
    func closeConnection() {
        self.socket.disconnect();
    }
    
}