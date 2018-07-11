//
//  RSSFeedsViewModel.swift
//  MVVMDemo
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/10/18.
//  Copyright © 2018 Demo. All rights reserved.
//

import Foundation

typealias feedsCompletionHandler = (Bool)-> Void


/// Enumeration of collection view layout styles
enum FeedsLayoutStyle:String{
    case list = "List"
    case grid = "Grid"
    
    var reuseIdentifier:String{
        return "ListCell"
    }
}


/// RSSFeedsViewModelDelegate
protocol RSSFeedsViewModelDelegate: class{
    func feedsLayoutDidChanged(toType feedsLayoutStyle:FeedsLayoutStyle)
}


/// Feeds ViewModel
struct RSSFeedsViewModel{
    
    // MARK - Stored & Computed Properties
    private var feedsModel: RSSFeedsModel!{
        didSet{
            feedsList = feedsModel.feeds.list.map({
                RSSFeedItemViewModel(name: $0.name, artistName: $0.artistName, artworkURL: $0.artworkURL, releaseDate: $0.releaseDate, icon: nil)
            })
        }
    }
    public static var shared = RSSFeedsViewModel()
    public let feedsSectionCount:Int = 1
    public weak var feedsViewModelDelegate:RSSFeedsViewModelDelegate?
    private var feedsLayout:FeedsLayoutStyle! = .list{
        didSet{
            feedsViewModelDelegate?.feedsLayoutDidChanged(toType: feedsLayout)
        }
    }
    public let feedsTitle = "Top 50 Free iOS Apps"
    public let loadingMsg = "Loading..."
    public let appsNotFoundMsg = "☹️ No apps found!" /// Unicode emoji char
    public var feedsList = [RSSFeedItemViewModel]()
    

    
    /// Allows to access current collection view layout style
    ///
    /// - Returns: FeedsLayoutStyle enumeration type selected
    public func getFeedsLayoutStyle()-> FeedsLayoutStyle{
        return feedsLayout
    }
    
    
    /// To initialize default layout style
    public mutating func initFeedsLayoutStyle(){
        feedsLayout = .list
    }
    
    
    /// Switches layout styles
    public mutating func toggleFeedsLayoutStyle(){
        feedsLayout = (feedsLayout == .list) ? .grid : .list
    }
    
    
    /// Flushes all feeds stored in model
    public mutating func resetFeedsList(){
        feedsList.removeAll()
    }
    
    
    /// Fetchees RSS feeds from model object
    ///
    /// - Parameter feedsCompletionHandler: (Bool)-> Void (Sends the status boolean flag)
    static func fetchRSSFeeds(_ feedsCompletionHandler:@escaping feedsCompletionHandler) {
        
        ///  Trailing closure syntax
        RSSFeedsModel.getRSSFeedsModel {
            (feedsModel:RSSFeedsModel?, error:Error?)-> Void in
            if let feedsModel = feedsModel{
                RSSFeedsViewModel.shared.feedsModel = feedsModel
            }
            feedsCompletionHandler(feedsModel != nil)
        }
    }
    
}
