//
//  RSSFeedItemViewModelTests.swift
//  MVVMDemoTests
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/10/18.
//  Copyright © 2018 Demo. All rights reserved.
//

import XCTest
@testable import MVVMDemo

class RSSFeedItemViewModelTests: XCTestCase {
    
    var feedItemViewModel:RSSFeedItemViewModel!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        feedItemViewModel = RSSFeedItemViewModel(name: "RSS Feeds", artistName: "Sesha Sai", artworkURL: "dummyURL", releaseDate: "2018-07-07", icon: nil)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        feedItemViewModel = nil
        super.tearDown()
    }
    
    func testFeedItemViewModelValues() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(feedItemViewModel.name == "RSS Feeds", #function)
        XCTAssert(feedItemViewModel.artistName == "Sesha Sai", #function)
        XCTAssert(feedItemViewModel.artworkURL == "dummyURL", #function)
        XCTAssert(feedItemViewModel.releaseDate == "2018-07-07", #function)
        XCTAssertNil(feedItemViewModel.icon, #function)
    }
    
    func testReleaseDateFormat(){
        XCTAssert(feedItemViewModel.releaseDate == "2018-07-07", #function)
        XCTAssert(feedItemViewModel.formattedDate == "Jul 07, 2018", #function)
        XCTAssert(feedItemViewModel.releaseDate != feedItemViewModel.formattedDate, #function)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            testFeedItemViewModelValues()
        }
    }
    
}
