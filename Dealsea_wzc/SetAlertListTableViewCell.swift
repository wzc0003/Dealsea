//
//  SetAlertListTableViewCell.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit
import AFNetworking

class SetAlertListTableViewCell: UITableViewCell {

    let deleteBtnColor = UIColor(red: 230/255, green: 51/255, blue: 55/255, alpha: 1)

    let manager = AFHTTPSessionManager()
    var defaults = NSUserDefaults.standardUserDefaults()
    var reloadblock:((alert_id:String)->Void)?
    let BasicValue = UIScreen.mainScreen().bounds.size.width/640
    var alertid:String?
    
    lazy var alertLb:UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .Center
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.layer.borderColor = UIColor.lightGrayColor().CGColor
        label.backgroundColor = UIColor.whiteColor()
        return label
    }()
    lazy var deleteBtn:UIButton = {
        let button = UIButton(type: UIButtonType.System)
        button.backgroundColor = self.deleteBtnColor
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitle("Delete", forState: UIControlState.Normal)
        button.tintColor = UIColor.whiteColor()
        button.addTarget(self, action: #selector(SetAlertListTableViewCell.delBtnClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }()
    func delBtnClick(sender:UIButton){
        self.reloadblock!(alert_id: alertid!)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        SetupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func SetupUI(){
        self.contentView.addSubview(alertLb)
        alertLb.snp_makeConstraints { (make) in
            make.leading.equalTo(self.contentView)
            make.top.equalTo(self.contentView).offset(10*BasicValue)
            make.bottom.equalTo(self.contentView).offset(-10*BasicValue)
            make.width.equalTo(400*BasicValue)
        }
        self.contentView.addSubview(deleteBtn)
        deleteBtn.snp_makeConstraints { (make) in
            make.trailing.equalTo(self.contentView)
            make.top.bottom.equalTo(alertLb)
            make.leading.equalTo(alertLb.snp_trailing)
        }
    }
}
