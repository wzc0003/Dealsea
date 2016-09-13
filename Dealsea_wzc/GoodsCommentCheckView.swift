//
//  GoodsCommentCheckView.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit
import SnapKit
import MBProgressHUD

class GoodsCommentCheckView: UIView {

    var signinblock:(()->Void)?
    var anonyblock:(()->Void)?
    let margin = 40 * UIScreen.mainScreen().bounds.size.width/320
    let detailColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        let tap = UITapGestureRecognizer(target: self, action: #selector(GoodsCommentCheckView.hiddenView(_:)))
        self.addGestureRecognizer(tap)
        SetupUI()
    }
    
    func SetupUI(){
        self.addSubview(self.anybutton)
        self.addSubview(self.signinbutton)
        self.anybutton.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self).offset(margin)
            make.centerY.equalTo(self)
            make.height.equalTo(margin)
        }
        self.signinbutton.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.anybutton.snp_trailing)
            make.trailing.equalTo(self).offset(-margin)
            make.top.bottom.width.equalTo(self.anybutton)
        }
    }
    
    func hiddenView(tap:UITapGestureRecognizer){
        self.removeFromSuperview()
    }
    
    func anonyClick(sender:UIButton){
        self.removeFromSuperview()
        self.anonyblock!()
    }
    
    func SignInClick(sender:UIButton){
        self.removeFromSuperview()
        self.signinblock!()
    }
    
    lazy var anybutton:UIButton = {
        let button = UIButton(type: UIButtonType.System)
        button.backgroundColor = self.detailColor
        button.setTitle("As Anonymous", forState: .Normal)
        button.addTarget(self, action: #selector(GoodsCommentCheckView.anonyClick(_:)), forControlEvents: .TouchUpInside)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.blackColor().CGColor
        button.layer.masksToBounds = true
        return button
    }()
    lazy var signinbutton:UIButton = {
        let button = UIButton(type: UIButtonType.System)
        button.setTitle("Sign in", forState: .Normal)
        button.addTarget(self, action: #selector(GoodsCommentCheckView.SignInClick(_:)), forControlEvents: .TouchUpInside)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.backgroundColor = self.detailColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.blackColor().CGColor
        button.layer.masksToBounds = true
        return button
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
