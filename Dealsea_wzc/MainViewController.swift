//
//  MainViewController.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit
import AFNetworking

class MainViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    var logo = "dealsea"
    var placeholder = "Search"
    var searchMode = "&search_mode=Deals&"
    let mainUrl = "https://dealsea.com/?app="+appVersion
    let searchUrl = "http://dealsea.com/search?q="
    var collectionview:UICollectionView!
    var goodscollectionview:UICollectionView!
    var searchBar:UILabel!
    var DataSource = []     //商品列表
    var Notifications = []  //消息列表
    var session:NSURLSession!
    var CategoriesList = [NotificationsInfo]()
    var selectindex:NSIndexPath!{
        didSet{
//            print(selectindex)
        }
    }
    
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
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        view.backgroundColor = UIColor.whiteColor()
        selectindex = NSIndexPath(forItem: 0, inSection: 0)
        configureSearchController()
        SetupcollectionView()
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        loadDataSource(NSURL(string: mainUrl)!)
    }
    
    func configureSearchController() {
        // 初始化搜索控制器
        let bgview = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 64))
        bgview.backgroundColor = UIColor.blackColor()
        view.addSubview(bgview)
        searchBar = UILabel(frame: CGRect(x: 0, y: 20, width: view.frame.size.width, height: 44))
        searchBar.backgroundColor = UIColor.blackColor()
        searchBar.textColor = UIColor.whiteColor()
        searchBar.font = UIFont.systemFontOfSize(18)
        searchBar.textAlignment = .Center
        searchBar.text = logo
        view.addSubview(searchBar)
        
        let searchicon:UIButton = UIButton(type: .Custom)
        searchicon.setImage(UIImage(named: "search"), forState: .Normal)
        searchicon.addTarget(self, action: #selector(MainViewController.searchiconClick(_:)), forControlEvents: .TouchUpInside)
        searchicon.frame = CGRect(x: CGRectGetMaxX(searchBar.frame) - searchBar.frame.size.height, y: searchBar.frame.origin.y, width: searchBar.frame.size.height, height: searchBar.frame.size.height)
        view.addSubview(searchicon)
    }
    
    func searchiconClick(sender:UIButton){
        let vc:SearchViewController = SearchViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func SetupcollectionView(){
        let flowlayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowlayout.minimumLineSpacing = 0
        flowlayout.minimumInteritemSpacing = 0
        flowlayout.scrollDirection = .Horizontal
        collectionview = UICollectionView(frame: CGRectMake(0, 20+searchBar.frame.size.height, view.frame.size.width, 44), collectionViewLayout: flowlayout)
        collectionview.tag = 10001
        collectionview.bounces = false
        collectionview.showsHorizontalScrollIndicator = false
        collectionview.backgroundColor = UIColor.whiteColor()
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.registerClass(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "collectioncell")
        view.addSubview(collectionview)
        
        let goodsflowlayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        goodsflowlayout.minimumLineSpacing = 0
        goodsflowlayout.minimumInteritemSpacing = 0
        goodsflowlayout.scrollDirection = .Horizontal
        goodscollectionview = UICollectionView(frame: CGRectMake(0, CGRectGetMaxY(collectionview.frame), view.frame.size.width, UIScreen.mainScreen().bounds.size.height - CGRectGetHeight(collectionview.frame) - 20 - CGRectGetHeight(searchBar.frame) - CGRectGetHeight((tabBarController?.tabBar.frame)!)), collectionViewLayout: goodsflowlayout)
        goodscollectionview.tag = 10002
        goodscollectionview.bounces = false
        goodscollectionview.pagingEnabled = true
        goodscollectionview.showsHorizontalScrollIndicator = false
        goodscollectionview.backgroundColor = UIColor.whiteColor()
        goodscollectionview.delegate = self
        goodscollectionview.dataSource = self
        goodscollectionview.registerClass(GoodsCollectionViewCell.self, forCellWithReuseIdentifier: "collectiongoodscell")
        view.addSubview(goodscollectionview)
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
                        self.collectionview.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
                        self.collectionview.reloadData()
                        self.goodscollectionview.reloadData()
                    })
                }catch{
                    self.activeDisable()
                }
            }
        }
        
        task.resume()
    }
//    
//    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
//        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
//        searchBar.layer.borderColor = UIColor.clearColor().CGColor
//    }
//    
//    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
//        searchBar.layer.borderColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1).CGColor
//    }
//    
//    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
//    }
//    
//    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        activityEnable()
//        var searchString = searchBar.text
//        if(searchString?.characters.count == 0){
//            return
//        }
//        searchString = searchString?.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
//        loadDataSource(NSURL(string: searchUrl + searchString! + searchMode + "app=" + appVersion)!)
//        
//        searchBar.endEditing(true)
//    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {

    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CategoriesList.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if(collectionView.tag == 10001){
            let cell:CategoryCollectionViewCell = collectionview.dequeueReusableCellWithReuseIdentifier("collectioncell", forIndexPath: indexPath) as! CategoryCollectionViewCell
            cell.label.text = CategoriesList[indexPath.item].title
            if(indexPath == selectindex){
                cell.label.textColor = UIColor(red: 9/255.0, green: 187/255.0, blue: 7/255.0, alpha: 1)
            }
            return cell
        }else{
            let cell:GoodsCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("collectiongoodscell", forIndexPath: indexPath) as! GoodsCollectionViewCell
            cell.didselectBlock = {vc in
                vc.navigationItem.title = "Deal detail"
                self.tabBarController?.tabBar.hidden = true
                let backbar:UIBarButtonItem = UIBarButtonItem(title: " ", style: .Done, target: nil, action: nil)
                self.navigationItem.backBarButtonItem = backbar
                self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
                self.navigationController?.navigationBar.titleTextAttributes =
                    [NSForegroundColorAttributeName: UIColor.whiteColor()]
                self.navigationController?.pushViewController(vc, animated: true)
            }
            cell.categoryModel = CategoriesList[indexPath.item]
            return cell
        }
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if(collectionView.tag == 10001){
            return CGSize(width: collectionview.frame.size.width/4, height: 44)
        }else{
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if(collectionView.tag == 10001){
            var selectcell:CategoryCollectionViewCell = collectionView.cellForItemAtIndexPath(selectindex) as! CategoryCollectionViewCell
            selectcell.label.textColor = UIColor.blackColor()
            selectcell = collectionView.cellForItemAtIndexPath(indexPath) as! CategoryCollectionViewCell
            selectcell.label.textColor = UIColor(red: 9/255.0, green: 187/255.0, blue: 7/255.0, alpha: 1)
            selectindex = indexPath
            goodscollectionview.scrollToItemAtIndexPath(selectindex, atScrollPosition: .None, animated: false)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if(scrollView.tag == 10002){
            var selectcell:CategoryCollectionViewCell = collectionview.cellForItemAtIndexPath(selectindex) as! CategoryCollectionViewCell
            selectcell.label.textColor = UIColor.blackColor()
            selectindex = NSIndexPath(forItem: Int(scrollView.contentOffset.x/scrollView.frame.size.width), inSection: 0)
            selectcell = collectionview.cellForItemAtIndexPath(selectindex) as! CategoryCollectionViewCell
            selectcell.label.textColor = UIColor(red: 9/255.0, green: 187/255.0, blue: 7/255.0, alpha: 1)
        }
    }
}
