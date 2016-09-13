//
//  GoodsViewController.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit
import AFNetworking
import SnapKit
import MBProgressHUD

class GoodsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate,UITextFieldDelegate {
    let commentUrl = "https://dealsea.com/comment.php?channel=iOS&app="+appVersion
    var defaults = NSUserDefaults.standardUserDefaults()
    var goodscheckview:GoodsCommentCheckView?
    var post_id:String?
    let margin:CGFloat = 5 * UIScreen.mainScreen().bounds.size.width / 320
    var headerview:UIView?
    var tableview:UITableView?
    var imgview:UIImageView?
    var url = String()
    let detailColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
    
    var merchantView: UILabel?
    var titleView: UILabel?
    var contentWebView: UIWebView?
    var commentView:UIView?
    var commentLabel:UITextField?
    
    var line:UIView?
    var lineTitle:UIView?
    var alertbtn:UIButton?
    var submitbtn:UIButton?
    
    var constraint:Constraint?
    var commentConents:NSArray = NSArray()
    var waitview:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.commentLabel?.resignFirstResponder()
        self.view .endEditing(true)
        self.commentView?.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame) - 44, UIScreen.mainScreen().bounds.size.width, 44)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.view.frame)
        self.view.backgroundColor = UIColor.whiteColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GoodsViewController.KeyBoardShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GoodsViewController.KeyBoardHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
        SetupUI()
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
                dict["post_id"] = self.post_id
                dict["user_id"] = Int(0)
                dict["comment_description"] = self.commentLabel?.text
                dict["app"] = appVersion
                self.commentLabel?.text = nil
                print(dict)
                
                let mbhud:MBProgressHUD = MBProgressHUD(view: self.view)
                mbhud.labelText = "Sending comments..."
                self.view.addSubview(mbhud)
                mbhud.show(true)
                let manager = AFHTTPSessionManager()
                manager.POST(self.commentUrl, parameters: dict, progress: { (progress) -> Void in
                    
                    }, success: { (task, data) -> Void in
                        sender.enabled = true
                        mbhud.labelText = "Comment success"
                        mbhud.mode = .Text
                        mbhud.hide(true, afterDelay: 2.0)
//                        self.getGoodData()
                    }) { (task, error) -> Void in
                        sender.enabled = true
                        mbhud.labelText = "Comment failed"
                        mbhud.mode = .Text
                        mbhud.hide(true, afterDelay: 2.0)
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
            dict["post_id"] = self.post_id
            dict["user_id"] = defaults.objectForKey("userid") as! String
            dict["comment_description"] = self.commentLabel?.text
            dict["app"] = appVersion
            self.commentLabel?.text = nil
            
            let mbhud:MBProgressHUD = MBProgressHUD(view: self.view)
            mbhud.labelText = "Sending comments..."
            self.view.addSubview(mbhud)
            mbhud.show(true)
            let manager = AFHTTPSessionManager()
            manager.POST(commentUrl, parameters: dict, progress: { (progress) -> Void in
                
                }, success: { (task, data) -> Void in
                    mbhud.labelText = "Comment success"
                    mbhud.mode = .Text
                    mbhud.hide(true, afterDelay: 2.0)
                    sender.enabled = true
                    self.getGoodData()
            }) { (task, error) -> Void in
                sender.enabled = true
                mbhud.labelText = "Comment failed"
                mbhud.mode = .Text
                mbhud.hide(true, afterDelay: 2.0)
                print(error.description)
            }

        }
    }
    func SetupUI(){

        //let barheight:CGFloat = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height
        
        self.commentView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 44))
        self.commentView?.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        self.commentView?.hidden = true
        
        
        self.commentLabel = UITextField(frame: CGRect(x: 5, y: 5, width: UIScreen.mainScreen().bounds.size.width*3/4, height: self.commentView!.frame.height - 10))
        self.commentLabel?.borderStyle = .RoundedRect
        self.commentLabel?.delegate = self
        self.commentLabel?.placeholder = "Comment"
        self.commentLabel!.clearButtonMode = .WhileEditing
        self.commentLabel?.userInteractionEnabled = false
        self.commentLabel?.hidden = true
        self.commentView?.addSubview(commentLabel!)
        
        self.submitbtn = UIButton(type: .Custom)
        submitbtn!.setTitle("Send", forState: .Normal)
        submitbtn!.backgroundColor = detailColor
        submitbtn!.frame = CGRect(x: CGRectGetMaxX((self.commentLabel?.frame)!)+5, y: 5, width: (self.commentView?.frame.size.width)! - CGRectGetMaxX((self.commentLabel?.frame)!) - 10, height: self.commentView!.frame.height - 10)
        submitbtn!.addTarget(self, action: #selector(GoodsViewController.submitComment(_:)), forControlEvents: .TouchUpInside)
        submitbtn!.layer.cornerRadius = 5
        submitbtn!.layer.masksToBounds = true
        submitbtn?.hidden = true
        self.commentView?.addSubview(submitbtn!)
        
//        self.headerview = UIView()
//        self.imgview = UIImageView(frame: CGRect(x: 130, y: 0, width: 100, height: 120))
//        self.imgview?.center.x = (self.view.frame.size.width)/2
//        self.imgview?.contentMode = UIViewContentMode.ScaleAspectFit
//        self.headerview!.addSubview(self.imgview!)
//        
//        self.merchantView = UILabel()
//        self.merchantView!.font  = UIFont.systemFontOfSize(13)
//        self.merchantView?.numberOfLines = 1
//        self.headerview!.addSubview(self.merchantView!)
//        self.merchantView?.snp_makeConstraints(closure: { (make) in
//            make.leading.equalTo(self.headerview!).offset(margin)
//            make.trailing.equalTo(self.headerview!).offset(-margin)
//            make.top.equalTo(self.imgview!.snp_bottom).offset(margin)
//        })
//        
//        self.titleView = UILabel()
//        self.titleView?.numberOfLines = 0
//        self.titleView!.font  = UIFont.systemFontOfSize(18)
//        self.headerview!.addSubview(self.titleView!)
//        self.titleView?.snp_makeConstraints(closure: { (make) in
//            make.leading.equalTo(self.merchantView!)
//            make.width.equalTo(UIScreen.mainScreen().bounds.size.width-2*margin)
//            make.top.equalTo(self.merchantView!.snp_bottom).offset(margin)
//        })
//        
//        self.lineTitle = UIView()
//        self.lineTitle?.hidden = true
//        self.lineTitle?.backgroundColor = detailColor
//        self.headerview!.addSubview(self.lineTitle!)
//        self.lineTitle?.snp_makeConstraints(closure: { (make) in
//            make.leading.trailing.equalTo(self.titleView!)
//            make.top.equalTo(self.titleView!.snp_bottom).offset(margin)
//            make.height.equalTo(1)
//        })
//        
        self.contentWebView = UIWebView()
        self.contentWebView?.frame = CGRect(x: 0, y: 100, width: UIScreen.mainScreen().bounds.size.width, height: 100)
        self.contentWebView?.backgroundColor = UIColor.lightGrayColor()
        //self.contentWebView!.scalesPageToFit = true
        self.contentWebView?.delegate = self
        self.view?.addSubview(self.contentWebView!)
        self.contentWebView?.loadRequest(NSURLRequest(URL: NSURL(string: "https://dealsea.com/view-deal/\(url)")!))
//        self.contentWebView?.snp_makeConstraints(closure: { (make) in
//            make.leading.trailing.equalTo(self.titleView!)
//            make.top.equalTo(self.lineTitle!.snp_bottom).offset(margin)
//            self.constraint = make.height.equalTo(100).constraint
//        })
//        
//        self.line = UIView()
//        self.line?.hidden = true
//        self.line?.backgroundColor = detailColor
//        self.headerview!.addSubview(self.line!)
//        self.line?.snp_makeConstraints(closure: { (make) in
//            make.leading.trailing.equalTo(self.titleView!)
//            make.top.equalTo(self.contentWebView!.snp_bottom).offset(margin)
//            make.height.equalTo(1)
//        })
//        
//        alertbtn = UIButton(type: .Custom)
//        alertbtn!.setImage(UIImage(named: "alert_select"), forState: .Normal)
//        alertbtn!.sizeToFit()
//        alertbtn?.backgroundColor = UIColor.clearColor()
//        alertbtn!.center = (self.line?.center)!
//        alertbtn!.frame.origin.y += alertbtn!.frame.size.height/2+margin
//        alertbtn!.addTarget(self, action: #selector(GoodsViewController.alertBntClick(_:)), forControlEvents: .TouchUpInside)
//        alertbtn?.hidden = true
//        self.headerview?.addSubview(alertbtn!)
//        self.alertbtn?.snp_makeConstraints(closure: { (make) in
//            make.top.equalTo(self.line!.snp_bottom).offset(margin)
//            make.centerX.equalTo(self.line!)
//        })
//        
//        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GoodsViewController.viewTap(_:)))
//        self.headerview?.addGestureRecognizer(tap)
//        
//        self.headerview?.snp_makeConstraints(closure: { (make) in
//            make.bottom.equalTo(self.alertbtn!).offset(margin)
//        })
//        
//        
//        self.tableview = UITableView(frame: CGRectMake(0, 0, self.view.bounds.size.width, CGRectGetMaxY(self.view.frame) - 44), style: .Plain)
//        self.tableview?.registerClass(GoodsCommentCell.self, forCellReuseIdentifier: "cell")
//        self.tableview?.delegate = self
//        self.tableview?.dataSource = self
//        tableview?.rowHeight = UITableViewAutomaticDimension
//        tableview?.estimatedRowHeight = 300
//        self.tableview?.separatorStyle = .None
//        //        self.tableview!.keyboardDismissMode = .OnDrag
//        self.tableview?.tableHeaderView = self.headerview
//        self.view.addSubview(self.tableview!)
        
        self.view.addSubview(self.commentView!)
        self.commentView?.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame) - 44, UIScreen.mainScreen().bounds.size.width, 44)
        
        self.waitview.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2)
        self.waitview.color = UIColor.grayColor()
        self.waitview.hidesWhenStopped = true
        self.view.addSubview(self.waitview)
        self.waitview.startAnimating()
    }
    
    func alertBntClick(sender:UIButton){
        if (defaults.objectForKey("username") == nil){
            let vc = SignInViewController()
            self.tabBarController?.tabBar.hidden = true
            vc.navigationItem.title = "Sign in"
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            if UIApplication.sharedApplication().currentUserNotificationSettings()?.types == UIUserNotificationType.None{
                let vc = NotificationViewController()
                vc.navigationItem.title = "Notifications"
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                let vc = SetAlertViewController()
                vc.navigationItem.title = "Set Alert"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }

    }
    func viewTap(tap:UIGestureRecognizer){
        self.commentLabel?.resignFirstResponder()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print(url)
//        getGoodData()
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
  
    func getGoodData(){
        NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: NSURL(string: url)!)) { (data, response, error) -> Void in
            if((error) != nil && data == nil){
                print(error?.localizedDescription)
            }
            else
            {
                //商品图片
                let dict = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                let imageURL:NSURL = NSURL(string: dict["image_url"] as! String)!
                //商品内容
                let post_text = dict["post_text"] as! String
                self.contentWebView?.loadHTMLString(post_text, baseURL: nil)
                //评论
                self.commentConents = dict["comments"] as! NSArray
                //商家名称 + 时间
                let merchantName = dict["merchant"] as! NSArray
                let post_time = dict["post_time"] as! String
                //Title
                let TitleName = dict["title"] as! String
                
                self.post_id = dict["post_id"] as? String
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.imgview!.contentMode = UIViewContentMode.ScaleAspectFit
                    self.imgview!.sd_setImageWithURL(imageURL, placeholderImage: UIImage(named: "goods"))
                    self.merchantView?.text = (merchantName[1] as! String) + "  " + post_time
                    self.merchantView?.textColor = self.detailColor
                    let oldheight = (self.titleView?.frame.size.height)!
                    self.titleView?.text = TitleName
                    self.titleView?.sizeToFit()
                    self.headerview?.frame.size.height += ((self.titleView?.frame.size.height)! - oldheight)
                    self.tableview?.tableHeaderView = self.headerview
                    self.commentLabel?.userInteractionEnabled = true
                    self.alertbtn?.hidden = false
                    self.lineTitle?.hidden = false
                    self.line?.hidden = false
                    self.commentView?.hidden = false
                    self.commentLabel?.hidden = false
                    self.submitbtn?.hidden = false
                    self.waitview.stopAnimating()
                    self.tableview?.reloadData()
                })
            }
            }.resume()
    }

    //MARK:
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.commentLabel?.resignFirstResponder()
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
//        NSString * clientheight_str = [webView stringByEvaluatingJavaScriptFromString: @"document.body.offsetHeight"];
//        float clientheight = [clientheight_str floatValue];
        /////let clientheight_str:String = webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight")!
      /// // let clientheight:Float = Float(clientheight_str)!
