//
//  Library.swift
//  HackerBooks
//
//  Created by Francisco Solano Gómez Pino on 08/05/2017.
//  Copyright © 2017 Francisco Solano Gómez Pino. All rights reserved.
//

import Foundation
import SwiftyJSON

// MARK: - Global constants

let allBookTag = ""
let favouriteBookTag = "favourites"

// MARK: - Errors

enum LibraryError:Error {
	case nilJSONObject
}

// MARK: - Class

class Library {
	
	// MARK: - Stored properties
	
	let books                     : [Book]
	var orderByTags               : Bool
	private let bookTags          : [String]

	// MARK: - Computed properties
	
	var firstBook: Book? {
		get{
			return self.books.first
		}
	}
	
	var booksCount: Int{
		get{
			return self.books.count
		}
	}
	
	var tags:[String]{
		get{
			if orderByTags {
				var tags = self.bookTags
				if self.booksCount(forTag: favouriteBookTag) > 0 {
					tags.insert(favouriteBookTag, at: 0)
				}
				return tags
			} else {
				return [allBookTag]
			}
		}
	}
	
	var tagsCount: Int{
		get{
			return self.tags.count
		}
	}
	
	// MARK: - Initialization
	
	init(books:[Book]){
		self.books = books.sorted()
		
		var tags:[String] = []
		for book in books {
			for tag in book.tags {
				if !tags.contains(tag) {
					tags.append(tag)
				}
			}
		}
		self.bookTags = tags.sorted()
		
		self.orderByTags = false
		
	}
	
	convenience init(jsonArray:JSON?) throws {
		
		if let jsonArray = jsonArray?.array {
			var books:[Book] = []
			for json in jsonArray {
				books.append(try Book(json: json))
			}
			self.init(books: books)
		} else {
			throw LibraryError.nilJSONObject
		}
		
	}
	
	// MARK: - Getters
	
	func booksCount(forTag tag: String) -> Int {
		if tag.lowercased() == allBookTag {
			return self.booksCount
		} else {
			var count = 0
			for book in self.books {
				if book.tags.contains(tag) || ( tag.lowercased() == favouriteBookTag && book.isFavourite ) {
					count += 1
				}
			}
			return count
		}
	}
	
	func books(forTag tag:String) -> [Book]? {
		if tag.lowercased() == allBookTag {
			return self.books.sorted()
		} else {
			var books:[Book] = []
			for book in self.books {
				if book.tags.contains(tag) || ( tag.lowercased() == favouriteBookTag && book.isFavourite )  {
					books.append(book)
				}
			}
			if books.count > 0 {
				return books.sorted()
			} else {
				return nil
			}
		}
	}
	
	func book(atIndex index: Int, forTag tag:String) -> Book? {
		return self.books(forTag: tag)?[index]
	}
	
}

// MARK: - CustomStringConvertible Extension

extension Library: CustomStringConvertible {
	
	var description: String {
		get {
			return "< \(type(of: self)): With \(self.booksCount) books and \(self.tagsCount) tags >"
		}
	}
	
}
