//
//  Book.swift
//  HackerBooks
//
//  Created by Francisco Solano Gómez Pino on 08/05/2017.
//  Copyright © 2017 Francisco Solano Gómez Pino. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

// MARK: - Errors

enum BookError:Error {
	case wrongURLFormatForJSONResource
	case jsonParsingError
	case nilJSONObject
}

// MARK: - Class

class Book {
	
	// MARK: - Static properties
	
	static let booksFavouritesUserDefault = UserDefaults(suiteName: "booksFavourites")!

	// MARK: - Stored properties
	
	let id						: String
	let title                   : String
	let authors                 : [String]
	let tags                    : [String]
	let imageURL                : URL?
	let pdfURL                  : URL?
	var image					: UIImage?
	
	// MARK: - Computed properties
	
	var authorsString : String {
		get{
			var authorsString = ""
			for (index,each) in authors.enumerated() {
				authorsString += "\(each)"
				if index != (authors.count-1) {
					if index == (authors.count-2) {
						authorsString += " and "
					} else {
						authorsString += ", "
					}
				}
			}
			return authorsString
		}
	}
	
	var tagsString : String {
		get{
			var tagsString = ""
			for (index,each) in tags.enumerated() {
				tagsString += "\(each)"
				if index != (tags.count-1) {
					if index == (tags.count-2) {
						tagsString += " and "
					} else {
						tagsString += ", "
					}
				}
			}
			return tagsString
		}
	}
	
	var isFavourite:Bool {
		get {
			return Book.booksFavouritesUserDefault.bool(forKey: "book-\(self.id)")
		}
		set(newValue){
			if newValue {
				Book.booksFavouritesUserDefault.setValue(true, forKey: "book-\(self.id)")
			} else {
				Book.booksFavouritesUserDefault.removeObject(forKey: "book-\(self.id)")
			}
			Book.booksFavouritesUserDefault.synchronize()
		}
	}
	
	// MARK: - Initialization
	
	init(id:String, title: String, authors: [String], tags: [String], imageURL: URL?, pdfURL: URL?, image:UIImage?) {
		self.id = id
		self.title = title
		self.authors = authors
		self.tags = tags
		self.imageURL = imageURL
		self.image = image
		self.pdfURL = pdfURL
	}
	
	convenience init(json: JSON?) throws {
		
		if let json = json {
			
			guard let id:String = json["id"].string else {
				throw BookError.jsonParsingError
			}
			
			guard let title:String = json["title"].string?.trimmingCharacters(in: .whitespacesAndNewlines) else {
				throw BookError.jsonParsingError
			}
			
			guard let authors:String = json["authors"].string else {
				throw BookError.jsonParsingError
			}
			
			guard let tags:String = json["tags"].string else {
				throw BookError.jsonParsingError
			}
			
			guard let imageURL:URL = json["image_url"].url else {
				throw BookError.wrongURLFormatForJSONResource
			}
			
			guard let pdfURL:URL = json["pdf_url"].url else {
				throw BookError.wrongURLFormatForJSONResource
			}
			
			self.init(id:id, title: title, authors: stringToArray(string: authors), tags: stringToArray(string: tags), imageURL: imageURL, pdfURL: pdfURL, image: nil)
			
		} else {
			
			throw BookError.nilJSONObject
			
		}
		
	}
	
}

// MARK: - Equatable Extension

extension Book: Equatable {
	
	var proxyForComparison : String{
		get{
			return "\(title)\(id)"
		}
	}
	
	static func ==(lhs: Book, rhs: Book) -> Bool {
		guard (lhs !== rhs) else {
			return true
		}
		return lhs.proxyForComparison == rhs.proxyForComparison
	}
	
}

// MARK: - Comparable Extension

extension Book: Comparable {
	
	var proxyForSorting : String{
		get{
			return proxyForComparison
		}
	}
	
	static func <(lhs: Book, rhs: Book) -> Bool {
		return lhs.proxyForSorting < rhs.proxyForSorting
	}
	
}

// MARK: - CustomStringConvertible Extension

extension Book: CustomStringConvertible {
	
	var description: String {
		get {
			return "< \(type(of: self)): ID\(self.id) \(self.title) writen by \(self.authorsString) >"
		}
	}
	
}
