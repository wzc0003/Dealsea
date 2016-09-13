//
//  NewGoodsViewController.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class NewGoodsViewController: UIViewController,UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource {
    
    let redio:CGFloat = UIScreen.mainScreen().bounds.size.width/320
    let detailColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
    var defaults = NSUserDefaults.standardUserDefaults()
    var myContext = 0
    var commentData:[GoodsCommentViewModel] = [GoodsCommentViewModel]()
    
    var bgscrollview:UIScrollView!
    var imgview:UIImageView!
    var nameLabel:UILabel!
    var merchantLabel:UILabel!
    var timeLabel:UILabel!
    lazy var topline:UIView = {
        let line = UIView()
        line.backgroundColor = self.detailColor
        return line
    }()
    lazy var bottomline:UIView = {
        let line = UIView()
        line.backgroundColor = self.detailColor
        return line
    }()
    lazy var commentcountLabel:UILabel = {
        let label = UILabel()
        label.textColor = UIColor.blackColor()
        label.backgroundColor = UIColor.whiteColor()
        label.textAlignment = .Left
        label.font = UIFont.systemFontOfSize(14)
        label.numberOfLines = 1
        return label
    }()
    lazy var addcommentButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.setTitleColor(UIColor(red: 9/255, green: 187/255, blue: 7/255, alpha: 1), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(14)
        button.addTarget(self, action: #selector(NewGoodsViewController.commentButtonClick(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    
    var webview:UIWebView!
    var tableview:UITableView!
    
    var goodModel:DeaList = DeaList(){
        didSet{
            commentButton.enabled = goodModel.allowComment.hasPrefix("0") ? false:true
            addcommentButton.enabled = goodModel.allowComment.hasPrefix("0") ? false:true
            imgview?.sd_setImageWithURL(NSURL(string:goodModel.image[0]), placeholderImage: UIImage(named: "goods"))
            if(goodModel.expired == 0){
                let attr:NSAttributedString = NSAttributedString(string: goodModel.title)
                nameLabel.attributedText = attr
            }else{
                let attr:NSMutableAttributedString = NSMutableAttributedString(string: "(Expired) \(goodModel.title)")
                attr.addAttributes([NSForegroundColorAttributeName:UIColor.redColor()], range: NSMakeRange(0, 9))
                nameLabel.attributedText = attr
            }
            merchantLabel.text = "\(goodModel.merchant[1])"
            timeLabel.text = goodModel.post_time
            commentcountLabel.text = "Comments \(goodModel.comment_count)"
            webview.loadRequest(NSURLRequest(URL: NSURL(string: "https://dealsea.com/view-deal/\(goodModel.post_id)?app=\(appVersion)&display=web")!))
            commentButton.setTitle("Comments \(goodModel.comment_count)", forState: .Normal)
            
//            commentButton.sizeToFit()
            nameLabel.sizeToFit()
            nameLabel.frame = CGRect(x: 10*redio, y: CGRectGetMaxY(imgview.frame)+10*redio, width: nameLabel.frame.size.width, height: nameLabel.frame.size.height)
            merchantLabel.sizeToFit()
            merchantLabel.frame = CGRect(x: nameLabel.frame.origin.x, y: CGRectGetMaxY(nameLabel.frame) + 10*redio, width: merchantLabel.frame.size.width, height: merchantLabel.frame.size.height)
            timeLabel.sizeToFit()
            timeLabel.frame = CGRect(x: view.frame.size.width - timeLabel.frame.size.width - 10*redio, y: merchantLabel.frame.origin.y, width: timeLabel.frame.size.width, height: timeLabel.frame.size.height)
            topline.frame = CGRect(x: 0, y: CGRectGetMaxY(merchantLabel.frame) + 5*redio, width: view.frame.size.width, height: 1)
            webview.frame = CGRect(x: 0, y: CGRectGetMaxY(topline.frame) + 10*redio, width: view.frame.size.width, height: 100)
            bottomline.frame = CGRect(x: 0, y: CGRectGetMaxY(webview.frame) + 10*redio, width: view.frame.size.width, height: 1)
            commentcountLabel.sizeToFit()
            commentcountLabel.frame = CGRect(x: 10*redio, y: 10*redio + CGRectGetMaxY(bottomline.frame), width: commentcountLabel.frame.size.width, height: commentcountLabel.frame.size.height)
            if(goodModel.comment_count == 0){
                addcommentButton.setTitle("Add your comment >", forState: .Normal)
                addcommentButton.sizeToFit()
                addcommentButton.center = CGPoint(x: view.frame.size.width/2, y: CGRectGetMaxY(commentcountLabel.frame) + 10*redio + addcommentButton.frame.size.height/2)
                bgscrollview.contentSize = CGSize(width: commentcountLabel.frame.size.width, height: CGRectGetMaxY(addcommentButton.frame) + 20*redio)
            }else{
                //                 self.tableview.frame = CGRect(x: 0, y: CGRectGetMaxY(self.commentcountLabel.frame) + 10*self.redio, width: self.view.frame.size.width, height: 100)
                addcommentButton.hidden = true
                loadComment()
            }
        }
    }
    
    
    func loadComment(){
        let manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as? Set<String>
        manager.POST("https://dealsea.com/view-deal/\(goodModel.post_id)?app=\(appVersion)&display=comments", parameters: nil, progress: { (progress) in
            
            }, success: { (task, data) in
                self.addcommentButton.hidden = false
                let dict:[String:AnyObject] = data as! Dictionary
                if((data?.isKindOfClass(NSDictionary.self)) != nil){
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
                            self.commentData.append(model)
                        }
                    })
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableview.reloadData()
                        self.webview.frame = CGRect(x: 0, y: CGRectGetMaxY(self.topline.frame) + 10*self.redio, width: self.webview.scrollView.contentSize.width, height: self.webview.scrollView.contentSize.height)
                        self.bottomline.frame = CGRect(x: 0, y: CGRectGetMaxY(self.webview.frame) + 10*self.redio, width: self.view.frame.size.width, height: 1)
                        self.commentcountLabel.frame = CGRect(x: 10*self.redio, y: 10*self.redio + CGRectGetMaxY(self.bottomline.frame), width: self.commentcountLabel.frame.size.width, height: self.commentcountLabel.frame.size.height)
                        self.tableview.frame = CGRect(x: 0, y: CGRectGetMaxY(self.commentcountLabel.frame) + 10*self.redio, width: self.view.frame.size.width, height: self.tableview.contentSize.height)
                        self.addcommentButton.setTitle("See more comments >", forState: .Normal)
                        self.addcommentButton.sizeToFit()
                        self.addcommentButton.center = CGPoint(x: self.view.frame.size.width/2, y: CGRectGetMaxY(self.tableview.frame) + 5*(self.redio) + self.addcommentButton.frame.size.height/2)
                        self.bgscrollview.contentSize = CGSize(width: self.commentcountLabel.frame.size.width, height: CGRectGetMaxY(self.addcommentButton.frame) + 20*self.redio)
                    })
                }
        }) { (task, error) in
            self.addcommentButton.hidden = false
            print(error.description)
        }
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SetupUI()
    }
    
    deinit{
        webview.scrollView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    func SetupUI(){
        bgscrollview = UIScrollView(frame: CGRect(x: 0, y: 64, width: view.bounds.size.width, height: view.bounds.size.height - 64 - 44))
        bgscrollview.contentSize = bgscrollview.frame.size
        
        self.imgview = UIImageView(frame: CGRect(x: 130, y: 10*redio, width: 130, height: 130))
        self.imgview?.center.x = (self.view.frame.size.width)/2
        self.imgview?.contentMode = UIViewContentMode.ScaleAspectFit
        self.imgview.clipsToBounds = true
        bgscrollview.addSubview(imgview)
        
        nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width - 20*redio, height: 20))
        nameLabel.backgroundColor = UIColor.clearColor()
        nameLabel.textAlignment = .Left
        nameLabel.numberOfLines = 0
        nameLabel.textColor = UIColor.blackColor()
        nameLabel.font = UIFont.systemFontOfSize(16)
        bgscrollview.addSubview(nameLabel)
        
        merchantLabel = UILabel()
        merchantLabel.backgroundColor = UIColor.clearColor()
        merchantLabel.textAlignment = .Left
        merchantLabel.textColor = self.detailColor
        merchantLabel.font = UIFont.systemFontOfSize(12)
        bgscrollview.addSubview(merchantLabel)
        
        timeLabel = UILabel()
        timeLabel.backgroundColor = UIColor.clearColor()
        timeLabel.textAlignment = .Left
        timeLabel.textColor = self.detailColor
        timeLabel.font = UIFont.systemFontOfSize(12)
        bgscrollview.addSubview(timeLabel)
        
        webview = UIWebView()
        webview.frame = CGRect(x: 0, y: 200, width: UIScreen.mainScreen().bounds.size.width, height: 10)
        webview.delegate = self
        webview.scrollView.bounces = false
        webview.backgroundColor = UIColor.clearColor()
        webview.scrollView.addObserver(self, forKeyPath: "contentSize", options: [.New,.Old], context: &myContext)
        bgscrollview.addSubview(webview)
        
        bgscrollview.addSubview(topline)
        bgscrollview.addSubview(bottomline)
        bgscrollview.addSubview(commentcountLabel)
        bgscrollview.addSubview(addcommentButton)
        
        tableview = UITableView(frame: CGRectZero, style: .Plain)
        tableview.separatorStyle = .None
        tableview.delegate = self
        tableview.dataSource = self
        tableview.registerClass(GoodCommentTableViewCell.self, forCellReuseIdentifier: "commentcell")
        tableview.bounces = false
        bgscrollview.addSubview(tableview)
        
        view.addSubview(bgscrollview)
        self.view.addSubview(commentButton)
        self.view.addSubview(shareButton)
        self.view.addSubview(setalertButton)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        dispatch_async(dispatch_get_main_queue()) {
            self.webview.frame = CGRect(x: 0, y: CGRectGetMaxY(self.topline.frame) + 10*self.redio, width: self.webview.scrollView.contentSize.width, height: self.webview.scrollView.contentSize.height)
            self.bottomline.frame = CGRect(x: 0, y: CGRectGetMaxY(self.webview.frame) + 10*self.redio, width: self.view.frame.size.width, height: 1)
            self.commentcountLabel.frame = CGRect(x: 10*self.redio, y: 10*self.redio + CGRectGetMaxY(self.bottomline.frame), width: self.commentcountLabel.frame.size.width, height: self.commentcountLabel.frame.size.height)
            if(self.goodModel.comment_count == 0){
                self.addcommentButton.setTitle("Add your comment >", forState: .Normal)
                self.addcommentButton.sizeToFit()
                self.addcommentButton.center = CGPoint(x: self.view.frame.size.width/2, y: CGRectGetMaxY(self.commentcountLabel.frame) + 10*self.redio + self.addcommentButton.frame.size.height/2)
                self.bgscrollview.contentSize = CGSize(width: self.commentcountLabel.frame.size.width, height: CGRectGetMaxY(self.addcommentButton.frame) + 20*self.redio)
            }else{
                self.tableview.frame = CGRect(x: 0, y: CGRectGetMaxY(self.commentcountLabel.frame) + 10*self.redio, width: self.view.frame.size.width, height: self.tableview.contentSize.height)
                self.addcommentButton.setTitle("See more comments >", forState: .Normal)
                self.addcommentButton.sizeToFit()
                self.addcommentButton.center = CGPoint(x: self.view.frame.size.width/2, y: CGRectGetMaxY(self.tableview.frame) + 5*(self.redio) + self.addcommentButton.frame.size.height/2)
                self.bgscrollview.contentSize = CGSize(width: self.commentcountLabel.frame.size.width, height: CGRectGetMaxY(self.addcommentButton.frame) + 20*self.redio)
            }
        }
    }
    
    lazy var commentButton:goodsViewBottomButton = {
        let button:goodsViewBottomButton = goodsViewBottomButton(type: .Custom)
        button.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(11)
        button.frame = CGRect(x: 0, y: self.view.frame.height - 44, width: self.view.frame.size.width/3, height: 44)
        button.setImage(UIImage(named: "comment"), forState: .Normal)
        //button.setTitle("Comment(\(self.commentCount))", forState: .Normal)
        button.setTitleColor(UIColor.grayColor(), forState: .Disabled)
        button.addTarget(self, action: #selector(NewGoodsViewController.commentButtonClick(_:)), forControlEvents: .TouchUpInside)
        button.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        button.layer.borderColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1).CGColor
        button.layer.borderWidth = 0.5
        return button
    }()
    
    func commentButtonClick(sender:goodsViewBottomButton){
        let vc = GoodsCommentViewController(post_id: goodModel.post_id)
        vc.goodTitle = goodModel.title
        vc.navigationItem.title = "Comments"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    lazy var shareButton:goodsViewBottomButton = {
        let button:goodsViewBottomButton = goodsViewBottomButton(type: .Custom)
        button.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(11)
        button.setImage(UIImage(named: "share"), forState: .Normal)
        button.setTitle("Share", forState: .Normal)
//        button.sizeToFit()
        button.frame = CGRect(x: self.view.frame.size.width/3, y: self.view.frame.height - 44, width: self.view.frame.size.width/3, height: 44)
        //button.setTitle("Share", forState: .Normal)
        button.addTarget(self, action: #selector(NewGoodsViewController.shareButtonClick(_:)), forControlEvents: .TouchUpInside)
        button.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        button.layer.borderColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1).CGColor
        button.layer.borderWidth = 0.5
        return button
    }()
    
    func shareButtonClick(sender:goodsViewBottomButton){
        var array:[AnyObject] = [AnyObject]()
        array.append(nameLabel.text!)
        array.append( self.imgview.image!)
        array.append(NSURL(string: "https://dealsea.com/view-deal/\(goodModel.post_id)")!)
        let cludeActivitys = [
            // 打印
            UIActivityTypePrint,
            // 设置联系人图片
            UIActivityTypeAssignToContact,
            ]
        let activityVC:UIActivityViewController = UIActivityViewController(activityItems: array, applicationActivities: nil)
        activityVC.excludedActivityTypes = cludeActivitys
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    lazy var setalertButton:goodsViewBottomButton = {
        let button:goodsViewBottomButton = goodsViewBottomButton(type: .Custom)
        button.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
         button.titleLabel?.font = UIFont.systemFontOfSize(11)
        button.frame = CGRect(x: self.view.frame.size.width/3*2, y: self.view.frame.height - 44, width: self.view.frame.size.width/3, height: 44)
        button.setImage(UIImage(named: "alert2"), forState: .Normal)
        button.setTitle("Alert", forState: .Normal)
//        button.sizeToFit()
        //button.setTitle("Set Alert", forState: .Normal)
        button.addTarget(self, action: #selector(NewGoodsViewController.setAlertButtonClick(_:)), forControlEvents: .TouchUpInside)
        button.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        button.layer.borderColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1).CGColor
        button.layer.borderWidth = 0.5
        return button
    }()
    
    func setAlertButtonClick(sender:goodsViewBottomButton){
        if (defaults.objectForKey("username") == nil){
            let vc = SignInViewController()
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
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        webview.hidden = false
        print(request.URL?.absoluteString)
        if((request.URL?.absoluteString.hasPrefix("about:blank")) == true || request.URL?.absoluteString.rangeOfString("https://dealsea.com/view-deal/\(goodModel.post_id)?app=\(appVersion)&display=web") != nil){
            return true
        }
        UIApplication.sharedApplication().openURL(request.URL!)
        return false
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        dispatch_async(dispatch_get_main_queue()) {
            self.webview.frame = CGRect(x: 0, y: CGRectGetMaxY(self.topline.frame) + 10*self.redio, width: webView.scrollView.contentSize.width, height: webView.scrollView.contentSize.height)
            self.bottomline.frame = CGRect(x: 0, y: CGRectGetMaxY(webView.frame) + 10*self.redio, width: self.view.frame.size.width, height: 1)
            self.commentcountLabel.frame = CGRect(x: 10*self.redio, y: 10*self.redio + CGRectGetMaxY(self.bottomline.frame), width: self.commentcountLabel.frame.size.width, height: self.commentcountLabel.frame.size.height)
            if(self.goodModel.comment_count == 0){
                self.addcommentButton.setTitle("Add your comment >", forState: .Normal)
                self.addcommentButton.sizeToFit()
                self.addcommentButton.center = CGPoint(x: self.view.frame.size.width/2, y: CGRectGetMaxY(self.commentcountLabel.frame) + 10*self.redio + self.addcommentButton.frame.size.height/2)
                self.bgscrollview.contentSize = CGSize(width: self.commentcountLabel.frame.size.width, height: CGRectGetMaxY(self.addcommentButton.frame) + 20*self.redio)
            }else{
                self.tableview.frame = CGRect(x: 0, y: CGRectGetMaxY(self.commentcountLabel.frame) + 10*self.redio, width: self.view.frame.size.width, height: self.tableview.contentSize.height)
                self.addcommentButton.setTitle("See more comments >", forState: .Normal)
                self.addcommentButton.sizeToFit()
                self.addcommentButton.center = CGPoint(x: self.view.frame.size.width/2, y: CGRectGetMaxY(self.tableview.frame) + 10*(self.redio) + self.addcommentButton.frame.size.height/2)
                self.bgscrollview.contentSize = CGSize(width: self.commentcountLabel.frame.size.width, height: CGRectGetMaxY(self.addcommentButton.frame) + 20*self.redio)
            }
        }
    }
    
    //MARK:
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70 + commentData[indexPath.row].commentHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentData.count > 3 ? 3:commentData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:GoodCommentTableViewCell = tableview.dequeueReusableCellWithIdentifier("commentcell", forIndexPath: indexPath) as! GoodCommentTableViewCell
        cell.selectionStyle = .None
        cell.celldataModel = commentData[indexPath.row]
        return cell
    }
    
    //MARK:
}
