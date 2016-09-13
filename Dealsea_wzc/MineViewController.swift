//
//  MineViewController.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit
import SnapKit

class MineViewController: UIViewController {
    
    let signoutBtnColor = UIColor(red: 230/255, green: 51/255, blue: 55/255, alpha: 1)

    var defaults = NSUserDefaults.standardUserDefaults()
    let backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
    let BasicValue = UIScreen.mainScreen().bounds.size.width/320
    var dataarray:[MeSignInModel]?
    var scrollview:UIScrollView?
    var headerimage:UIImageView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        if (defaults.objectForKey("username") == nil){
            self.signinbutton.setTitle("Sign in", forState: UIControlState.Normal)
            self.signinbutton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
            self.headerimage.hidden = true
            self.arrow3.hidden = false
            self.signinbutton.tag = 0
            self.signoutbutton.hidden = true
            self.signinbutton.enabled = true
        }else{
            self.signinbutton.setTitle("\(defaults.objectForKey("username") as! String)", forState: UIControlState.Normal)
            self.signinbutton.contentEdgeInsets = UIEdgeInsetsMake(0, 100, 0, 0)
            self.headerimage.hidden = false
            self.arrow3.hidden = true
            self.signinbutton.tag = 1
            self.signinbutton.enabled = false
            self.signoutbutton.hidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None
        navigationItem.title = "Me"
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.view.backgroundColor = backgroundColor
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        
        SetupData()
        SetupUI()
        if (defaults.objectForKey("username") == nil){
            self.signinbutton.setTitle("Sign in", forState: UIControlState.Normal)
            self.signinbutton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
            self.headerimage.hidden = true
            self.arrow3.hidden = false
            self.signinbutton.tag = 0
            self.signoutbutton.hidden = true
            self.signinbutton.enabled = true
        }else{
            self.signinbutton.setTitle("\(defaults.objectForKey("username") as! String)", forState: UIControlState.Normal)
            self.signinbutton.contentEdgeInsets = UIEdgeInsetsMake(0, 100, 0, 0)
            self.headerimage.hidden = false
            self.arrow3.hidden = true
            self.signinbutton.tag = 1
            self.signinbutton.enabled = false
            self.signoutbutton.hidden = false
        }
    }
    func SetupData(){
        let tmparray = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("MeSignInCell.plist", ofType: nil)!)
        dataarray = [MeSignInModel]()
        for dict in tmparray!
        {
            let model:MeSignInModel = MeSignInModel(dict: dict as! [String : AnyObject])
            dataarray?.append(model)
        }
    }
    func SetupUI(){
    
        self.scrollview = UIScrollView(frame: self.view.bounds)
        scrollview?.backgroundColor = backgroundColor
        self.view.addSubview(scrollview!)
        
        
        self.scrollview?.addSubview(signinbutton)
        self.scrollview?.addSubview(setalertbutton)
        self.scrollview?.addSubview(notifibutton)
        self.scrollview?.addSubview(signoutbutton)
        self.scrollview?.addSubview(arrow1)
        self.scrollview?.addSubview(arrow2)
        self.scrollview?.addSubview(arrow3)
        
        self.signinbutton.snp_makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(self.view).offset(10 * BasicValue)
            make.height.equalTo(60*BasicValue)
        }
        self.notifibutton.snp_makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(self.signinbutton.snp_bottom).offset(40 * BasicValue)
            make.height.equalTo(40*BasicValue)
        }
        self.setalertbutton.snp_makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(self.notifibutton.snp_bottom).offset(20 * BasicValue)
            make.height.equalTo(40*BasicValue)
        }
        self.signoutbutton.snp_makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(self.setalertbutton.snp_bottom).offset(40 * BasicValue)
            make.height.equalTo(40*BasicValue)
        }
        self.arrow1.snp_makeConstraints { (make) in
            make.trailing.equalTo(self.notifibutton).offset(-5*BasicValue)
            make.top.equalTo(self.notifibutton).offset(10*BasicValue)
            make.height.equalTo(20*BasicValue)
            make.width.equalTo(20*BasicValue)
        }
        self.arrow2.snp_makeConstraints { (make) in
            make.trailing.equalTo(self.setalertbutton).offset(-5*BasicValue)
            make.top.equalTo(self.setalertbutton).offset(10*BasicValue)
            make.height.equalTo(20*BasicValue)
            make.width.equalTo(20*BasicValue)
        }
        self.arrow3.snp_makeConstraints { (make) in
            make.trailing.equalTo(self.signinbutton).offset(-5*BasicValue)
            make.top.equalTo(self.signinbutton).offset(20*BasicValue)
            make.height.equalTo(20*BasicValue)
            make.width.equalTo(20*BasicValue)
        }
        
        headerimage = UIImageView(image: UIImage(named: "man"))
        self.view.addSubview(headerimage)
        headerimage.snp_makeConstraints { (make) in
            make.leading.top.equalTo(self.signinbutton).offset(5*BasicValue)
            make.height.width.equalTo(50*BasicValue)
        }
    }
    
    func setNavigationController(){
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }

    func signinbtnClick(sender:UIButton){
        let vc = SignInViewController()
        self.tabBarController?.tabBar.hidden = true
        vc.navigationItem.title = "Sign in"
        self.navigationController?.pushViewController(vc, animated: true)
        setNavigationController()
    }
    func setalertbtnClick(sender:UIButton){
        self.tabBarController?.tabBar.hidden = true
        if (defaults.objectForKey("username") == nil){
            let vc = SignInViewController()
            vc.navigationItem.title = "Sign in"
            self.navigationController?.pushViewController(vc, animated: true)
            /////arrow3.hidden = false
            setNavigationController()
        }else{
            /////arrow3.hidden = true
            if UIApplication.sharedApplication().currentUserNotificationSettings()?.types == UIUserNotificationType.None{
                let vc = NotificationViewController()
                vc.navigationItem.title = "Notifications"
                self.navigationController?.pushViewController(vc, animated: true)
                setNavigationController()
            }else{
                let vc = SetAlertViewController()
                vc.navigationItem.title = "Set Alert"
                self.navigationController?.pushViewController(vc, animated: true)
                setNavigationController()
            }
        }
    }
    func notifibtnClick(sender:UIButton){
        let vc = NotificationViewController()
        self.tabBarController?.tabBar.hidden = true
        vc.navigationItem.title = "Notifications"
        self.navigationController?.pushViewController(vc, animated: true)
        setNavigationController()
    }

    func signoutbtnClick(sender:UIButton){
        self.defaults.removeObjectForKey("username")
        self.defaults.removeObjectForKey("password")
        self.defaults.removeObjectForKey("userid")
        self.defaults.removeObjectForKey("time")
        self.defaults.removeObjectForKey("avatar")
        self.defaults.synchronize()
        if (defaults.objectForKey("username") == nil){
            self.signinbutton.setTitle("Sign in", forState: UIControlState.Normal)
            self.signinbutton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
            self.headerimage.hidden = true
            self.arrow1.hidden = false
            self.signinbutton.tag = 0
            self.signoutbutton.hidden = true
            self.signinbutton.enabled = true
            self.arrow3.hidden = false
        }else{
            self.signinbutton.setTitle("\(defaults.objectForKey("username") as! String)", forState: UIControlState.Normal)
            self.signinbutton.contentEdgeInsets = UIEdgeInsetsMake(0, 100, 0, 0)
            self.headerimage.hidden = false
            self.arrow1.hidden = true
            self.signinbutton.tag = 1
            self.signoutbutton.hidden = false
            self.signinbutton.enabled = false
            self.arrow3.hidden = true
        }
    }
    
    lazy var signinbutton:UIButton = {
        let btn = UIButton(type: UIButtonType.System)
        btn.addTarget(self, action: #selector(MineViewController.signinbtnClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        btn.layer.masksToBounds = true
        btn.contentHorizontalAlignment = .Left
        btn.contentEdgeInsets  = UIEdgeInsetsMake(0, 10, 0, 0)
        btn.backgroundColor = UIColor.whiteColor()
        btn.setTitle("Sign in", forState: UIControlState.Normal)
        btn.tintColor = UIColor.blackColor()
        btn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Disabled)
        btn.titleLabel?.font = UIFont.systemFontOfSize(25)
        return btn
    }()
    lazy var setalertbutton:UIButton = {
        let btn = UIButton(type: UIButtonType.System)
        btn.addTarget(self, action: #selector(MineViewController.setalertbtnClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        btn.contentHorizontalAlignment = .Left
        btn.contentEdgeInsets  = UIEdgeInsetsMake(0, 10, 0, 0)
        btn.layer.masksToBounds = true
        btn.backgroundColor = UIColor.whiteColor()
        btn.setTitle("Set Alert", forState: UIControlState.Normal)
        btn.tintColor = UIColor.blackColor()
        btn.titleLabel?.font = UIFont.systemFontOfSize(18)
        return btn
    }()
    lazy var notifibutton:UIButton = {
        let btn = UIButton(type: UIButtonType.System)
        btn.addTarget(self, action: #selector(MineViewController.notifibtnClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        btn.contentHorizontalAlignment = .Left
        btn.contentEdgeInsets  = UIEdgeInsetsMake(0, 10, 0, 0)
        btn.layer.masksToBounds = true
        btn.backgroundColor = UIColor.whiteColor()
        btn.setTitle("Notifications", forState: UIControlState.Normal)
        btn.tintColor = UIColor.blackColor()
        btn.titleLabel?.font = UIFont.systemFontOfSize(18)
        return btn
    }()
    lazy var signoutbutton:UIButton = {
        let btn = UIButton(type: UIButtonType.System)
        btn.addTarget(self, action: #selector(MineViewController.signoutbtnClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        btn.layer.masksToBounds = true
        btn.backgroundColor = self.signoutBtnColor
        btn.setTitle("Sign Out", forState: UIControlState.Normal)
        btn.tintColor = UIColor.whiteColor()
        btn.titleLabel?.font = UIFont.systemFontOfSize(18)
        return btn
    }()
    
    lazy var arrow1:UIImageView = {
        let imgv = UIImageView(image: UIImage(named: "arrow"))
        imgv.backgroundColor = UIColor.clearColor()
        return imgv
    }()
    lazy var arrow2:UIImageView = {
        let imgv = UIImageView(image: UIImage(named: "arrow"))
        imgv.backgroundColor = UIColor.clearColor()
        return imgv
    }()
    lazy var arrow3:UIImageView = {
        let imgv = UIImageView(image: UIImage(named: "arrow"))
        imgv.backgroundColor = UIColor.clearColor()
        return imgv
    }()
}
