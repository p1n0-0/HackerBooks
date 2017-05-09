//
//  BookTests.swift
//  HackerBooks
//
//  Created by Francisco Solano Gómez Pino on 08/05/2017.
//  Copyright © 2017 Francisco Solano Gómez Pino. All rights reserved.
//

import XCTest
@testable import HackerBooks

class BookTests: XCTestCase {
	
	var book:Book?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		
		self.book = Book(id:"", title: "Example", authors: ["a1","a2"], tags: ["t1","t2"], imageURL: URL(string:"http://example.com/image")!, pdfURL: URL(string:"http://example.com/pdf")!, image: #imageLiteral(resourceName: "AppLogo"))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
		
		self.book = nil
    }
	
	func testAuthorsStringBook(){
		
		XCTAssertEqual(book!.authorsString, "a1 and a2", "Authors strings is not equal")
		
	}
	
	func testTagsStringBook(){
		
		XCTAssertEqual(book!.tagsString, "t1 and t2", "Tags strings is not equal")
		
	}
}
