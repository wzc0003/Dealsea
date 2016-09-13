//
//  NetworkTool.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit
import AFNetworking

class NetworkTool: NSObject {
    
    var taskarr:[NSURLSessionDataTask] = [NSURLSessionDataTask]()
    static var sharetool = NetworkTool()
    var manager:AFHTTPSessionManager = AFHTTPSessionManager()
}
