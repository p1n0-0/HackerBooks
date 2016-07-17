//
//  Errors.swift
//  HackerBooks
//
//  Created by Francisco Gómez Pino on 6/7/16.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import Foundation

//--------------------------------------
// MARK: - Aliases
//--------------------------------------

typealias JSONObject        =   AnyObject
typealias JSONDictionary    =   [String : JSONObject]
typealias JSONArray         =   [JSONDictionary]

//--------------------------------------
// MARK: - JSON Errors
//--------------------------------------

enum JSONError : ErrorType{
    case wrongURLFormatForJSONResource
    case resourcePointedByURLNotReachable
    case jsonParsingError
    case wrongJSONFormat
    case nilJSONObject
}


//--------------------------------------
// MARK: - Decodification
//--------------------------------------

func decode(book json: JSONDictionary) throws  -> Book{
    
    guard let title = json["title"] as? String else {
        throw JSONError.jsonParsingError
    }
    
    guard let authors = json["authors"] as? String,
        authorsArray = stringToArray(authors) else {
            throw JSONError.jsonParsingError
    }
    
    guard let tags = json["tags"] as? String,
        tagsArray = stringToArray(tags) else {
            throw JSONError.jsonParsingError
    }
    
    guard let imageURL = json["image_url"] as? String,
        imgURL = NSURL(string: imageURL) else {
            throw JSONError.wrongURLFormatForJSONResource
    }
    
    guard let pdfURL = json["pdf_url"] as? String,
        url = NSURL(string: pdfURL) else{
            throw JSONError.wrongURLFormatForJSONResource
    }
    
    return Book(title: title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()), authors: authorsArray, tags: tagsArray, imageURL: imgURL, pdfURL: url)
    
}

func decode(book json: JSONDictionary?) throws -> Book{
    if case .Some(let jsonDict) = json{
        return try decode(book: jsonDict)
    }else{
        throw JSONError.nilJSONObject
    }
}

//--------------------------------------
// MARK: - Loading
//--------------------------------------

func load(fromData data: NSData) throws -> JSONArray {
    
    if let maybeArray = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? JSONArray, array = maybeArray {
        return array
    }else{
        throw JSONError.jsonParsingError
    }
}

//--------------------------------------
// MARK: - Utils
//--------------------------------------

func stringToArray(string: String) -> [String]? {
    var array:[String] = []
    for each in string.componentsSeparatedByString(",") {
        array.append(each.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
    }
    return array
}
