//
//  DealeaseHeaderView.swift
//  Copyright © 2016年 dealsea. All rights reserved.
//

import UIKit

class DealeaseHeaderView: UIView {

    var searchController:UISearchController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        self.addSubview(searchController.searchBar)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
