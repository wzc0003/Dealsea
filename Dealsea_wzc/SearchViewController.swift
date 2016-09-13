//
//  SearchViewController.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit
import AFNetworking

class SearchViewController: UIViewController,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate {

    var searchMode = "&search_mode=Deals&"
    let searchUrl = "http://dealsea.com/search?&q="
    var searchBar:UISearchBar!
    var searchLine:UIView!
    var searchLine2:UIView!
    var session:NSURLSession!
    var DataSource = []     //商品列表
    var tableview:UITableView!
    var waitview:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    var enableFrash:Bool = true
    var frashPage:NSInteger = 10
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 236/255, green: 235/255, blue: 243/255, alpha: 1)
        configureSearchController()
        innerTableview()
        activityEnable()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func innerTableview(){
        tableview = UITableView(frame: CGRectMake(0, CGRectGetMaxY(searchLine.frame), view.frame.size.width, view.frame.size.height - CGRectGetMaxY(searchLine.frame)), style: .Plain)
        tableview.separatorStyle = .None
        tableview.keyboardDismissMode = .OnDrag
        let header = MJRefreshNormalHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(SearchViewController.headerRefresh))
        self.tableview.mj_header = header
        tableview.dataSource = self
        tableview.delegate = self
        tableview.registerClass(DealseaTableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableview)
    }
    
    func headerRefresh(){
        var searchString = searchBar.text
        if(searchString?.characters.count == 0){
            self.tableview.mj_header.endRefreshing()
            return
        }
        searchString = searchString?.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        loadDataSource(NSURL(string: searchUrl + searchString! + searchMode + "app=" + appVersion + "&n=0")!)
    }
    
    func activityEnable(){
        self.waitview.color = UIColor.grayColor()
        self.waitview.hidesWhenStopped = true
        self.waitview.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        view.addSubview(self.waitview)
    }
    func activeDisable(){
        self.tableview.mj_header.endRefreshing()
        self.waitview.stopAnimating()
    }
    
    func configureSearchController() {
        searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.barTintColor = UIColor(red: 236/255, green: 235/255, blue: 243/255, alpha: 1)
        searchBar.tintColor = UIColor.blackColor()
        //searchBar.layer.borderColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1).CGColor
        searchBar.layer.borderColor = UIColor(red: 236/255, green: 235/255, blue: 243/255, alpha: 1).CGColor
        searchBar.layer.borderWidth = 1
        searchBar.becomeFirstResponder()
//        print(searchBar.performSelector(Selector("recursiveDescription")))
        searchBar.frame = CGRect(x: 0, y: 20, width: searchBar.frame.size.width, height: searchBar.frame.size.height)
        for tmp in searchBar.subviews[0].subviews {
            if tmp.isKindOfClass(UIButton.self) {
                let button:UIButton = tmp as! UIButton
                button.setTitle("Cancel", forState: .Normal)
                button.setTitleColor(UIColor.blackColor(), forState: .Normal)
            }
        }
        view.addSubview(searchBar)
        
        searchLine = UIView(frame: CGRect(x: 0, y: CGRectGetMaxY(searchBar.frame), width: view.frame.size.width, height: 1))
        searchLine.backgroundColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
        //view.addSubview(searchLine)
        
        searchLine2 = UIView(frame: CGRect(x: 0, y: CGRectGetMinY(searchBar.frame) - 1, width: view.frame.size.width, height: 1))
        searchLine2.backgroundColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
        //view.addSubview(searchLine2)
    }
    
    //MARK:
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func loadDataSource(url:NSURL){
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 30
        self.waitview.startAnimating()
        session = NSURLSession(configuration: config)
        let task = session.dataTaskWithURL(url) { (data, request, error) -> Void in
            if((error) != nil){
                print(error?.localizedDescription)
            }
            if(data != nil){
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    let CouponsDataSource = json["list"] as! NSArray
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
                    
                    self.DataSource = CurrentDeaData
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableview.reloadData()
                        self.activeDisable()
                    })
                }catch{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.activeDisable()
                    })
                }
            }
        }
        
        task.resume()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        var searchString = searchBar.text
        if(searchString?.characters.count == 0){
            return
        }
        searchString = searchString?.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        loadDataSource(NSURL(string: searchUrl + searchString! + searchMode + "app=" + appVersion + "&n=0")!)
        
        searchBar.endEditing(true)
    }
    //MARK:
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 100
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  DataSource.count
    }
    
    func  tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! DealseaTableViewCell
        let splist =  DataSource[indexPath.row] as! DeaList
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
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.textLabel?.numberOfLines = 0
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
        
        if(indexPath.row == (self.DataSource.count - 1)){
            var searchString = searchBar.text
            if(enableFrash == true && searchString?.characters.count != 0){
                enableFrash = false
                waitview.startAnimating()
                let manager = AFHTTPSessionManager()
                manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as? Set<String>
                searchString = searchString?.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                print(searchUrl + searchString! + searchMode + "app=" + appVersion + "&n=\(self.frashPage)")
                manager.POST(searchUrl + searchString! + searchMode + "app=" + appVersion + "&n=\(self.frashPage)", parameters: "", progress: { (progress) -> Void in
                    
                    }, success: { (task, data) -> Void in
                        self.enableFrash = true
                        let dict:[String:AnyObject] = data as! Dictionary
                        if(data != nil){
                            let CouponsDataSource = dict["list"] as! NSArray
                            let CurrentDeaData = NSMutableArray(array: self.DataSource)
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
                            self.DataSource = CurrentDeaData
                            self.tableview.reloadData()
                            self.frashPage = self.frashPage + 10
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
        self.tabBarController?.tabBar.hidden = true
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let goodsvc = NewGoodsViewController()
        let splist = DataSource[indexPath.row] as! DeaList
        goodsvc.goodModel = splist
        [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        goodsvc.navigationItem.title = "Deal detail"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.pushViewController(goodsvc, animated: true)
    }

}
