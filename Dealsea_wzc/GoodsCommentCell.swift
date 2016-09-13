//
//  GoodsCommentCell.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit
import SnapKit

class GoodsCommentCell: UITableViewCell {

    let margin:CGFloat = 5
    let detailColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
    var line:UIView = UIView()
    
    var namelabel:UILabel?
    var timelabel:UILabel?
    var comlabel:UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        line.backgroundColor = detailColor
        self.contentView.addSubview(line)
        
        self.namelabel = UILabel()
        self.namelabel?.numberOfLines = 0
        self.namelabel?.textAlignment = .Left
        self.namelabel?.textColor = UIColor.blackColor()
        self.namelabel?.font = UIFont.systemFontOfSize(12)
        self.contentView.addSubview(self.namelabel!)
        self.namelabel?.snp_makeConstraints(closure: { (make) in
            make.top.leading.trailing.equalTo(self.contentView).offset(margin)
            make.height.equalTo(30)
        })
        
        
        self.timelabel = UILabel()
        self.timelabel?.numberOfLines = 1
        self.timelabel?.textAlignment = .Left
        self.timelabel?.textColor = detailColor
        self.timelabel?.font = UIFont.systemFontOfSize(12)
        self.contentView.addSubview(self.timelabel!)
        self.timelabel?.snp_makeConstraints(closure: { (make) in
            make.leading.trailing.equalTo(self.namelabel!)
            make.top.equalTo(self.namelabel!.snp_bottom).offset(margin)
            make.height.equalTo(30)
        })
        
        self.comlabel = UILabel()
        self.comlabel?.numberOfLines = 0
        self.comlabel?.textAlignment = .Left
        self.comlabel?.textColor = detailColor
        self.comlabel?.font = UIFont.systemFontOfSize(14)
        self.contentView.addSubview(self.comlabel!)
        self.comlabel?.snp_makeConstraints(closure: { (make) in
            make.leading.equalTo(self).offset(margin)
            make.trailing.equalTo(self).offset(-margin)
            make.top.equalTo(self.timelabel!.snp_bottom).offset(2*margin)
        })
        self.line.snp_makeConstraints { (make) in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(self.comlabel!.snp_bottom).offset(margin)
            make.height.equalTo(1)
        }
        self.contentView.snp_makeConstraints { (make) in
            make.bottom.equalTo(self.line.snp_bottom)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
