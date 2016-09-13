//
//  GoodsCollectionViewCell.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit
import AFNetworking

class GoodsCollectionViewCell: UICollectionViewCell,UITableViewDataSource,UITableViewDelegate {
    
    var logo = "dealsea"
    var placeholder = "Search"
    var searchMode = "&search_mode=Deals&"
    //    let mainUrl = "https://dealsea.com/?app="+appVersion
    let searchUrl = "http://dealsea.com/search?q="
    var session:NSURLSession!
    var tableview:UITableView!
    //    var DataSource:NSMutableArray!    //商品列表
    
    var didselectBlock:((vc:NewGoodsViewController)->Void)?
    
    var enableFrash:Bool = true
    var frashPage:NSInteger = 2
    
    var waitview:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    
    var categoryModel:NotificationsInfo = NotificationsInfo(){
        didSet{
            categoryurl = categoryModel.url
        }
    }
    var categoryurl:String = String(){
        didSet{
            self.enableFrash = true
            let manager = NetworkTool.sharetool
            for task in manager.taskarr{
                task.cancel()
            }
            self.tableview.mj_header.endRefreshing()
            if(categoryModel.DataSource.count == 0){
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableview.reloadData()
                }
                self.waitview.startAnimating()
                loadDataSource(NSURL(string: categoryurl)!)
//                self.tableview.mj_header.beginRefreshing()
            }else{
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableview.reloadData()
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        SetupUI()
    }
    
    func SetupUI(){
        contentView.backgroundColor = UIColor.whiteColor()
        tableview = UITableView()
        tableview.separatorStyle = .None
        let header = MJRefreshNormalHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(DealseaViewController.headerRefresh))
        self.tableview.mj_header = header
        tableview.dataSource = self
        tableview.delegate = self
        tableview.registerClass(DealseaTableViewCell.self, forCellReuseIdentifier: "reusingCell")
        contentView.addSubview(tableview)
        activityEnable()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableview.frame = contentView.frame
        self.waitview.center = CGPoint(x: contentView.frame.size.width/2, y: contentView.frame.size.height/2)
        
    }
    
    func headerRefresh(){
        loadDataSource(NSURL(string: categoryurl)!)
    }
    func activityEnable(){
        self.waitview.color = UIColor.grayColor()
        self.waitview.hidesWhenStopped = true
        contentView.addSubview(self.waitview)
    }
    func activeDisable(){
        self.tableview.mj_header.endRefreshing()
        self.waitview.stopAnimating()
    }
    
    func loadDataSource(url:NSURL){
        let manager = NetworkTool.sharetool
        manager.manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as? Set<String>
        let tmptask:NSURLSessionDataTask = manager.manager.POST(url.absoluteString, parameters: nil, progress: { (progress) in
            
            }, success: { (task, data) in
                let dict:[String:AnyObject] = data as! Dictionary
                let CouponsDataSource = dict["list"] as! NSArray
                let CurrentDeaData = NSMutableArray()
                for CurrentDea in CouponsDataSource{
                    let spList = DeaList()
                    spList.title = CurrentDea["title"] as! String
                    spList.post_time = CurrentDea["post_time"] as! String
                    spList.post_id = CurrentDea["post_id"] as! String
                    spList.merchant = CurrentDea["merchant"] as! Array
                    spList.image = CurrentDea["img"] as! Array
                    spList.comment_count = CurrentDea["comment_count"] as! Int
                    spList.allowComment = CurrentDea["post_allowcomment"] as! String
                    spList.expired = CurrentDea["expired"] as! Int
                    spList.hotness = CurrentDea["hotness"] as! String
                    CurrentDeaData.addObject(spList)
                }
                
                self.categoryModel.DataSource = CurrentDeaData
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.activeDisable()
                    self.tableview.reloadData()
                })
                
        }) { (task, error) in
            print(error.localizedDescription)
            }!
        manager.taskarr.append(tmptask)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 100
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  categoryModel.DataSource.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCellWithIdentifier("reusingCell", forIndexPath: indexPath) as! DealseaTableViewCell
        let splist =  categoryModel.DataSource[indexPath.row] as! DeaList
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.textLabel?.numberOfLines = 0
        if(splist.expired != 0){
            cell.textLabel?.text = "(Expired) \(splist.title)"
            cell.textLabel?.textColor = UIColor.blackColor()
        }else{
            cell.textLabel?.text = splist.title
            if(splist.hotness.hasPrefix("1")){
                cell.textLabel?.textColor = UIColor.redColor()
            }else{
                cell.textLabel?.textColor = UIColor.blackColor()
            }
        }
        cell.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        cell.imageView?.sd_setImageWithURL(NSURL(string: splist.image[0]), placeholderImage: UIImage(named: "goods"))
        cell.textLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightMedium)
        //cell.textLabel.font = UIFont.weight: UIFontWeightBold
        cell.detailTextLabel?.textColor = UIColor.grayColor()
        cell.detailTextLabel?.text = splist.merchant[1]
        cell.commentlabel.textColor = UIColor.grayColor()
        cell.commentlabel.text = "\(splist.comment_count)"
        cell.commentlabel.sizeToFit()
        
        cell.timelabel.textColor = UIColor.grayColor()
        cell.timelabel.text = splist.post_time
        cell.timelabel.sizeToFit()
        
        
        
        if(indexPath.row > (self.categoryModel.DataSource.count - 10)){
            if(enableFrash == true){
                enableFrash = false
                waitview.startAnimating()
                let manager = NetworkTool.sharetool
                for task in manager.taskarr{
                    task.cancel()
                }
                manager.manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as? Set<String>
                manager.manager.POST(categoryurl+"&page=\(self.frashPage)", parameters: "", progress: { (progress) -> Void in
                    
                    }, success: { (task, data) -> Void in
                        self.enableFrash = true
                        let dict:[String:AnyObject] = data as! Dictionary
                        if(data != nil){
                            let CouponsDataSource = dict["list"] as! NSArray
                            let CurrentDeaData = NSMutableArray(array: self.categoryModel.DataSource)
                            for CurrentDea in CouponsDataSource{
                                let spList = DeaList()
                                spList.title = CurrentDea["title"] as! String
                                spList.post_time = CurrentDea["post_time"] as! String
                                spList.post_id = CurrentDea["post_id"] as! String
                                spList.merchant = CurrentDea["merchant"] as! Array
                                spList.image = CurrentDea["img"] as! Array
                                spList.comment_count = CurrentDea["comment_count"] as! Int
                                spList.allowComment = CurrentDea["post_allowcomment"] as! String
                                spList.expired = CurrentDea["expired"] as! Int
                                spList.hotness = CurrentDea["hotness"] as! String
                                CurrentDeaData.addObject(spList)
                            }
                            self.categoryModel.DataSource = CurrentDeaData
                            self.tableview.reloadData()
                            self.frashPage  = self.frashPage + 1
                            self.waitview.stopAnimating()
                        }
                        
                }) { (task, error) -> Void in
                    self.enableFrash = true
                    self.waitview.stopAnimating()
                }
            }
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let goodsvc = NewGoodsViewController(nibName: nil, bundle: nil)
        let splist = categoryModel.DataSource[indexPath.row] as! DeaList
        goodsvc.goodModel = splist
        [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        if(didselectBlock != nil){
            didselectBlock!(vc: goodsvc)
        }
    }
    
}
