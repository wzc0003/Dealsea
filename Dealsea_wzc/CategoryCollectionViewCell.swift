//
//  CategoryCollectionViewCell.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    let detailColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
    lazy var label:UILabel = {
        var label:UILabel = UILabel()
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(14)
        label.layer.masksToBounds = true
        label.textColor = UIColor.blackColor()
        label.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1).CGColor

        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
