//
//  CouponsViewController.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit

class CouponsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate{
    var couponsUrl = "https://dealsea.com/coupons/?app="+appVersion
    var tableview = UITableView()
    var session:NSURLSession!
    var CouponsDataSource = []
    var waitview:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let header = MJRefreshNormalHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(CouponsViewController.headerRefresh))
        self.tableview.mj_header = header
        
        self.tableview.keyboardDismissMode = .OnDrag
        self.tableview.separatorStyle = .None
        self.tableview.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height-0)
        self.view .addSubview(tableview)
        self.tableview.dataSource = self
        self.tableview.delegate = self
        
        navigationItem.title = "Coupons"
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        activityEnable()
        loadCouponsData(NSURL(string: couponsUrl)!)

    }
    
    func activityEnable(){
        self.waitview.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2)
        self.waitview.color = UIColor.grayColor()
        self.waitview.hidesWhenStopped = true
        self.view.addSubview(self.waitview)
        self.waitview.startAnimating()
    }
    func activeDisable(){
        self.waitview.stopAnimating()
    }
    
    func headerRefresh(){
        loadCouponsData(NSURL(string: couponsUrl)!)
        // 结束刷新
        self.tableview.mj_header.endRefreshing()
    }
    
    func loadCouponsData(url:NSURL){
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 30
        session = NSURLSession(configuration: config)
        let task = session.dataTaskWithURL(url) { (data, request, error) -> Void in
            if((error) != nil){
                print(error?.localizedDescription)
            }
            
            if(data == nil){
                return
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                let SpDataSource = json["list"] as! NSArray
                let CurrentDeaData = NSMutableArray()
                for CurrentDea in SpDataSource{
                    let CouponsList = CouponsInfo()
                    CouponsList.title = CurrentDea["title"] as! String
                    CouponsList.post_endtime = CurrentDea["post_endtime"] as! String
                    CouponsList.post_id = CurrentDea["post_id"] as! String
                    CouponsList.merchant = CurrentDea["merchant"] as! Array
                    CouponsList.comment_count = CurrentDea["comment_count"] as! Int
                    CurrentDeaData.addObject(CouponsList)
                }
                
                self.CouponsDataSource = CurrentDeaData
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.activeDisable()
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
        return CouponsDataSource.count

    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->UITableViewCell{
        let cell = CouponsTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "reusingCell")
        let CouponsList = CouponsDataSource[indexPath.row] as! CouponsInfo
        cell.textLabel?.text = CouponsList.title
        cell.textLabel?.numberOfLines = 0
        cell.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        cell.imageView?.sd_setImageWithURL(NSURL(string: CouponsList.merchant[4]), placeholderImage: UIImage(named: "goods"))
        
        cell.textLabel?.font = UIFont.systemFontOfSize(15)
        cell.detailTextLabel?.textColor = UIColor.grayColor()
        cell.detailTextLabel?.text = CouponsList.merchant[1]
        cell.commentlabel.textColor = UIColor.grayColor()
        cell.commentlabel.text = "\(CouponsList.comment_count)"
        cell.commentlabel.sizeToFit()
        
        cell.timelabel.textColor = UIColor.grayColor()
        cell.timelabel.text = "Expired: "+CouponsList.post_endtime
        cell.timelabel.sizeToFit()
        return cell

    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let detailVc = CouponsDetailViewController()
        let CouponsList = CouponsDataSource[indexPath.row] as! CouponsInfo
        detailVc.url = CouponsList.merchant[3] + "?app=" + appVersion
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Coupons", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.pushViewController(detailVc, animated: true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
