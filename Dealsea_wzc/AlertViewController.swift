//
//  AlertViewController.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    let backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
    var DataSource = []
    var tableview:UITableView!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        self.tabBarController?.tabBar.items![1].badgeValue = nil
        let defaults = NSUserDefaults.standardUserDefaults()
        if(defaults.objectForKey("CurrentDeaData") != nil){
            let CurrentDeaData:NSMutableArray = defaults.objectForKey("CurrentDeaData") as! NSMutableArray
            let tmp:NSMutableArray = NSMutableArray()
            CurrentDeaData.enumerateObjectsUsingBlock({ (CurrentDea, index, stop) in
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
                tmp.addObject(spList)
            })
            DataSource = tmp
            tableview.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        self.view.backgroundColor = backgroundColor
        SetupUI()
        innerTableview()
    }

    func SetupUI(){
        self.navigationItem.title = "Alert"
        let rightbar = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(AlertViewController.SetAlertButtonClick(_:)))
        self.navigationItem.rightBarButtonItem = rightbar
    }
    
    func SetAlertButtonClick(sender:UIBarButtonItem){
        let vc = SetAlertViewController()
        vc.navigationItem.title = "Set Alert"
        self.navigationController?.pushViewController(vc, animated: true)
    }
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
        return cell
    }
    
    
    func innerTableview(){
        tableview = UITableView(frame: CGRectMake(0, 64, view.frame.size.width, view.frame.size.height - 108), style: .Plain)
        tableview.separatorStyle = .None
        tableview.keyboardDismissMode = .OnDrag
        tableview.dataSource = self
        tableview.delegate = self
        tableview.registerClass(DealseaTableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableview)
    }
}
