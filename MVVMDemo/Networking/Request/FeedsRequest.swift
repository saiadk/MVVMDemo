//
//  TopRatedAppsRequest.swift
//  MVVMDemo
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/8/18.
//  Copyright © 2018 Demo. All rights reserved.
//

import Foundation


/// RSS Feeds request generator
struct FeedsRequest: Requestable {
    var URI = "https://rss.itunes.apple.com/api/v1/us/apple-music/coming-soon/all/50/explicit.json"
    var httpMethod = HTTPMethod.get
}
