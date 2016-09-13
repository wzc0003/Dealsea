//
//  GoodsCommentViewModel.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit

class GoodsCommentViewModel: NSObject {

    var commentHeight:CGFloat = 0
    var isableAgree:Bool = false
    var dataArray:[String] = [String](){
        didSet{
            var redio:CGFloat = UIScreen.mainScreen().bounds.size.width/320
            var margin:CGFloat = 10
            let attrStr = try! NSMutableAttributedString(
                data: "\(dataArray[0])".dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
                options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                documentAttributes: nil)
            attrStr.addAttributes([NSFontAttributeName:UIFont.systemFontOfSize(15)], range: NSMakeRange(0, attrStr.string.characters.count))
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width - 40 - 6*margin*redio, height: 10))
            label.numberOfLines = 0
            label.attributedText = attrStr
            label.sizeToFit()
            commentHeight = label.frame.size.height
        }
    }
}