//        self.constraint?.uninstall()
//        if(clientheight >= 300){
//            self.contentWebView?.snp_makeConstraints(closure: { (make) in
//                self.constraint = make.height.equalTo(300).constraint
//            })
//        }else{
//            self.contentWebView?.snp_makeConstraints(closure: { (make) in
//                self.constraint = make.height.equalTo(clientheight).constraint
//            })
//        }
        
        webView.frame.size.height = 1
        webView.frame.size = webView.sizeThatFits(CGSizeZero)
        
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print(request.URL?.absoluteString)
        if((request.URL?.absoluteString.hasPrefix("about:blank")) == true){
            return true
        }
        UIApplication.sharedApplication().openURL(request.URL!)
        return false
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.headerview!
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentConents.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = GoodsCommentCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        cell.selectionStyle = .None
//        cell.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(256))/255.0, green: CGFloat(arc4random_uniform(256))/255.0, blue: CGFloat(arc4random_uniform(256))/255.0, alpha: 1)
        let CommentData:NSArray = commentConents[indexPath.row] as! NSArray
        cell.namelabel?.text = CommentData[2] as? String
        cell.timelabel?.text = CommentData[1] as?  String
        cell.comlabel?.text = CommentData[0] as?  String
//        cell.comlabel?.sizeToFit()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.commentLabel?.resignFirstResponder()
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 120
//    }

    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.commentLabel?.resignFirstResponder()
    }
}
