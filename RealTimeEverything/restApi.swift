//
//  restApi.swift
//  RealTimeEverything
//
//  Created by paulus herdiyatma on 6/10/16.
//  Copyright © 2016 paulusherdiyatma. All rights reserved.
//

import Foundation
import SocketIOClientSwift
class SocketIOManager : NSObject {
    static let sharedInstance = SocketIOManager();
    
    //change this url with current API server
    let socket:SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://172.19.12.39:3000")!, options: ["log": true,"ForcePolling":true]);
    
    override init() {
        super.init();
    }
    
    //make a connection to server
    func establishConnection() {
        self.socket.connect();
    }
    
    //disconnect connection
    func closeConnection() {
        self.socket.disconnect();
    }
    
}