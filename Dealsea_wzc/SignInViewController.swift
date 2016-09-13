//
//  SignInViewController.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class SignInViewController: UIViewController {
    let loginUrl = "https://dealsea.com/profile/login?app=" + appVersion
    let backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
    let signinBtnColor = UIColor(red: 9/255, green: 187/255, blue: 7/255, alpha: 1)

    let margin = 50 * UIScreen.mainScreen().bounds.size.width/320
    let defaults = NSUserDefaults.standardUserDefaults()
    lazy var emailTextfield:UITextField = {
        let text = UITextField()
        text.placeholder = "email or username"
        text.borderStyle = .RoundedRect
        text.layer.borderWidth = 1
        text.layer.borderColor = UIColor.lightGrayColor().CGColor
        text.clearButtonMode = .WhileEditing
        return text
    }()
    lazy var pwdTextfield:UITextField = {
        let text = UITextField()
        text.placeholder = "password"
        text.secureTextEntry = true
        text.borderStyle = .RoundedRect
        text.layer.borderWidth = 1
        text.layer.borderColor = UIColor.lightGrayColor().CGColor
        text.clearButtonMode = .WhileEditing
        return text
    }()
    lazy var signinBtn:UIButton = {
        let text = UIButton(type: UIButtonType.System)
        text.setTitle("Sign in", forState: .Normal)
        text.titleLabel?.font = UIFont.systemFontOfSize(18)
        text.addTarget(self, action: #selector(SignInViewController.SignInClick(_:)), forControlEvents: .TouchUpInside)
        text.layer.borderWidth = 0
        text.layer.cornerRadius = 5
        text.layer.masksToBounds = true
        text.tintColor = UIColor.whiteColor()
        text.layer.backgroundColor = self.signinBtnColor.CGColor
        return text
    }()
    func register(sender:UIBarButtonItem){
        UIApplication.sharedApplication().openURL(NSURL(string: "https://dealsea.com/profile/confirm")!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColor
        let rightbtn = UIBarButtonItem(title: "Register", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SignInViewController.register(_:)))
        self.navigationItem.rightBarButtonItem = rightbtn
        SetupUI()
    }
    
    func SignInClick(sender:UIButton){
        
        let mbhud:MBProgressHUD = MBProgressHUD(view: self.view)
        mbhud.labelText = "Loading..."
        self.view.addSubview(mbhud)
        mbhud.show(true)
        self.view.endEditing(true)
        if self.emailTextfield.text?.characters.count >= 250 || self.pwdTextfield.text?.characters.count >= 250 {
               let alertvc = UIAlertController(title: "Warning", message: "The length of password or account is too long", preferredStyle: UIAlertControllerStyle.Alert)
            let alertcancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            alertvc.addAction(alertcancel)
            self.presentViewController(alertvc, animated: true, completion: nil)
            return
        }
        var dict:Dictionary<String,AnyObject> = Dictionary()
        dict["username"] = self.emailTextfield.text
        dict["password"] = self.pwdTextfield.text
        dict["login"] = "1"
        print(dict)

        
        if let devicetoken:String = defaults.objectForKey("deviceToken") as? String {
            dict["devicetoken"] = devicetoken
        }
        let manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as? Set<String>
        manager.POST(loginUrl, parameters: dict, progress: { (progress) -> Void in
            
            }, success: { (task, data) -> Void in
                let dict:[String:AnyObject] = data as! Dictionary
                if(data != nil){
                    mbhud.labelText = "Load Success"
                    mbhud.mode = .Text
                    mbhud.hide(true, afterDelay: 2.0)
                    if((dict["status"]) as! Float != 0){
                        let userid:String = dict["user_id"] as! String
                        self.defaults.setObject(self.emailTextfield.text, forKey: "username")
                        self.defaults.setObject(self.pwdTextfield.text, forKey: "password")
                        self.defaults.setObject(userid, forKey: "userid")
                        self.defaults.setObject(dict["user_avatar"], forKey: "avatar")
                        let dateformatter:NSDateFormatter = NSDateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let date:String = dateformatter.stringFromDate(NSDate())
                        self.defaults.setObject(date, forKey: "time")
                        self.defaults.synchronize()
                        self.navigationController?.popViewControllerAnimated(false)
                    }else{
                        mbhud.hide(true, afterDelay: 0)
                        let alertvc = UIAlertController(title: "Warning", message: "email or password is wrong?", preferredStyle: UIAlertControllerStyle.Alert)
                        let alertcancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
                        alertvc.addAction(alertcancel)
                        self.presentViewController(alertvc, animated: true, completion: nil)
                    }
                }
        }) { (task, error) -> Void in
            print(error.description)
            let alertvc = UIAlertController(title: "Warning", message: "Delete this Alert?", preferredStyle: UIAlertControllerStyle.ActionSheet)
            let alertcancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            alertvc.addAction(alertcancel)
            self.presentViewController(alertvc, animated: true, completion: nil)
        }
    }

    func SetupUI(){
        self.view.addSubview(self.emailTextfield)
        self.view.addSubview(self.pwdTextfield)
        self.view.addSubview(self.signinBtn)
        
        self.emailTextfield.snp_makeConstraints { (make) in
            make.leading.equalTo(self.view).offset(margin)
            make.top.equalTo(self.view).offset(2*margin)
            make.trailing.equalTo(self.view).offset(-margin)
            make.height.equalTo(margin/50*40)
        }
        self.pwdTextfield.snp_makeConstraints { (make) in
            make.leading.trailing.equalTo(self.emailTextfield)
            make.top.equalTo(self.emailTextfield.snp_bottom).offset(margin/50*20)
            make.height.equalTo(margin/50*40)
        }
        self.signinBtn.snp_makeConstraints { (make) in
            make.leading.trailing.equalTo(self.pwdTextfield)
            make.top.equalTo(self.pwdTextfield.snp_bottom).offset(margin/50*20)
            make.height.equalTo(margin/50*40)
        }
    }
}
