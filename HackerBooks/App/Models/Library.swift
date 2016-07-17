//
//  Library.swift
//  HackerBooks
//
//  Created by Francisco Gómez Pino on 6/7/16.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import Foundation
import UIKit

let allBookTag = ""
let favoriteBookTag = "favorites"

class Library {
    
    //--------------------------------------
    // MARK: - Stored properties
    //--------------------------------------
    
    let books                     : [Book]
    var orderByTags               : Bool
    private let bookTags          : [String]
    
    //--------------------------------------
    // MARK: - Computed properties
    //--------------------------------------
    
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
                if self.booksCount(forTag: favoriteBookTag) > 0 {
                    tags.insert(favoriteBookTag, atIndex: 0)
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
    
    //--------------------------------------
    // MARK: - Initialization
    //--------------------------------------
    
    init(books:[Book]){
        self.books = books.sort()
        
        var tags:[String] = []
        for book in books {
            for tag in book.tags {
                if !tags.contains(tag) {
                    tags.append(tag)
                }
            }
        }
        self.bookTags = tags.sort()
        
        self.orderByTags = false
        
    }
    
    //--------------------------------------
    // MARK: - Getters
    //--------------------------------------
    
    func booksCount(forTag tag: String) -> Int {
        if tag.lowercaseString == allBookTag {
            return self.booksCount
        } else {
            var count = 0
            for book in self.books {
                if book.tags.contains(tag) || ( tag.lowercaseString == favoriteBookTag && book.isFavorite ) {
                    count += 1
                }
            }
            return count
        }
    }
    
    func books(forTag tag:String) -> [Book]? {
        if tag.lowercaseString == allBookTag {
            return self.books.sort()
        } else {
            var books:[Book] = []
            for book in self.books {
                if book.tags.contains(tag) || ( tag.lowercaseString == favoriteBookTag && book.isFavorite )  {
                    books.append(book)
                }
            }
            if books.count > 0 {
                return books.sort()
            } else {
                return nil
            }
        }
    }
    
    func book(atIndex index: Int, forTag tag:String) -> Book? {
        return self.books(forTag: tag)?[index]
    }
    
}
