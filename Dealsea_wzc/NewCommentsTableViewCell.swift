//
//  NewCommentsTableViewCell.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit
import AFNetworking

class NewCommentsTableViewCell: UITableViewCell {

    let laberColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
    let tableViewbackgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
    var redio:CGFloat = UIScreen.mainScreen().bounds.size.width/320
    var margin:CGFloat = 10
    var reloadblock:(()->Void)?
    var celldataModel:GoodsCommentViewModel = GoodsCommentViewModel(){
        didSet{
            let attrStr = try! NSMutableAttributedString(
                data: "\(celldataModel.dataArray[0])".dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
                options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
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

    lazy var bottomline:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        return view
    }()
    lazy var headImgView:UIImageView = {
        let imagev = UIImageView()
        imagev.contentMode = .ScaleAspectFill
        imagev.clipsToBounds = true
        imagev.backgroundColor = self.tableViewbackgroundColor
        return imagev
    }()
    
    lazy var namelabel:UILabel = {
        let label = UILabel()
        label.backgroundColor = self.tableViewbackgroundColor
        label.textColor = self.laberColor
        label.font = UIFont.systemFontOfSize(12)
        label.numberOfLines = 1
        return label
    }()
    lazy var commentBg:UIImageView = {
        var image = UIImage(named: "dialog")
        image = image?.resizableImageWithCapInsets(UIEdgeInsets(top: image!.size.height*0.5 - 1, left: image!.size.width*0.5 - 1, bottom: image!.size.height*0.5, right: image!.size.width*0.5))
        let imageview = UIImageView(image: image)
        imageview.sizeToFit()
        return imageview
    }()
    
    lazy var timelabel:UILabel = {
        let label = UILabel()
        label.backgroundColor = self.laberColor
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(12)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var commentlabel:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clearColor()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var agreeButton:GoodsCommentAgreeButton = {
        let button = GoodsCommentAgreeButton(type: .Custom)
        button.layer.cornerRadius = 5
        button.backgroundColor = self.tableViewbackgroundColor
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
        self.contentView.backgroundColor = self.tableViewbackgroundColor
        SetupUI()
    }
    
    func SetupUI(){ 
        self.contentView.addSubview(bottomline)
        self.contentView.addSubview(headImgView)
        self.contentView.addSubview(namelabel)
        self.contentView.addSubview(timelabel)
        self.contentView.addSubview(commentBg)
        self.contentView.addSubview(commentlabel)
        self.contentView.addSubview(agreeButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timelabel.center = CGPoint(x: self.contentView.frame.size.width/2, y: margin*redio + timelabel.frame.size.height/2)
        bottomline.frame = CGRect(x: 0, y: self.contentView.frame.size.height - 1, width: self.contentView.frame.size.width, height: 1)
        headImgView.frame = CGRect(x: margin*redio, y: margin*redio+CGRectGetMaxY(timelabel.frame), width: 40, height: 40)
        namelabel.frame = CGRect(x: CGRectGetMaxX(headImgView.frame)+margin*redio, y: CGRectGetMinY(headImgView.frame), width: namelabel.frame.size.width, height: namelabel.frame.size.height)
        agreeButton.center = CGPoint(x: self.contentView.frame.size.width - agreeButton.frame.size.width/2 - margin*redio, y: namelabel.center.y)
        commentlabel.frame = CGRect(x: CGRectGetMaxX(headImgView.frame)+2*margin*redio, y: CGRectGetMaxY(namelabel.frame) + 2*margin*redio, width: self.contentView.frame.size.width - CGRectGetMaxX(headImgView.frame) - 6*margin*redio, height: self.contentView.frame.size.height - margin*redio - CGRectGetMaxY(namelabel.frame))
        commentlabel.sizeToFit()
        commentBg.frame = CGRect(x: commentlabel.frame.origin.x-2*margin*redio, y: commentlabel.frame.origin.y - margin*redio, width: commentlabel.frame.size.width+4*margin*redio, height:commentlabel.frame.size.height + 3*margin*redio)
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
