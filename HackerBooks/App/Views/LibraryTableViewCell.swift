//
//  LibraryTableViewCell.swift
//  HackerBooks
//
//  Created by Francisco Solano Gómez Pino on 08/05/2017.
//  Copyright © 2017 Francisco Solano Gómez Pino. All rights reserved.
//

import UIKit
import Alamofire

// MARK: - Class

class LibraryTableViewCell: UITableViewCell {
	
	// MARK: - Properties
	
	private var request:DataRequest?

	// MARK: - IBOutlets
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var authorsLabel: UILabel!
	@IBOutlet weak var bookImageView: UIImageView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
    // MARK: - Syncronize
	
	// Set model in cell
	func set(model:Book?) {
		
		if let model = model {
			
			if model.title.isEmpty {
				self.titleLabel.text = "Book Untitled"
			} else {
				self.titleLabel.text = model.title
			}
			
			if model.authorsString.isEmpty {
				self.authorsLabel.text = "Authorless"
			} else {
				self.authorsLabel.text = model.authorsString
			}
			
			// Check if image is avaliable in model
			if let image = model.image {
				
				// Stop activity indicator
				self.activityIndicator.stopAnimating()
				
				// Show image
				self.bookImageView.image = image
				self.bookImageView.isHidden = false
				
			} else {
				
				if let imageURL = model.imageURL {
					
					// Show activity indicator, Hidden image & flag canceled
					self.activityIndicator.startAnimating()
					self.bookImageView.isHidden = true
					
					// Download image
					self.request = Alamofire.request(imageURL).responseData {
						(response:DataResponse<Data>) in
						
						if response.result.isSuccess {
						
							// Stop activity indicator
							self.activityIndicator.stopAnimating()
							
							// Obtain image from data
							if let data = response.result.value,
								let image = UIImage(data: data) {
								model.image = image
								self.bookImageView.image = image
							} else {
								self.bookImageView.image = #imageLiteral(resourceName: "AppLogo")
							}
							
							// Show image
							self.bookImageView.isHidden = false
							
						}
						
					}
					
				} else {
					
					// Stop activity indicator
					self.activityIndicator.stopAnimating()
					
					// Show image
					self.bookImageView.image = #imageLiteral(resourceName: "AppLogo")
					self.bookImageView.isHidden = false
					
				}
				
			}

		} else {
			
			self.activityIndicator.stopAnimating()
			self.titleLabel.text = "No book"
			self.authorsLabel.text = ""
			self.bookImageView.image = #imageLiteral(resourceName: "AppLogo")
			
		}
		
	}
	
	// Cancel download image
	func cancel() {
		
		// Cancel request
		self.request?.cancel()
		
	}
    
}
