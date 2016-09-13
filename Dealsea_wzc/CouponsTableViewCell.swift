//
//  CouponsTableViewCell.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit

class CouponsTableViewCell: UITableViewCell {

    let margin:CGFloat = 5
    var merchantlabel:UILabel = UILabel()
    var timelabel:UILabel = UILabel()
    var commentlabel:UILabel = UILabel()
    var commentImage:UIImageView = UIImageView()
    var line:UIView = UIView()
    
    let detailColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(merchantlabel)
        merchantlabel.textColor = detailColor
        merchantlabel.font = UIFont.systemFontOfSize(11)
        merchantlabel.textAlignment = .Center
        
        commentImage.image = UIImage(named: "comment")
        self.contentView.addSubview(commentImage)
        
        self.contentView.addSubview(commentlabel)
        commentlabel.textColor = detailColor
        commentlabel.font = UIFont.systemFontOfSize(11)
        commentlabel.textAlignment = .Center
        self.contentView.addSubview(timelabel)
        timelabel.textColor = detailColor
        timelabel.font = UIFont.systemFontOfSize(11)
        timelabel.textAlignment  = .Center
        self.contentView.addSubview(line)
        line.backgroundColor = detailColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.frame = CGRectMake(margin, margin, contentView.frame.size.height - 2*margin + 3*margin,  contentView.frame.size.height - 2*margin)
        
        textLabel?.frame = CGRectMake(CGRectGetMaxX((imageView?.frame)!)+margin, margin, contentView.frame.size.width - CGRectGetMaxX((imageView?.frame)!) - 2*margin, contentView.frame.size.height/2 - 2*margin)
        
        commentImage.frame = CGRectMake(CGRectGetMaxX((imageView?.frame)!)+margin, contentView.frame.size.height/2, 20,20)
        
        commentlabel.frame = CGRectMake(CGRectGetMaxX(commentImage.frame) + margin, contentView.frame.size.height/2 + 2, commentlabel.bounds.size.width, commentlabel.bounds.size.height)
        
        detailTextLabel?.frame = CGRectMake(CGRectGetMaxX((commentlabel.frame))+margin, contentView.frame.size.height/2-2*margin-1, (detailTextLabel?.bounds.size.width)!, contentView.frame.size.height/2 - 2*margin)
        
        timelabel.frame = CGRectMake(CGRectGetMaxX((imageView?.frame)!)+margin, self.contentView.frame.size.height - 4*margin, timelabel.bounds.size.width, timelabel.bounds.size.height)
        
        line.frame = CGRectMake(2*margin, self.contentView.frame.height - 1, self.contentView.frame.width, 1)
        
    }
}
