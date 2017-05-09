//
//  BookViewController.swift
//  HackerBooks
//
//  Created by Francisco Solano Gómez Pino on 08/05/2017.
//  Copyright © 2017 Francisco Solano Gómez Pino. All rights reserved.
//

import UIKit
import Alamofire

// MARK: - Global constants

let BookIsFavoriteDidChangeNotification:Notification.Name = Notification.Name(rawValue: "BookIsFavoriteDidChangeNotification")

// MARK: - Class

class BookViewController: UIViewController {

	// MARK: - Properties
	
	var model: Book
	private var request:DataRequest?
	
	// MARK: - IBOutlets
	
	@IBOutlet weak var bookImageView: UIImageView!
	@IBOutlet weak var bookImageActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var authorsLabel: UILabel!
	@IBOutlet weak var tagsLabel: UILabel!
	@IBOutlet weak var likeButton: UIButton!
	@IBOutlet weak var readButton: UIButton!
	
	// MARK: - Initialization
	
	init(model:Book) {
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
		
		// View title
		self.title = "Book Info"
		
		// Buttons Personalization
		self.likeButton.layer.cornerRadius = 5
		self.readButton.layer.cornerRadius = 5
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Sync with model
		self.syncModelWithView()
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// Cancel request
		self.request?.cancel()
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - IBActions

	@IBAction func readBook(_ sender: Any) {
		
		self.navigationController?.pushViewController(PDFViewController(model: self.model), animated: true)
		
	}
	
	@IBAction func likeOrUnlikeBook(_ sender: Any) {
		
		self.model.isFavourite = !self.model.isFavourite
		self.syncModelWithFavoriteButton()
		
		// Send notification
		NotificationCenter.default.post(Notification(name: BookIsFavoriteDidChangeNotification, object: self, userInfo: nil))
		
	}
	
	// MARK: - Syncing
	
	func syncModelWithView(){
		
		self.likeButton.isHidden = true
		self.readButton.isHidden = true
		
		if model.id.isEmpty {
			
			self.bookImageView.image = #imageLiteral(resourceName: "AppLogo")
			self.bookImageActivityIndicator.stopAnimating()
			self.titleLabel.text = "⬅️ Select a book"
			self.authorsLabel.text = ""
			self.tagsLabel.text = ""
			
		} else {
			
			self.likeButton.isHidden = false
			
			if model.title.isEmpty {
				self.titleLabel.text = "Book Untitled"
			} else {
				self.titleLabel.text = model.title
			}
			
			if model.authorsString.isEmpty {
				self.authorsLabel.text = "Authorless"
			} else {
				self.authorsLabel.text = "Written by \(model.authorsString)"
			}
			
			if model.tagsString.isEmpty {
				self.tagsLabel.text = "No tagged"
			} else {
				self.tagsLabel.text = "Tagged as \(model.tagsString)"
			}
			
			if model.pdfURL != nil {
				self.readButton.isHidden = false
			}
			
			self.syncModelWithFavoriteButton()
			
			// Check if image is avaliable in model
			if let image = model.image {
				
				// Stop activity indicator
				self.bookImageActivityIndicator.stopAnimating()
				
				// Show image
				self.bookImageView.image = image
				self.bookImageView.isHidden = false
				
			} else {
				
				if let imageURL = model.imageURL {
					
					// Show activity indicator, Hidden image & flag canceled
					self.bookImageActivityIndicator.startAnimating()
					self.bookImageView.isHidden = true
					
					// Download image
					self.request = Alamofire.request(imageURL).responseData {
						(response:DataResponse<Data>) in
						
						switch response.result {
						case .success:
						
							// Stop activity indicator
							self.bookImageActivityIndicator.stopAnimating()
							
							// Obtain image from data
							if let data = response.result.value,
								let image = UIImage(data: data) {
								self.model.image = image
								self.bookImageView.image = image
							} else {
								self.bookImageView.image = #imageLiteral(resourceName: "AppLogo")
							}
							
							// Show image
							self.bookImageView.isHidden = false
								
						case .failure(let error):
							if (error as NSError).code != NSURLErrorCancelled {
								displayAlert(target: self, title: "Downloading error", message: error.localizedDescription, completionHandler: {
									self.navigationController?.popViewController(animated: true)
								})
							}
						}
					}
					
				} else {
					
					// Stop activity indicator
					self.bookImageActivityIndicator.stopAnimating()
					
					// Show image
					self.bookImageView.image = #imageLiteral(resourceName: "AppLogo")
					self.bookImageView.isHidden = false
					
				}
				
			}
			
		}
		
	}
	
	func syncModelWithFavoriteButton() {
		
		if self.model.isFavourite {
			self.likeButton.backgroundColor = UIColor(red:0.81, green:0.00, blue:0.00, alpha:1.0)
			self.likeButton.setTitle(" 👎 Remove from your favorites ", for: .normal)
		} else {
			self.likeButton.backgroundColor = UIColor(red:0.07, green:0.81, blue:0.00, alpha:1.0)
			self.likeButton.setTitle(" 👍 Add to favourites ", for: .normal)
		}
		
	}
	
	
}

// MARK: - Extensions

extension BookViewController: LibraryTableViewControllerDelegate {
	
	func libraryTableViewController(vc: LibraryTableViewController, didSelectBook book: Book) {
		
		// Set new model
		self.model = book
		
		// Sync
		self.syncModelWithView()
		
	}
	
}
