//
//  GoodsCommentViewController.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class GoodsCommentViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var postid:String!
    var tableview:UITableView!
    var commentView:UIView!
    var commentLabel:UITextField!
    var submitbtn:UIButton!
    var titlelabel:UILabel!
    var goodTitle:String = String()
    
    var isLastPage:Bool = false
    var freshPage:NSInteger = 2
    var enableFrash:Bool = true
    
    var goodscheckview:GoodsCommentCheckView!
    
    let commentUrl = "https://dealsea.com/comment.php?channel=iOS&app="+appVersion
    var defaults = NSUserDefaults.standardUserDefaults()
    let detailColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
    let backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
//    var dataarray:NSArray = [[String]]()
    var dataArray:Array = [GoodsCommentViewModel]()
    var replayperson:GoodsCommentViewModel!

    
    convenience init(post_id:String){
        self.init()
        postid = post_id
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.edgesForExtendedLayout = .None
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.whiteColor()]
        view.backgroundColor = UIColor.whiteColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GoodsViewController.KeyBoardShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GoodsViewController.KeyBoardHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
        SetupUI()
        getData()
    }
    
    func KeyBoardShow(noti:NSNotification)
    {
        let rect:CGRect = (noti.userInfo!["UIKeyboardBoundsUserInfoKey"] as! NSValue).CGRectValue()
        let time:CGFloat = noti.userInfo!["UIKeyboardAnimationDurationUserInfoKey"] as! CGFloat
        UIView.animateWithDuration(Double(time)) {
            self.commentView?.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame) - 44 - rect.size.height, UIScreen.mainScreen().bounds.size.width, 44)
        }
    }
    func KeyBoardHidden(noti:NSNotification)
    {
        let time:CGFloat = noti.userInfo!["UIKeyboardAnimationDurationUserInfoKey"] as! CGFloat
        UIView.animateWithDuration(Double(time)) {
            self.commentView?.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame) - 44, UIScreen.mainScreen().bounds.size.width, 44)
        }
    }

    func SetupUI(){
        titlelabel =  UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        titlelabel.textColor = UIColor.blackColor()
        titlelabel.textAlignment = .Center
        titlelabel.numberOfLines = 0
        titlelabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightMedium)
        titlelabel.backgroundColor = UIColor.clearColor()
        titlelabel.text = goodTitle
        titlelabel.sizeToFit()
        
        tableview = UITableView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), style: .Plain)
        tableview.tableHeaderView = titlelabel
        tableview.registerClass(NewCommentsTableViewCell.self, forCellReuseIdentifier: "cell")
        tableview.separatorStyle = .None
        tableview.delegate = self
        tableview.dataSource = self
        tableview.backgroundColor = backgroundColor
        tableview.keyboardDismissMode = .OnDrag
        view.addSubview(tableview)
        
        commentView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 44, width: UIScreen.mainScreen().bounds.size.width, height: 44))
        commentView?.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        commentView.hidden = true
        view.addSubview(commentView)
        self.commentView?.frame = CGRectMake(0, self.view.frame.height - 44, UIScreen.mainScreen().bounds.size.width, 44)
        
        self.commentLabel = UITextField(frame: CGRect(x: 5, y: 5, width: UIScreen.mainScreen().bounds.size.width*3/4, height: self.commentView!.frame.height - 10))
        self.commentLabel?.borderStyle = .RoundedRect
        self.commentLabel?.placeholder = "Comments"
        self.commentLabel!.clearButtonMode = .WhileEditing
        self.commentView?.addSubview(commentLabel!)
        
        self.submitbtn = UIButton(type: .Custom)
        submitbtn!.setTitle("Send", forState: .Normal)
        submitbtn!.backgroundColor = UIColor(red: 9/255, green: 187/255, blue: 7/255, alpha: 1)
        submitbtn!.frame = CGRect(x: CGRectGetMaxX((self.commentLabel?.frame)!)+5, y: 5, width: (self.commentView?.frame.size.width)! - CGRectGetMaxX((self.commentLabel?.frame)!) - 10, height: self.commentView!.frame.height - 10)
        submitbtn!.addTarget(self, action: #selector(GoodsViewController.submitComment(_:)), forControlEvents: .TouchUpInside)
        submitbtn!.layer.cornerRadius = 5
        submitbtn!.layer.masksToBounds = true
        self.commentView?.addSubview(submitbtn!)
    }
    
    
    func getData(){
        let manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as? Set<String>
        manager.POST("https://dealsea.com/view-deal/\(postid)?app=\(appVersion)&display=comments",
                     parameters: nil, progress: { (progress) in
            }, success: { (task, data) in
                let dict:[String:AnyObject] = data as! Dictionary
                if((data?.isKindOfClass(NSDictionary.self)) != nil){
                    self.isLastPage = dict["last_page"] as! Bool
                    let tmparray:NSArray = dict["list"] as! NSArray
                    self.dataArray.removeAll()
                    tmparray.enumerateObjectsUsingBlock({ (obj, index, stop) in
                        if(obj.isKindOfClass(NSArray.self)){
                            print(obj)
                            var tmpobj:[String] = [String]()
                            obj.enumerateObjectsUsingBlock({ (subobj, index, stop) in
                                tmpobj.append(subobj as? String ?? "")
                            })
                            
                            let model = GoodsCommentViewModel()
                            model.dataArray = tmpobj
                            model.isableAgree = true
                            self.dataArray.append(model)
                        }
                    })
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableview.reloadData()
                        //self.tableview.contentSize.height -= 44
                        self.commentView.hidden = false
                    })
                }
            }) { (task, error) in
                print(error.description)
        }
   }

    
    func submitComment(sender:UIButton){
        self.commentLabel?.resignFirstResponder()
        if self.commentLabel?.text!.characters.count == 0{
            return
        }

        if (defaults.objectForKey("username") == nil){
            goodscheckview = GoodsCommentCheckView(frame: UIScreen.mainScreen().bounds)
            goodscheckview?.anonyblock = {
                self.submitbtn!.enabled = false
                var dict:Dictionary<String,AnyObject> = Dictionary()
                dict["post_id"] = self.postid
                dict["user_id"] = Int(0)
                if((self.replayperson) != nil){
                    dict["comment_description"] = "\((self.commentLabel?.text)!) //@\(self.replayperson.dataArray[2]):\(self.replayperson.dataArray[0])"
                }else{
                    dict["comment_description"] = self.commentLabel?.text
                }
                dict["app"] = appVersion
                self.commentLabel?.text = nil
                self.replayperson = nil
                print(dict)
                
                let mbhud:MBProgressHUD = MBProgressHUD(view: self.view)
                mbhud.labelText = "Sending comments..."
                self.view.addSubview(mbhud)
                mbhud.show(true)
                let manager = AFHTTPSessionManager()
                manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as? Set<String>
                manager.POST(self.commentUrl, parameters: dict, progress: { (progress) -> Void in
                    
                    }, success: { (task, data) -> Void in
                        sender.enabled = true
                        mbhud.labelText = "Submitted"
                        dispatch_async(dispatch_get_main_queue(), { 
                            self.getData()
                        })
                        mbhud.mode = .Text
                        mbhud.hide(true, afterDelay: 2.0)
                        //                        self.getGoodData()
                }) { (task, error) -> Void in
                    sender.enabled = true
                    mbhud.labelText = "Comment failed"
                    mbhud.mode = .Text
                    mbhud.hide(true, afterDelay: 2.0)
                    sender.enabled = true
                    print(error.description)
                }
            }
            goodscheckview?.signinblock = {
                let vc = SignInViewController()
                vc.navigationItem.title = "Sign in"
                self.navigationController?.pushViewController(vc, animated: true)
            }
            self.tabBarController?.view.addSubview(goodscheckview!)
        }else{
            var dict:Dictionary<String,AnyObject> = Dictionary()
            dict["post_id"] = self.postid
            dict["user_id"] = defaults.objectForKey("userid") as! String
            if((self.replayperson) != nil){
                dict["comment_description"] = "\((self.commentLabel?.text)!) //@\(self.replayperson.dataArray[2]):\(self.replayperson.dataArray[0])"
            }else{
                dict["comment_description"] = self.commentLabel?.text
            }
            dict["app"] = appVersion
            self.commentLabel?.text = nil
            self.replayperson = nil
            
            let mbhud:MBProgressHUD = MBProgressHUD(view: self.view)
            mbhud.labelText = "Sending comments..."
            self.view.addSubview(mbhud)
            mbhud.show(true)
            let manager = AFHTTPSessionManager()
            manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as? Set<String>
            manager.POST(commentUrl, parameters: dict, progress: { (progress) -> Void in
                
                }, success: { (task, data) -> Void in
                    mbhud.labelText = "Submitted"
                    mbhud.mode = .Text
                    mbhud.hide(true, afterDelay: 2.0)
                    sender.enabled = true
                    dispatch_async(dispatch_get_main_queue(), {
                        self.getData()
                    })
            }) { (task, error) -> Void in
                sender.enabled = true
                mbhud.labelText = "Comment failed"
                mbhud.mode = .Text
                sender.enabled = true
                mbhud.hide(true, afterDelay: 2.0)
                
                print(error.description)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110 + self.dataArray[indexPath.row].commentHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:NewCommentsTableViewCell = tableview.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! NewCommentsTableViewCell
        let obj:GoodsCommentViewModel = self.dataArray[indexPath.row]
        cell.selectionStyle = .None
        cell.reloadblock = {
            dispatch_async(dispatch_get_main_queue(), {
                print(self.dataArray[indexPath.row])
            })
        }
        cell.celldataModel = obj
        
        if(indexPath.row >= self.dataArray.count - 2){
            if(self.enableFrash == true && self.isLastPage == false){
                self.enableFrash = false
                let manager = AFHTTPSessionManager()
                manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as? Set<String>
                manager.POST("https://dealsea.com/view-deal/\(postid)?app=\(appVersion)&display=comments&page=\(self.freshPage)",
                             parameters: nil, progress: { (progress) in
                    }, success: { (task, data) in
                        let dict:[String:AnyObject] = data as! Dictionary
                        if((data?.isKindOfClass(NSDictionary.self)) != nil){
                            self.isLastPage = dict["last_page"] as! Bool
                            let tmparray:NSArray = dict["list"] as! NSArray
                            tmparray.enumerateObjectsUsingBlock({ (obj, index, stop) in
                                if(obj.isKindOfClass(NSArray.self)){
                                    print(obj)
                                    var tmpobj:[String] = [String]()
                                    obj.enumerateObjectsUsingBlock({ (subobj, index, stop) in
                                        tmpobj.append(subobj as? String ?? "")
                                    })
                                    let model = GoodsCommentViewModel()
                                    model.dataArray = tmpobj
                                    model.isableAgree = true
                                    self.dataArray.append(model)
                                }
                            })
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableview.reloadData()
                                self.enableFrash = true
                                self.freshPage += 1
                            })
                        }
                }) { (task, error) in
                    print(error.description)
                    self.enableFrash = true
                }
            }
        }
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let obj:GoodsCommentViewModel = self.dataArray[indexPath.row]
//        let attrStr = try! NSAttributedString(
//            data: " //<span style=\"color: #3373b0;\">@\(obj.dataArray[2])</span>：\(obj.dataArray[0])".dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
//            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
//            documentAttributes: nil)
//        commentLabel.attributedText = attrStr
        self.replayperson = obj
        self.commentLabel.becomeFirstResponder()
        
        //光标移动到最开始
//        let begining:UITextPosition = self.commentLabel.beginningOfDocument
//        let startPosition:UITextPosition = self.commentLabel.positionFromPosition(begining, offset: 0)!
//        let selectRange = self.commentLabel.textRangeFromPosition(startPosition, toPosition: startPosition)
//        self.commentLabel.selectedTextRange = selectRange
    }

}
