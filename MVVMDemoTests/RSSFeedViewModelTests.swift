//
//  RSSFeedViewModelTests.swift
//  MVVMDemoTests
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/10/18.
//  Copyright © 2018 Demo. All rights reserved.
//

import XCTest
@testable import MVVMDemo

class RSSFeedViewModelTests: XCTestCase {
    
    var feedsViewModel:RSSFeedsViewModel!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        feedsViewModel = RSSFeedsViewModel()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        feedsViewModel = nil
        super.tearDown()
    }
    
    func testStaticCopyText() {
        XCTAssert(feedsViewModel.feedsTitle == "Top 50 Free iOS Apps", #function)
        XCTAssert(feedsViewModel.loadingMsg == "Loading...", #function)
        XCTAssert(feedsViewModel.appsNotFoundMsg == "☹️ No apps found!", #function)
        XCTAssert(feedsViewModel.feedsSectionCount == 1, #function)
    }
    
    func testDefaultLayout(){
        feedsViewModel.initFeedsLayoutStyle()
        XCTAssert(feedsViewModel.getFeedsLayoutStyle() == .list, #function)
    }
    
    func testToggleLayoutStyle(){
        let currentLayoutStyle = feedsViewModel.getFeedsLayoutStyle()
        feedsViewModel.toggleFeedsLayoutStyle()
        XCTAssert(feedsViewModel.getFeedsLayoutStyle() != currentLayoutStyle, #function)
    }

    func testResetFeedsList(){
        feedsViewModel.resetFeedsList()
        XCTAssert(feedsViewModel.feedsList.isEmpty, #function)
    }
    
    func testFeedsViewModelDelegate(){
        class FeedsViewModelDelegateProtocolMock: RSSFeedsViewModelDelegate {
            var feedsLayoutDidChangedCalled = false
            func feedsLayoutDidChanged(toType feedsLayoutStyle:FeedsLayoutStyle){
                feedsLayoutDidChangedCalled = true
            }
        }
        
        let feedsViewModelMock = FeedsViewModelDelegateProtocolMock()
        feedsViewModel.feedsViewModelDelegate = feedsViewModelMock
        XCTAssertFalse(feedsViewModelMock.feedsLayoutDidChangedCalled, #function)
        feedsViewModel.toggleFeedsLayoutStyle()
        XCTAssertTrue(feedsViewModelMock.feedsLayoutDidChangedCalled, #function)

    }
    
    func testFetchRSSFeedsAPI(){
        let feedsExpectation = expectation(description: "FetchRSSFeedsAPI")
        RSSFeedsViewModel.fetchRSSFeeds(){ (status:Bool) in
            XCTAssertTrue(status, #function)
            feedsExpectation.fulfill()
        }
        waitForExpectations(timeout: 20.0){ error in }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            testFetchRSSFeedsAPI()
        }
    }
    
}
