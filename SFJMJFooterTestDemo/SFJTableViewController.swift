//
//  SFJTableViewController.swift
//  SFJMJFooterTestDemo
//
//  Created by shafujiu on 2020/5/18.
//  Copyright © 2020 shafujiu. All rights reserved.
//

import UIKit
import MJRefresh

class SFJTableViewController: UITableViewController {

    
    var data = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 10 // 注释掉这一句就不会有问题了
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        for i in 0...9 {
            data.append(i)
        }
        tableView.reloadData()
        
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("content size\(String(describing: change?[NSKeyValueChangeKey.newKey]))")
    }
    
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    @objc func loadMoreData() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            var indexPaths = [IndexPath]()
            for i in 0...9 {
                indexPaths.append(IndexPath(row: self.data.count + i, section: 0))
            }
            for i in 0...9 {
                self.data.append(self.data.count + i)
            }
            self.tableView.insertRows(at: indexPaths, with: .none)
            
            self.tableView.mj_footer?.endRefreshing()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text =  "这是第\(indexPath.row)行"
        return cell
    }
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }

}
