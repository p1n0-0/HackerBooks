//
//  Book.swift
//  HackerBooks
//
//  Created by Francisco Gómez Pino on 6/7/16.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import Foundation
import UIKit

class Book : Comparable {
    
    //--------------------------------------
    // MARK: - Stored properties
    //--------------------------------------
    
    let title                   : String?
    let authors                 : [String]
    let tags                    : [String]
    let imageURL                : NSURL?
    let pdfURL                  : NSURL
    private var image           : UIImage?
    private(set) var isFavorite : Bool
    
    //--------------------------------------
    // MARK: - Computed properties
    //--------------------------------------
    
    var authorsString : String?{
        get{
            var authorsString = ""
            for (index,each) in authors.enumerate() {
                authorsString += "\(each)"
                if index != (authors.count-1) {
                    if index == (authors.count-2) {
                        authorsString += " and "
                    } else {
                        authorsString += ", "
                    }
                }
            }
            if authorsString == "" {
                return nil
            } else {
                return authorsString
            }
        }
    }
    
    var tagsString : String?{
        get{
            var tagsString = ""
            for (index,each) in tags.enumerate() {
                tagsString += "\(each)"
                if index != (tags.count-1) {
                    if index == (tags.count-2) {
                        tagsString += " and "
                    } else {
                        tagsString += ", "
                    }
                }
            }
            if tagsString == "" {
                return nil
            } else {
                return tagsString
            }
        }
    }
    
    //--------------------------------------
    // MARK: - Initialization
    //--------------------------------------
    
    init(title: String?, authors: [String], tags: [String], imageURL: NSURL?, image:UIImage?, pdfURL: NSURL) {
        self.title = title
        self.authors = authors
        self.tags = tags
        self.imageURL = imageURL
        self.image = image
        self.pdfURL = pdfURL
        
        if let fileName:String = pdfURL.lastPathComponent {
            self.isFavorite = NSUserDefaults.standardUserDefaults().boolForKey(fileName)
        } else {
            self.isFavorite = false
        }
        
    }
    
    convenience init(title: String?, authors: [String], tags: [String], imageURL: NSURL?, pdfURL: NSURL) {
        self.init(title: title, authors: authors, tags: tags, imageURL: imageURL, image: nil, pdfURL: pdfURL)
    }
    
    //--------------------------------------
    // MARK: - Getters
    //--------------------------------------
    
    func getImage() -> UIImage? {
        if self.image == nil {
            guard
                let imageURL:NSURL = self.imageURL,
                let imageData:NSData = getResourceWithCache(fromURL: imageURL),
                let image:UIImage = UIImage(data: imageData) else {
                    return nil
            }
            self.image = image
        }
        return self.image
    }
    
    func getImageInBackground(withBlock block: (image:UIImage?)->()) {
        
        if self.image == nil {
            if let imageURL:NSURL = self.imageURL {
                
                getResourceWithCacheInBackground(fromURL: imageURL, withBlock: {
                    (resource:NSData?) in
                    
                    if let imageData:NSData = resource, let image:UIImage = UIImage(data: imageData) {
                        self.image = image
                        block(image: image)
                    } else {
                        block(image: nil)
                    }
                    
                })
                
            } else {
                block(image: nil)
            }
        } else {
            block(image: self.image)
        }
        
    }
    
    //--------------------------------------
    // MARK: - Setters
    //--------------------------------------
    
    func setIsFavorite(bool:Bool) {
        if let fileName:String = pdfURL.lastPathComponent {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setBool(bool, forKey: fileName)
            userDefaults.synchronize()
            self.isFavorite = bool
        } else {
            self.isFavorite = false
        }
    }
    
    //--------------------------------------
    // MARK: - Proxies
    //--------------------------------------
    
    var proxyForComparison : String{
        get{
            return "\(title)\(authorsString)\(tagsString)\(pdfURL)\(imageURL)"
        }
    }
    
    var proxyForSorting : String{
        get{
            return proxyForComparison
        }
    }
    
}

//--------------------------------------
// MARK: - Equatable & Comparable
//--------------------------------------

func ==(lhs: Book, rhs: Book) -> Bool {
    guard (lhs !== rhs) else{
        return true
    }
    return lhs.proxyForComparison == rhs.proxyForComparison
}

func <(lhs: Book, rhs: Book) -> Bool {
    return lhs.proxyForSorting < rhs.proxyForSorting
}

//--------------------------------------
// MARK: - Extensions
//--------------------------------------

extension Book :  CustomStringConvertible{
    
    var description : String{
        get{
            if let title = self.title{
                if let authorsString = self.authorsString {
                    return  "< \(self.dynamicType) \(title) written by \(authorsString) >"
                } else {
                    return  "< \(self.dynamicType) \(title) >"
                }
            }
            
            return "<\(self.dynamicType)>"
        }
    }
    
}
