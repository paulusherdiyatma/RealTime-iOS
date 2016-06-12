//
//  GoodViewController.swift
//  RealTimeEverything
//
//  Created by paulus herdiyatma on 6/10/16.
//  Copyright © 2016 paulusherdiyatma. All rights reserved.
//

import Foundation
import UIKit

class GoodViewController: UIViewController, UITabBarDelegate, UITableViewDataSource {
    @IBOutlet weak var timerLabel: UILabel!
    var timer = NSTimer();
    @IBOutlet weak var mainTableView: UITableView!
    var goods:NSMutableArray = [];
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getGoods();
        let nib = UINib(nibName: "GoodCell", bundle: nil)
        self.mainTableView.registerNib(nib, forCellReuseIdentifier: "customCell");
        self.mainTableView.tableFooterView = UIView();

        SocketIOManager.sharedInstance.socket.on("connect") {
            data, ack in
        }
        
        
        
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GoodViewController.tick), userInfo: nil, repeats: true);
    }
    
    @objc func tick() {
        self.timerLabel.text = NSDateFormatter.localizedStringFromDate(NSDate(),
                                                                        dateStyle: .MediumStyle,
                                                                        timeStyle: .MediumStyle)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.goods.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:GoodCell = tableView.dequeueReusableCellWithIdentifier("customCell") as! GoodCell
        let goodObject:NSDictionary = self.goods[indexPath.row] as! NSDictionary;
        cell.nameLabel.text = goodObject.objectForKey("name") as? String;
        
        let fmt = NSNumberFormatter()
        fmt.numberStyle = .DecimalStyle
        fmt.stringForObjectValue(goodObject.objectForKey("price")!);
        cell.priceLabel.text = fmt.stringFromNumber((goodObject.objectForKey("price")?.integerValue)!);
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        let standardDateFormat: NSDateFormatter = NSDateFormatter()
        standardDateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let standardDate: NSDate? = standardDateFormat.dateFromString((goodObject.objectForKey("lastUpdated")as? String)!);
        
        cell.lastUpdatedLabel.text =  dateFormatter.stringFromDate(standardDate!);
        cell.backgroundColor = UIColor.whiteColor();
        
        return cell;
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView:UITableView!, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat
    {
        
        return 70
    }
    
    
    func getGoods() {
        SocketIOManager.sharedInstance.socket.on("connect") {
            data, ack in
            SocketIOManager.sharedInstance.socket.emit("getAllGood", []);
            
            SocketIOManager.sharedInstance.socket.on("goods") {
                data, ack in
                self.goods = (data[0] as? NSMutableArray)!
                self.mainTableView.reloadData();
            }
        }
    }
    
    
}