//
//  SetAlertViewController.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit
import AFNetworking

class SetAlertViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    let alertUrl = "https://dealsea.com/alert?app=" + appVersion
    let backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
    let addBtnColor = UIColor(red: 9/255, green: 187/255, blue: 7/255, alpha: 1)
    let deleteBtmColor = UIColor(red: 9/255, green: 187/255, blue: 7/255, alpha: 1)

    let manager = AFHTTPSessionManager()
    var defaults = NSUserDefaults.standardUserDefaults()
    var dataarray:NSArray?
    let BasicValue = UIScreen.mainScreen().bounds.size.width/320
    
    var waitview:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    lazy var keywordText:UITextField = {
        let text = UITextField()
        text.layer.borderWidth = 1
        text.layer.cornerRadius = 5
        text.layer.masksToBounds = true
        text.layer.borderColor = UIColor.lightGrayColor().CGColor
        text.borderStyle = .RoundedRect
        text.clearButtonMode = .WhileEditing
        text.placeholder = "Keyword"
        return text
    }()
    lazy var addButton:UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitle("Add", forState: .Normal)
        button.backgroundColor = self.addBtnColor
        button.addTarget(self, action: #selector(SetAlertViewController.addBtnClick(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    lazy var tableview:UITableView = {
        let tab = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        tab.dataSource = self
        tab.delegate = self
        tab.separatorStyle = .None
        tab.backgroundColor = UIColor.clearColor()
        tab.registerClass(SetAlertListTableViewCell.self, forCellReuseIdentifier: "cell")
        return tab
    }()
    let detailColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
    func addBtnClick(sender:UIButton){
        if keywordText.text?.characters.count == 0 {
            return
        }
        keywordText.userInteractionEnabled = false
        let param:[String:AnyObject] = ["user_id":defaults.objectForKey("userid") ?? Int(0),"alert_keyword":self.keywordText.text!,"alert_action":"add"]
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as? Set<String>
        keywordText.text = ""
        manager.POST(alertUrl, parameters: param, progress: { (progress) in
            
            }, success: { (task, data) in
                let dict = data as? NSDictionary ?? NSDictionary()
                self.dataarray = dict["list"] as? NSArray ?? NSArray()
                print(self.dataarray)
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableview.reloadData()
                })
                self.keywordText.userInteractionEnabled = true
        }) { (task, error) in
            print(error.description)
            self.keywordText.userInteractionEnabled = true
        }
        
    }
    func GetAlertList(){
        let param:[String:AnyObject] = ["user_id":defaults.objectForKey("userid") ?? Int(0),"alert_action":"list"]
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as? Set<String>
        manager.POST(alertUrl, parameters: param, progress: { (progress) in
            
            }, success: { (task, data) in
                let dict = data as? NSDictionary ?? NSDictionary()
                self.dataarray = dict["list"] as? NSArray ?? NSArray()
                print(self.dataarray)
                dispatch_async(dispatch_get_main_queue(), {
                    self.waitview.stopAnimating()
                    self.tableview.reloadData()
                })
                
        }) { (task, error) in
            print(error.description)
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GetAlertList()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColor
        SetupUI()
    }
    func SetupUI(){
        self.view.addSubview(self.keywordText)
        self.keywordText.snp_makeConstraints { (make) in
            make.leading.equalTo(self.view).offset(30*BasicValue)
            make.top.equalTo(self.view).offset(100*BasicValue)
            make.height.equalTo(30*BasicValue)
            make.width.equalTo(200*BasicValue)
        }
        self.view.addSubview(self.addButton)
        self.addButton.snp_makeConstraints { (make) in
            make.top.bottom.equalTo(self.keywordText)
            make.leading.equalTo(self.keywordText.snp_trailing)
            make.trailing.equalTo(self.view).offset(-30*BasicValue)
        }
        self.view .addSubview(tableview)
        tableview.snp_makeConstraints { (make) in
            make.leading.equalTo(keywordText)
            make.trailing.equalTo(addButton)
            make.top.equalTo(keywordText.snp_bottom).offset(30*BasicValue)
            make.bottom.equalTo(self.view)
        }
        
        self.waitview.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2)
        self.waitview.color = UIColor.grayColor()
        self.waitview.hidesWhenStopped = true
        self.view.addSubview(self.waitview)
        self.waitview.startAnimating()
    }
    
    // //MARK: - tableview Data delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataarray?.count ?? 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SetAlertListTableViewCell
        cell.selectionStyle = .None
        cell.backgroundColor = UIColor.clearColor()
        let data = self.dataarray![indexPath.row] as? NSArray ?? NSArray()
        cell.alertLb.text = data[1] as? String
        cell.alertid = data[0] as? String
        cell.reloadblock = {(alert_id:String)->Void in
            let alertvc = UIAlertController(title: "Warning", message: "Delete this Alert?", preferredStyle: UIAlertControllerStyle.ActionSheet)
            let alertcancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            let alertconfirm = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alertconfirm) in
                let param:[String:AnyObject] = ["user_id":self.defaults.objectForKey("userid") ?? Int(0),"alert_id":alert_id,"alert_action":"delete"]
                self.manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as? Set<String>
                self.manager.POST(self.alertUrl, parameters: param, progress: { (progress) in
                    
                    }, success: { (task, data) in
                        dispatch_async(dispatch_get_main_queue(), {
                            let dict = data as? NSDictionary ?? NSDictionary()
                            self.dataarray = dict["list"] as? NSArray ?? NSArray()
                            print(self.dataarray)
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableview.reloadData()
                            })
                        })
                }) { (task, error) in
                    print(error.description)
                }
            })
            alertvc.addAction(alertcancel)
            alertvc.addAction(alertconfirm)
            self.presentViewController(alertvc, animated: true, completion: nil)
        }
        return cell
    }
}
