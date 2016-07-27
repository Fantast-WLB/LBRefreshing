//
//  ViewController.swift
//  testForRefreshing
//
//  Created by 吴龙波 on 16/7/26.
//  Copyright © 2016年 SleepWell. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    private var modelArr: [String]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private func loadData() {
        modelArr = [String]()
        
        for i in 0...5 {
            let str = "广州\(i)"
            
            modelArr?.append(str)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadData()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.tableView.addSubview(refreshView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - datasource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArr?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = modelArr?[indexPath.row]
        
        return cell
    }

    // MARK: - 懒加载
    private lazy var refreshView = LBRefreshingView(frame: CGRectZero)
}

