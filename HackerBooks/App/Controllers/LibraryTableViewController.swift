//
//  LibraryTableViewController.swift
//  HackerBooks
//
//  Created by Francisco Solano Gómez Pino on 08/05/2017.
//  Copyright © 2017 Francisco Solano Gómez Pino. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

// MARK: - Global constants

let BookDidChangeNotification:Notification.Name = Notification.Name(rawValue: "BookDidChangeNotification")
let BookKeyNotification:String = "BookKeyNotification"

// MARK: - Class

class LibraryTableViewController: UITableViewController {
	
	// MARK: - Static
	
	static let cellReuseIdentifier	 : String = "BookCell"

	// MARK: - Properties
	
	var model            : Library?
	var orderButton		 : UIBarButtonItem?
	let refresher		 : UIRefreshControl = UIRefreshControl()
	var delegate         : LibraryTableViewControllerDelegate?
	
	// MARK: - Initialization
	
	init(model: Library?){
		self.model = model
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - UIViewController
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Do any additional setup after loading the view.
		
		// App title
		self.title = "HackerBooks"
		
		// Create order button
		self.orderButton = UIBarButtonItem(title: "ABC", style: .done, target: self, action: #selector(LibraryTableViewController.changeOrder(sender:)))
		self.navigationItem.rightBarButtonItem = self.orderButton
		
		// Register Custom Cell
		self.tableView.register(UINib(nibName: "LibraryTableViewCell", bundle: nil), forCellReuseIdentifier: LibraryTableViewController.cellReuseIdentifier)
		
		// Customization & setting refresher
		self.refresher.tintColor = UIColor.gray
		self.refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
		self.refresher.addTarget(self, action: #selector(LibraryTableViewController.refreshLibrary), for: UIControlEvents.valueChanged)
		self.tableView?.addSubview(self.refresher)
		
		// Check if exist model
		if self.model == nil {
			
			// Start refreshing
			self.refresher.beginRefreshing()
			
			// First refresh
			self.refreshLibrary()
			
		}
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Observer if book change
		NotificationCenter.default.addObserver(self, selector: #selector(LibraryTableViewController.reloadData(notification:)), name: BookIsFavoriteDidChangeNotification, object: nil)
		
		// Reload table
		self.tableView.reloadData()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// Remove observer
		NotificationCenter.default.removeObserver(self)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - Table view delegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if let book:Book = self.model!.book(atIndex: indexPath.row, forTag: self.model!.tags[indexPath.section]) {
			
			if (UIDevice.current.userInterfaceIdiom == .pad) {
				
				delegate?.libraryTableViewController(vc: self, didSelectBook: book)
				NotificationCenter.default.post(Notification(name: BookDidChangeNotification, object: self, userInfo: [BookKeyNotification : book]))
				
			} else {
				
				self.navigationController?.pushViewController(BookViewController(model: book), animated: true)
				
			}
			
		}
		
	}

    // MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}

    override func numberOfSections(in tableView: UITableView) -> Int {
		return ( self.model == nil ? 0 : self.model!.tagsCount )
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.model!.tags[section].capitalized
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model!.booksCount(forTag: self.model!.tags[section])
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LibraryTableViewController.cellReuseIdentifier, for: indexPath) as! LibraryTableViewCell

        // Configure the cell...
		cell.set(model: self.model!.book(atIndex: indexPath.row, forTag: self.model!.tags[indexPath.section]))
		
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let cell = cell as? LibraryTableViewCell {
			cell.cancel()
		}
	}
	
	// MARK: - Syncing
	
	func changeOrder(sender:UIBarButtonItem) {
		
		if sender.title == "ABC" {
			sender.title = "TAG"
			self.model?.orderByTags = true
		} else {
			sender.title = "ABC"
			self.model?.orderByTags = false
		}
		
		self.tableView.reloadData()
		
	}
	
	func reloadData(notification: Notification)  {
		self.tableView.reloadData()
	}
	
	func refreshLibrary() {
		
		self.orderButton?.isEnabled = false
		
		if self.refresher.isRefreshing {
			self.refresher.attributedTitle = NSAttributedString(string: "Updating...")
		}
		
		// Get response from API
		Alamofire.request("https://parse.netpino.net/api/HackerBooks.php").validate().responseSwiftyJSON {
			(response:DataResponse<JSON>) in
			
			switch response.result {
			case .success:
				do {
					self.model = try Library(jsonArray: response.result.value)
					self.model?.orderByTags = (self.orderButton?.title == "TAG")
					self.orderButton?.isEnabled = true
					
					self.tableView.reloadData()
					
				} catch {
					displayAlert(target: self, title: "Parsing error", message: "The server response was different than expected.", completionHandler: nil)
				}
			case .failure(let error):
				displayAlert(target: self, title: "Downloading error", message: error.localizedDescription, completionHandler: nil)
			}
			
			if self.refresher.isRefreshing {
				self.refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
				self.refresher.endRefreshing()
			}
			
		}
		
	}

}

// MARK: - Protocols

protocol LibraryTableViewControllerDelegate {
	
	func libraryTableViewController(vc : LibraryTableViewController, didSelectBook book: Book)
	
}

// MARK: - Extensions

extension LibraryTableViewController: UISplitViewControllerDelegate {
	
	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
		return true
	}
	
}
