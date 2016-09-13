
//
//  DealseaViewController.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit
import AFNetworking
    
class DealseaViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
        
    var logo = "dealsea"
    var placeholder = "Search"
    var searchMode = "&search_mode=Deals&"
    let mainUrl = "https://dealsea.com/?app="+appVersion
    let searchUrl = "http://dealsea.com/search?q="
    var tableview = UITableView()
    var collectionview:UICollectionView!
    var searchBar:UISearchBar!
    var DataSource = []     //商品列表
    var Notifications = []  //消息列表
    var session:NSURLSession!
    var CategoriesList = [NotificationsInfo]()
    
    let headerviewLine = UIView()
    
    var enableFrash:Bool = true
    var frashPage:NSInteger = 2
    var waitview:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        self.tableview.keyboardDismissMode = .OnDrag
        configureSearchController()
        SetupcollectionView()
        let header = MJRefreshNormalHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(DealseaViewController.headerRefresh))
        self.tableview.mj_header = header
        

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        tableview.registerClass(DealseaTableViewCell.self, forCellReuseIdentifier: "reusingCell")
        tableview.frame = CGRect(x: 0, y: 20+searchBar.frame.size.height + 44, width: view.frame.size.width, height: view.frame.size.height - 20 - searchBar.frame.size.height - (self.tabBarController?.tabBar.frame.size.height)! - 44)
        
        self.view .addSubview(tableview)
        self.navigationItem.title = logo
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        tableview.dataSource = self
        tableview.delegate = self
        
        activityEnable()
        loadDataSource(NSURL(string: mainUrl)!)
    }
    
    func configureSearchController() {
        // 初始化搜索控制器
        searchBar = UISearchBar()
        searchBar.showsCancelButton = true
//        searchController.searchResultsUpdater = self
//        searchController.dimsBackgroundDuringPresentation = false
        searchBar.placeholder = placeholder
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.barTintColor = UIColor(red: 236/255, green: 235/255, blue: 243/255, alpha: 1)
        searchBar.tintColor = UIColor.blackColor()
        searchBar.layer.borderColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1).CGColor
        searchBar.layer.borderWidth = 1
        searchBar.frame = CGRect(x: 0, y: 20, width: searchBar.frame.size.width - searchBar.frame.size.height, height: searchBar.frame.size.height)
        headerviewLine.frame = CGRectMake(10, searchBar.frame.origin.y, UIScreen.mainScreen().bounds.size.width, 1)
        headerviewLine.backgroundColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
        view.addSubview(searchBar)
        view.addSubview(headerviewLine)
        
        let searchicon:UIButton = UIButton(type: .Custom)
        searchicon.backgroundColor = UIColor.grayColor()
        searchicon.setImage(UIImage(named: "search"), forState: .Normal)
        searchicon.frame = CGRect(x: CGRectGetMaxX(searchBar.frame), y: searchBar.frame.origin.y, width: searchBar.frame.size.height, height: searchBar.frame.size.height)
        view.addSubview(searchicon)
    }
    
    func SetupcollectionView(){
        let flowlayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowlayout.minimumLineSpacing = 0
        flowlayout.minimumInteritemSpacing = 0
        collectionview = UICollectionView(frame: CGRectMake(0, 20+searchBar.frame.size.height, view.frame.size.width, 44), collectionViewLayout: flowlayout)
        collectionview.backgroundColor = UIColor.whiteColor()
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.registerClass(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "collectioncell")
        view.addSubview(collectionview)
    }

    func headerRefresh(){
        loadDataSource(NSURL(string: mainUrl)!)
        // 结束刷新
        self.tableview.mj_header.endRefreshing()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadDataSource(url:NSURL){
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 30
        session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithURL(url) { (data, request, error) -> Void in
            
            if((error) != nil){
                print(error?.localizedDescription)
            }
            if(data != nil){
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    print(json)
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
                        CurrentDeaData.addObject(spList)
                    }
                    
                    //get notifications data
                    let CategoriesData:NSArray
                    CategoriesData = json["categories"] as! NSArray
                    for temp in CategoriesData{
                        let tmparray:NSArray = temp as! NSArray
                        let notificationInfo = NotificationsInfo()
                        notificationInfo.title = tmparray[0] as! String
                        notificationInfo.url = tmparray[1] as! String
                        self.CategoriesList.append(notificationInfo)
                    }
                    self.DataSource = CurrentDeaData
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.activeDisable()
                        self.tableview.reloadData()
                        self.collectionview.reloadData()
                    })
                }catch{
                    self.activeDisable()
                }
            }
        }
        
        task.resume()
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        searchBar.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.layer.borderColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1).CGColor
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        activityEnable()
        var searchString = searchBar.text
        if(searchString?.characters.count == 0){
            return
        }
        searchString = searchString?.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        loadDataSource(NSURL(string: searchUrl + searchString! + searchMode + "app=" + appVersion)!)
        
        searchBar.endEditing(true)
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.tableview.reloadData()
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 100
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataSource.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCellWithIdentifier("reusingCell", forIndexPath: indexPath) as! DealseaTableViewCell
        let splist = DataSource[indexPath.row] as! DeaList
        cell.textLabel?.text = splist.title
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
        
        
        
        if(indexPath.row > (self.DataSource.count - 10)){
            if(enableFrash == true){
                enableFrash = false
                let manager = AFHTTPSessionManager()
                manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as? Set<String>
                manager.POST(mainUrl+"&page=\(self.frashPage)", parameters: "", progress: { (progress) -> Void in
                    
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
                                CurrentDeaData.addObject(spList)
                            }
                            self.DataSource = CurrentDeaData
                            self.tableview.reloadData()
                            self.frashPage  = self.frashPage + 1
                        }
                
                }) { (task, error) -> Void in
                       self.enableFrash = true
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

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "dealsea", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.pushViewController(goodsvc, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CategoriesList.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:CategoryCollectionViewCell = collectionview.dequeueReusableCellWithReuseIdentifier("collectioncell", forIndexPath: indexPath) as! CategoryCollectionViewCell
//        cell.contentView.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(256))/255.0, green: CGFloat(arc4random_uniform(256))/255.0, blue: CGFloat(arc4random_uniform(256))/255.0, alpha: 1)
        cell.label.text = CategoriesList[indexPath.item].title
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionview.frame.size.width/4, height: 44)
    }
}
