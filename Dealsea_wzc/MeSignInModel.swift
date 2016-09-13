//
//  MeSignInModel.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit

class MeSignInModel: NSObject {
    
    var Title:String?
    var UIType:String?
    
    init(dict:[String:AnyObject]){
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}

}
