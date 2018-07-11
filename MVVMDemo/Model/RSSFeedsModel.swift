//
//  AppDataModel.swift
//  MVVMDemo
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/8/18.
//  Copyright © 2018 Demo. All rights reserved.
//

import Foundation
import UIKit

typealias feedModelCompletionHandler = (RSSFeedsModel?, Error?)-> Void

struct RSSFeedsModel: Decodable {
    let feeds: Feeds
    
    enum CodingKeys: String, CodingKey {
        case feeds = "feed"
    }
}

extension RSSFeedsModel{
    
    //Factory method that creates & initializes model object with data from web service
    static func getRSSFeedsModel(feedModelCompletionHandler:@escaping feedModelCompletionHandler){
        
        //Initilize requestable object useful in creating URLRequest
        let requestObj = FeedsRequest()
        
        //Invoke web service with the request configuration created
        NetworkOperation(withRequest: requestObj, completionHandler: { (response, error) -> Void in
            
            //Validate & decode response with JSONDecoder API
            if let response = response{
                
                //Convert response data to dictionary and access array of apps value dicrectly and convert them into data to make it compatible to use Decodable protocol for the time being to avoid more model classes
                do {
                    let decoder = JSONDecoder()
                    let rssFeedsModel = try decoder.decode(RSSFeedsModel.self, from: response)
                    feedModelCompletionHandler(rssFeedsModel, nil)
                }
                catch _ {
                    #if DEBUG
                        print("Response is empty")
                    #endif
                    feedModelCompletionHandler(nil, nil)
                }
            }else{
                feedModelCompletionHandler(nil, error)
            }
            
        }).start()
        
    }

}

struct Feeds: Decodable {
    let list: [Feed]
    
    enum CodingKeys: String, CodingKey {
        case list = "results"
    }
}

struct Feed: Decodable {
    let artistName, id, releaseDate: String
    let name: String
    let artworkURL: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case artistName, id, releaseDate, name, url
        case artworkURL = "artworkUrl100"
    }
}
