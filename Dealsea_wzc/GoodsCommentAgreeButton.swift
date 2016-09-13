//
//  GoodsCommentAgreeButton.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit

class GoodsCommentAgreeButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.contentMode = .ScaleAspectFill
        imageView?.clipsToBounds = true
        if((imageView?.frame.size.height) != 0){
            imageView?.frame = CGRect(x: 0, y: 0, width: (imageView?.frame.size.width)!/(imageView?.frame.size.height)!*(titleLabel?.frame.size.height)!, height: (titleLabel?.frame.size.height)!)
            titleLabel?.center = CGPoint(x: self.frame.size.width - (titleLabel?.frame.size.width)!/2, y: self.frame.size.height/2)
            imageView?.center = CGPoint(x: CGRectGetMinX((titleLabel?.frame)!) - imageView!.frame.size.width/2 - 5, y: self.frame.size.height/2)
        }
//        titleLabel?.frame = CGRect(x: CGRectGetMaxX((imageView?.frame)!)+5, y: 0, width: (titleLabel?.frame.size.width)!, height: (titleLabel?.frame.size.height)!)
//        titleLabel?.center = CGPoint(x: (titleLabel?.center.x)!, y: self.frame.size.height/2)
    }

}
