//
//  NotificationViewController.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {

    let backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
    let margin = UIScreen.mainScreen().bounds.size.width/320

    lazy var bgview:UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor.whiteColor()
        return bg
    }()
    
    lazy var notifiLb:UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.blackColor()
        lb.textAlignment = .Left
        return lb
    }()
    
    lazy var ableLb:UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.lightGrayColor()
        lb.textAlignment = .Right
        return lb
    }()
    
    lazy var noticeLb:UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.lightGrayColor()
        lb.textAlignment = .Left
        lb.numberOfLines = 0
        lb.lineBreakMode = .ByWordWrapping
        return lb
    }()
    func SetupUI(){
        self.view.addSubview(bgview)
        bgview.snp_makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(self.view).offset(80*margin)
            make.height.equalTo(40*margin)
        }
        
        self.view.addSubview(notifiLb)
        notifiLb.snp_makeConstraints { (make) in
            make.top.equalTo(self.bgview).offset(5*margin)
            make.bottom.equalTo(self.bgview).offset(-5*margin)
            make.leading.equalTo(self.bgview).offset(10*margin)
        }
        notifiLb.text = "Notifications"
        notifiLb.sizeToFit()
        
        self.view.addSubview(ableLb)
        ableLb.snp_makeConstraints { (make) in
            make.top.equalTo(self.bgview).offset(5*margin)
            make.bottom.equalTo(self.bgview).offset(-5*margin)
            make.trailing.equalTo(self.bgview).offset(-10*margin)
        }
        if UIApplication.sharedApplication().currentUserNotificationSettings()?.types == UIUserNotificationType.None{
            ableLb.text = "Disabled"
        }else{
            ableLb.text = "Enabled"
        }
        
        self.view.addSubview(noticeLb)
        noticeLb.snp_makeConstraints { (make) in
            make.leading.equalTo(self.view).offset(10*margin)
            make.trailing.equalTo(self.view).offset(-10*margin)
            make.top.equalTo(bgview.snp_bottom).offset(20*margin)
        }
        noticeLb.text = "Enable or disable Dealsea Notifications via \"Settings\"->\"Notifications\" on your iPhone."
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColor
        SetupUI()
    }

}
