//
//  LibraryTableViewController.swift
//  HackerBooks
//
//  Created by Francisco Gómez Pino on 6/7/16.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import UIKit

let BookDidChangeNotification = "Selected book did change"
let BookKey = "BookKey"
let cellId = "BookCell"

class LibraryTableViewController: UITableViewController {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    var model            : Library
    var segmentedControl : UISegmentedControl?
    var delegate         : LibraryTableViewControllerDelegate?
    
    //--------------------------------------
    // MARK: - Initialization
    //--------------------------------------
    
    init(model: Library){
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //--------------------------------------
    // MARK: - UIViewController
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "LibraryTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationBar = self.navigationController?.navigationBar {
            
            segmentedControl = UISegmentedControl(items: ["All books", "Grouped by tag"])
            segmentedControl!.frame = CGRect(x: (navigationBar.frame.size.width/2)-125, y: 5, width: 250, height: (navigationBar.frame.size.height/1.3))
            segmentedControl!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
            segmentedControl?.addTarget(self, action: #selector(segmentedControlChanged), forControlEvents: .ValueChanged)
            navigationBar.addSubview(self.segmentedControl!)
            
            if self.model.orderByTags {
                segmentedControl?.selectedSegmentIndex = 1
            } else {
                segmentedControl?.selectedSegmentIndex = 0
            }
            
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadData), name: BookIsFavoriteDidChangeNotification, object: nil)
        
        self.tableView.reloadData()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        segmentedControl?.removeFromSuperview()
        NSNotificationCenter.defaultCenter().removeObserver(self)

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //--------------------------------------
    // MARK: - Table view delegate
    //--------------------------------------

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let book:Book = self.model.book(atIndex: indexPath.row, forTag: self.model.tags[indexPath.section]) {
            
            if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
                
                delegate?.libraryTableViewController(self, didSelectBook: book)
                
                let nc = NSNotificationCenter.defaultCenter()
                let notif = NSNotification(name: BookDidChangeNotification, object: self, userInfo: [BookKey:book])
                nc.postNotification(notif)
                
            } else {
                
                navigationController?.pushViewController(BookViewController(model: book), animated: true)
                
            }
            
        }
        
    }
    
    //--------------------------------------
    // MARK: - Table view data source
    //--------------------------------------
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.model.tagsCount
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.model.booksCount(forTag: self.model.tags[section])
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.model.tags[section]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? LibraryTableViewCell
        
        if cell == nil{
            cell = LibraryTableViewCell()
        }
        
        cell?.model = self.model.book(atIndex: indexPath.row, forTag: self.model.tags[indexPath.section])
        
        cell?.syncModelWithView()

        return cell!
        
    }
    
    //--------------------------------------
    // MARK: - Syncing
    //--------------------------------------
    
    func reloadData(notification: NSNotification)  {
        self.tableView.reloadData()
    }
    
    func segmentedControlChanged(sender: UISegmentedControl)  {
        
        if sender.selectedSegmentIndex == 0 {
            self.model.orderByTags = false
        } else {
            self.model.orderByTags = true
        }
        
        self.tableView.reloadData()
        
    }
    
}

//--------------------------------------
// MARK: - Protocols
//--------------------------------------

protocol LibraryTableViewControllerDelegate {
    
    func libraryTableViewController(vc : LibraryTableViewController, didSelectBook book: Book)
    
}

//--------------------------------------
// MARK: - Extensions
//--------------------------------------

extension LibraryTableViewController: UISplitViewControllerDelegate {
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }
    
}
