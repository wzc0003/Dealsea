//
//  ViewController.swift
//  Dealsea_wzc
//
//  Created by dptech on 16/5/11.
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var tableview = UITableView()
    let listUrl = "https://dealsea.com/?app=v2"
    var DataSource = []
    var session:NSURLSession!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableview.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reusingCell")
        tableview.frame = CGRect(x: 0, y: 44 + CGRectGetMaxY((self.navigationController?.navigationBar.frame)!), width: view.frame.size.width, height: view.frame.size.height-44)
        self.view .addSubview(tableview)
        view.backgroundColor = UIColor.redColor()
        self.navigationItem.title = "Dealsea"
        tableview.dataSource = self
        tableview.delegate = self
        let Rect = CGRect(x: 0, y: CGRectGetMaxY((self.navigationController?.navigationBar.frame)!), width: view.bounds.width, height: 44)
        let sv = scrollView(Rect)
        self.view.addSubview(sv)
        loadDataSource()
    }
    func scrollView(frame: CGRect) -> UIScrollView{
        let sv = UIScrollView(frame: frame)
        sv.backgroundColor = UIColor.greenColor()
        let lableArray: [String] = ["Computers   ", "Beauty   ", "Fashion   ", "Coupons   "]
        let margin:CGFloat = 12
        var x = margin
        for i in 0..<4{
            let lable = UILabel()
            lable.text = lableArray[i]
            lable.font = UIFont.systemFontOfSize(20)
            lable.sizeToFit()
            lable.font = UIFont.systemFontOfSize(18)
            lable.frame = CGRect(x: x, y: 0, width: lable.bounds.width, height: frame.height)
            sv.addSubview(lable)
            x += lable.bounds.width
        }
        //    sv.alwaysBounceVertical
        sv.contentSize = CGSize(width: x + margin, height: frame.height)
        return sv
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDataSource(){
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 15
        
        session = NSURLSession(configuration: config)
        
        let url = NSURL(string: listUrl)
        
        let task = session.dataTaskWithURL(url!) { (data, request, error) -> Void in
            
            if((error) != nil){
                print(error?.localizedDescription)
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                print("myData is \(json)")
                
                
                let SpDataSource = json["list"] as! NSArray
                
                let CurrentDeaData = NSMutableArray()
                
                for CurrentDea in SpDataSource{
                    let spList = DeaList()
                    spList.title = CurrentDea["title"] as! String
                    spList.post_time = CurrentDea["post_time"] as! String
                    spList.post_id = CurrentDea["post_id"] as! String
                    
                    CurrentDeaData.addObject(spList)
                    
                }
                
                
                
                self.DataSource = CurrentDeaData
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableview.reloadData()
                })
                
                
            }catch{
                print("error")
            }
        }
        
        task.resume()
    }
    


    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataSource.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "reusingCell")
        let splist = DataSource[indexPath.row] as! DeaList
        cell.textLabel?.text = splist.title
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont.systemFontOfSize(10)
        cell.detailTextLabel?.textColor = UIColor.grayColor()
        cell.detailTextLabel?.text = splist.post_time
        return cell
    }
}

