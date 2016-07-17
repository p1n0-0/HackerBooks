//
//  Resources.swift
//  HackerBooks
//
//  Created by Francisco Gómez Pino on 6/7/16.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import Foundation

//--------------------------------------
// MARK: - Get resource with cache
//--------------------------------------

func getResourceWithCache(fromURL url:NSURL) -> NSData? {
    
    let fileManager:NSFileManager = NSFileManager.defaultManager()
    
    guard
        let resourceName:String = url.lastPathComponent,
        let cacheURL:NSURL = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).last,
        let directoryURL:NSURL = cacheURL.URLByAppendingPathComponent("Resources"),
        let directoryPath:String = directoryURL.path,
        let filePath:String = directoryURL.URLByAppendingPathComponent(resourceName).path
        else {
            return nil
    }
    
    if !fileManager.fileExistsAtPath(directoryPath) {
        try! fileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: false, attributes: nil)
    }
    
    var resource:NSData?
    
    if fileManager.fileExistsAtPath(filePath) {
        resource = NSData(contentsOfFile: filePath)
    } else {
        resource = NSData(contentsOfURL: url)
        resource?.writeToFile(filePath, atomically: true)
    }
    
    return resource
    
}

func getResourceWithCacheInBackground(fromURL url:NSURL, withBlock block: (resource:NSData?) ->()) {
    
    let gcdQueue:dispatch_queue_t = dispatch_queue_create("Resources", DISPATCH_QUEUE_SERIAL)
    
    dispatch_async(gcdQueue) {
        
        let resource:NSData? = getResourceWithCache(fromURL: url)
        
        dispatch_async(dispatch_get_main_queue(), {
            
            block(resource: resource)
            
        })
        
    }
    
}
