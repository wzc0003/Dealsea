//
//  DealseaTableViewCell.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit

class DealseaTableViewCell: UITableViewCell {

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
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(merchantlabel)
        merchantlabel.textColor = detailColor
        merchantlabel.font = UIFont.systemFontOfSize(11)
        merchantlabel.textAlignment = .Center
        
        commentImage.image = UIImage(named: "commentView")
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
        imageView?.frame = CGRectMake(3*margin, 25/2, 75,  75)
        
        textLabel?.frame.size.width = contentView.frame.size.width - CGRectGetMaxX((imageView?.frame)!) - 2*margin
        textLabel?.numberOfLines = 3
        textLabel?.sizeToFit()
        textLabel?.frame = CGRectMake(CGRectGetMaxX((imageView?.frame)!)+margin, margin + 5, (textLabel?.frame.size.width)!,(textLabel?.frame.size.height)!)
        
        commentImage.frame = CGRectMake(CGRectGetMaxX((imageView?.frame)!)+margin, self.contentView.frame.size.height - 3*margin - 3 - timelabel.bounds.size.height + 10, 15,15)
        
        commentlabel.frame = CGRectMake(CGRectGetMaxX(commentImage.frame) + margin, self.contentView.frame.size.height - 3*margin - 2 - timelabel.bounds.size.height + 10, commentlabel.bounds.size.width, commentlabel.bounds.size.height)
        
        detailTextLabel?.frame = CGRectMake(CGRectGetMaxX((commentlabel.frame))+2*margin, self.contentView.frame.size.height - 4*margin-1-timelabel.bounds.size.height + 10, UIScreen.mainScreen().bounds.size.width/3-2*margin, 20)
        
        
        timelabel.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - margin - timelabel.bounds.size.width, self.contentView.frame.size.height - 3*margin - 2 - timelabel.bounds.size.height + 10, timelabel.bounds.size.width, timelabel.bounds.size.height)
        
        
        line.frame = CGRectMake(2*margin, self.contentView.frame.height - 1, self.contentView.frame.width, 1)
    }
}
