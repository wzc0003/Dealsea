//
//  GoodCommentTableViewCell.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit
import AFNetworking

class GoodCommentTableViewCell: UITableViewCell {

    let laberColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
    let tableViewbackgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
    var redio:CGFloat = UIScreen.mainScreen().bounds.size.width/320
    var margin:CGFloat = 5
    var reloadblock:(()->Void)?
    var celldataModel:GoodsCommentViewModel = GoodsCommentViewModel(){
        didSet{
            let attrStr = try! NSMutableAttributedString(
                data: "\(celldataModel.dataArray[0])".dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
                options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                documentAttributes: nil)
            attrStr.addAttributes([NSFontAttributeName:UIFont.systemFontOfSize(15)], range: NSMakeRange(0, attrStr.string.characters.count))
            commentlabel.attributedText = attrStr
            timelabel.text = celldataModel.dataArray[1]
            timelabel.sizeToFit()
            timelabel.layer.cornerRadius = timelabel.frame.size.height/4
            timelabel.layer.masksToBounds = true
            namelabel.text = celldataModel.dataArray[2]
            namelabel.sizeToFit()
            agreeButton.setTitle("\(celldataModel.dataArray[4])  ", forState: .Normal)
            agreeButton.sizeToFit()
            headImgView.sd_setImageWithURL(NSURL(string: celldataModel.dataArray[6]), placeholderImage: UIImage(named: "man"))
            dispatch_async(dispatch_get_main_queue()) {
                self.layoutIfNeeded()
            }
        }
    }
    lazy var headImgView:UIImageView = {
        let imagev = UIImageView()
        imagev.contentMode = .ScaleAspectFill
        imagev.clipsToBounds = true
        imagev.backgroundColor = UIColor.clearColor()
        return imagev
    }()
    
    lazy var namelabel:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.whiteColor()
        label.textColor = self.laberColor
        label.font = UIFont.systemFontOfSize(12)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var timelabel:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.whiteColor()
        label.textColor = self.laberColor
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(11)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var commentlabel:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clearColor()
        label.textColor = self.laberColor
        label.font = UIFont.systemFontOfSize(14)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var agreeButton:GoodsCommentAgreeButton = {
        let button = GoodsCommentAgreeButton(type: .Custom)
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.whiteColor()
        button.titleLabel?.font = UIFont.systemFontOfSize(12)
        button.setImage(UIImage(named: "rate"), forState: .Normal)
        button.setTitleColor(self.laberColor, forState: .Normal)
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(NewCommentsTableViewCell.agreeButtonClick(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    
    func agreeButtonClick(sender:UIButton){
        if celldataModel.isableAgree == false {
            return
        }
        celldataModel.isableAgree = false
        let manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as? Set<String>
        manager.POST("https://dealsea.com/commentlikes?app=\(appVersion)&comment_id=\(celldataModel.dataArray[5])", parameters: nil, progress: { (progress) in
            }, success: { (task, data) in
                //                if((self.reloadblock) != nil){
                //                    self.reloadblock!()
                //                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.celldataModel.dataArray[4] = "\(Int(self.celldataModel.dataArray[4])!+1)"
                    self.agreeButton.setTitle("\(self.celldataModel.dataArray[4])  ", forState: .Normal)
                })
        }) { (task, error) in
            print(error.description)
            self.celldataModel.isableAgree = true
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = UIColor.whiteColor()
        SetupUI()
    }
    
    func SetupUI(){
        self.contentView.addSubview(headImgView)
        self.contentView.addSubview(namelabel)
        self.contentView.addSubview(timelabel)
        self.contentView.addSubview(commentlabel)
        self.contentView.addSubview(agreeButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        headImgView.frame = CGRect(x: margin*redio, y: margin*redio, width: 30*redio, height: 30*redio)
        namelabel.frame = CGRect(x: margin*redio + CGRectGetMaxX(headImgView.frame), y: headImgView.frame.origin.y, width: namelabel.frame.size.width, height: namelabel.frame.size.height)
        timelabel.frame = CGRect(x: margin*redio + CGRectGetMaxX(headImgView.frame), y: margin*redio + CGRectGetMaxY(namelabel.frame), width: timelabel.frame.size.width, height: timelabel.frame.size.height)
        agreeButton.center = CGPoint(x: self.contentView.frame.size.width - agreeButton.frame.size.width/2 - margin*redio, y: timelabel.frame.origin.y)
        commentlabel.frame = CGRect(x: margin*redio + CGRectGetMaxX(headImgView.frame), y: CGRectGetMaxY(timelabel.frame) + margin*redio, width: contentView.frame.size.width - CGRectGetMaxX(headImgView.frame) - 2*margin*redio, height: self.contentView.frame.size.height - margin*redio - CGRectGetMaxY(namelabel.frame))
        commentlabel.sizeToFit()
    }
    
    //    override func drawRect(rect: CGRect) {
    //        let context:CGContextRef = UIGraphicsGetCurrentContext()!
    //        CGContextSetLineWidth(context, 0.5)
    //        CGContextMoveToPoint(context, commentlabel.frame.origin.x, commentlabel.frame.origin.y +  margin*redio/2)
    //        CGContextAddLineToPoint(context, commentlabel.frame.origin.x - margin*redio/2, commentlabel.frame.origin.y + margin*redio)
    //        CGContextAddLineToPoint(context, commentlabel.frame.origin.x, commentlabel.frame.origin.y + margin*redio*1.5)
    //        CGContextDrawPath(context, CGPathDrawingMode.EOFillStroke)
    //        CGContextClosePath(context)
    //        CGContextStrokePath(context)
    //    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }


}
