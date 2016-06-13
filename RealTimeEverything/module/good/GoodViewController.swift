//
//  GoodViewController.swift
//  RealTimeEverything
//
//  Created by paulus herdiyatma on 6/10/16.
//  Copyright © 2016 paulusherdiyatma. All rights reserved.
//

import Foundation
import UIKit

class GoodViewController: UIViewController, UITabBarDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    //outlet var
    @IBOutlet weak var totalDataLoaded: UILabel!
    @IBOutlet weak var totalResult: UILabel!
    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var mainTableView: UITableView!
    
    //custom var
    var timer = NSTimer();
    var goods:NSMutableArray = [];
    var searchTextValue:String = "";
    var limitResult = 20;
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchText.delegate = self;
        
        //set pull to refresh control
        refreshControl = UIRefreshControl();
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh");
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged);
        self.mainTableView.addSubview(refreshControl);
        
        //when a connection has been built, will trigger below function
        SocketIOManager.sharedInstance.socket.on("connect") { data, ack in
            self.searchGoods(0);
        }
        
        //when there is any changes in the server, will triger below function
        SocketIOManager.sharedInstance.socket.on("goods-changed") { data, ack in
            
            let changes = data[0] as! NSDictionary;
            
            //below are logics for checking whether the updated goods are available in the array, then update the array & reload table
            for(var i=0;i<self.goods.count;i++){
                let goodDictionary = self.goods[i] as! NSDictionary;
                if(goodDictionary.objectForKey("id")as! String == changes.objectForKey("id")as! String){
                    self.goods[i] = changes;
                    self.mainTableView.reloadData();
                }
            }
        }
        
        //initialize good cell
        let nib = UINib(nibName: "GoodCell", bundle: nil)
        self.mainTableView.registerNib(nib, forCellReuseIdentifier: "customCell");
        
        //remove unused rows on the table view
        self.mainTableView.tableFooterView = UIView();
        self.mainTableView.layer.borderColor = UIColor.groupTableViewBackgroundColor().CGColor;
        self.mainTableView.layer.borderWidth = 3;
        
        //infinite scroll style
        self.mainTableView.infiniteScrollIndicatorStyle = .Gray;
        
        //set elements visibility
        self.noResultLabel.hidden = true;
        self.activityIndicator.hidden = true;
        self.loadingView.hidden = true;
        
        
        // Add infinite scroll handler
        self.mainTableView.addInfiniteScrollWithHandler { (scrollView) -> Void in
            
            //
            // fetch your data here, can be async operation,
            // just make sure to call finishInfiniteScroll in the end
            //
            
            //send data to the server with 3 parameters. This is an async function with callback
            SocketIOManager.sharedInstance.socket.emitWithAck("searchGood",[self.limitResult,self.goods.count, self.searchTextValue])(timeoutAfter: 10000) {data in
                let resultDictionary = data[0] as? NSDictionary;
                self.totalResult.text = (resultDictionary!.objectForKey("count")as!NSNumber).stringValue;
                //add the result to the goods array.
                self.goods.addObjectsFromArray((resultDictionary!.objectForKey("results") as? NSMutableArray)! as [AnyObject]);
                self.totalDataLoaded.text = String(self.goods.count);
                //reload table view
                self.mainTableView.reloadData();
                //stop infinite scroll
                self.mainTableView.finishInfiniteScroll();
            }
        }
        
        //make a new timer & repeat every 1 second then execute 'tick' function.
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "tick", userInfo: nil, repeats: true);
    }
    
    //function to  set timer label
    @objc func tick() {
        self.timerLabel.text = NSDateFormatter.localizedStringFromDate(NSDate(),
            dateStyle: .MediumStyle,
            timeStyle: .MediumStyle)
    }
    
    
    //when pull to refresh is triggred do this function
    func refresh(sender:AnyObject) {
        //call search good function
        self.searchGoods(0);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //table view delegate functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.goods.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //initialize cell
        let cell:GoodCell = tableView.dequeueReusableCellWithIdentifier("customCell") as! GoodCell
        
        //get good object from array based on indexpath
        let goodObject:NSDictionary = self.goods[indexPath.row] as! NSDictionary;
        
        //set good's name text
        cell.nameLabel.text = goodObject.objectForKey("name") as? String;
        
        //create number formatter & set number style to be decimal style
        let priceFormatter = NSNumberFormatter();
        priceFormatter.numberStyle = .DecimalStyle;
        priceFormatter.stringForObjectValue(goodObject.objectForKey("price")!);
        
        //set good's price text
        cell.priceLabel.text = priceFormatter.stringFromNumber((goodObject.objectForKey("price")?.integerValue)!);
        
        //create date formatter
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        //create standard date formatter (JSON date format)
        let standardDateFormat: NSDateFormatter = NSDateFormatter()
        standardDateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        //convert standard JSON date to be desire format
        let standardDate: NSDate? = standardDateFormat.dateFromString((goodObject.objectForKey("lastUpdated")as? String)!);
        
        //set good's last updated text
        cell.lastUpdatedLabel.text =  dateFormatter.stringFromDate(standardDate!);
        
        return cell;
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView:UITableView!, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat
    {
        
        return 70
    }
    
    //search good function with skip parameter
    func searchGoods(skip:Int) {
        //start activity indicator & block table view
        self.activityIndicator.startAnimating();
        self.loadingView.hidden = false;
        self.activityIndicator.hidden = false;
        
        //send data to the server with 3 parameters & get callback result from the server
        SocketIOManager.sharedInstance.socket.emitWithAck("searchGood", [self.limitResult, skip, self.searchTextValue])(timeoutAfter: 10000) {data in
            
            let resultDictionary = data[0] as? NSDictionary;
            
            //set goods's array with the results
            self.goods = (resultDictionary!.objectForKey("results") as? NSMutableArray)!;
            
            //set total result text
            self.totalResult.text = (resultDictionary!.objectForKey("count")as!NSNumber).stringValue;
            
            //set total data loaded text
            self.totalDataLoaded.text = String(self.goods.count);
            
            //when the results is 0/empty
            if(self.goods.count == 0){
                //show no result text & hide table view
                self.noResultLabel.hidden = false;
                self.mainTableView.hidden = true;
            }
            
            //when the results is not empty
            else {
                //show table view & hide no result label
                self.noResultLabel.hidden = true;
                self.mainTableView.hidden = false;
            }
            
            //reload table view
            self.mainTableView.reloadData();
            
            //stop activity indicator & hide loading view
            self.activityIndicator.stopAnimating();
            self.activityIndicator.hidden = true;
            self.loadingView.hidden = true;
            
            self.refreshControl.endRefreshing();
        }
    }
    
    
    //search bar delegate method
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        //get text input
        self.searchTextValue = searchText;
        
        //call search good function
        self.searchGoods(0);
    }
    
    
    
    
}