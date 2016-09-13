//
//  goodsViewBottomButton.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit

class goodsViewBottomButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.contentMode = .ScaleToFill
        imageView?.frame = CGRect(x: self.frame.size.width/2 - self.frame.size.height/4, y: 5, width: self.frame.size.height/2, height: self.frame.size.height/2)
        titleLabel?.frame = CGRect(x: self.frame.size.width/2 - (titleLabel?.frame.size.width)!/2, y: CGRectGetMaxY((imageView?.frame)!), width: (titleLabel?.frame.size.width)!, height: self.frame.size.height/2 - 5)
    }
}
