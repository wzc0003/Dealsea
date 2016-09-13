//
//  GoodsViewController.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit

class CouponsDetailViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var tableview = UITableView()
    var imgview:UIImageView?
    var url = String()
    var session:NSURLSession!
    var CouponsDetailDataSource = []
    var merchant = Array(count: 5, repeatedValue: "")


    let detailColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = ""
        
        self.tableview.keyboardDismissMode = .OnDrag
        self.tableview.separatorStyle = .None
        self.tableview.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height-0)

        self.view .addSubview(tableview)
        tableview.dataSource = self
        tableview.delegate = self
        
        loadCouponsDetailData(NSURL(string: self.url)!)
    }
    
    func loadCouponsDetailData(url:NSURL){
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 30
        
        session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithURL(url) { (data, request, error) -> Void in
            
            if((error) != nil){
                print(error?.localizedDescription)
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                let merchantData = json["merchant"] as! NSArray
                self.merchant = merchantData as! Array<String>
                
                let DataSource = json["list"] as! NSArray
                let CurrentDeaData = NSMutableArray()
                for CurrentDea in DataSource{
                    let List = CouponsDetailInfo()
                    List.title = CurrentDea["title"] as! String
                    List.post_endtime = CurrentDea["post_endtime"] as! String
                    List.expired = CurrentDea["expired"] as! Bool
                    List.comment_count = CurrentDea["comment_count"] as! Int
                    CurrentDeaData.addObject(List)
                }
                
                self.CouponsDetailDataSource = CurrentDeaData
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableview.reloadData()
                })
            }catch{
                print("error")
            }
        }
        
        task.resume()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 100
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CouponsDetailDataSource.count
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->UITableViewCell{
        let cell = CouponsDetailTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "reusingCell")
        let CouponsList = CouponsDetailDataSource[indexPath.row] as! CouponsDetailInfo
        cell.textLabel?.text = CouponsList.title
        cell.textLabel?.numberOfLines = 0
        
        cell.textLabel?.font = UIFont.systemFontOfSize(15)
        cell.detailTextLabel?.textColor = UIColor.grayColor()
        cell.detailTextLabel?.text = ""
        cell.commentlabel.textColor = UIColor.grayColor()
        cell.commentlabel.text = "\(CouponsList.comment_count)"
        cell.commentlabel.sizeToFit()
        
        cell.timelabel.textColor = UIColor.grayColor()
        cell.timelabel.text = "Expired: "+CouponsList.post_endtime
        cell.timelabel.sizeToFit()
        return cell
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
