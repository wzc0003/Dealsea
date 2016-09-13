//
//  DealeaseList.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import Foundation

let appVersion = "v2"

class DeaList: NSObject{
    var title = String()
    var post_time = String()
    var image = Array(count: 2, repeatedValue: "")
    var post_id = String()
    var merchant = Array(count: 4, repeatedValue: "")
    var comment_count:Int = 0
    var allowComment:String = String()
    var expired:Int = 0
    var hotness:String = String()
}

class NotificationsInfo: NSObject{
    var title = String()
    var url = String()
    var DataSource:NSMutableArray = NSMutableArray()
}

class CouponsInfo: NSObject{
    var title = String()
    var url = String()
    var comment_count:Int = 0
    var merchant = Array(count: 5, repeatedValue: "")
    var post_endtime = String()
    var post_id = String()
}

class CouponsDetailInfo: NSObject{
    var merchant = Array(count: 5, repeatedValue: "")
    var title = String()
    var post_endtime = String()
    var expired = Bool()
    var comment_count = Int()
}
