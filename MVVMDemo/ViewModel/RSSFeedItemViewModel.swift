//
//  RSSFeedCellViewModel.swift
//  MVVMDemo
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/10/18.
//  Copyright © 2018 Demo. All rights reserved.
//

import Foundation
import UIKit


/// Feed cell view model
struct RSSFeedItemViewModel {
    let name, artistName, artworkURL, releaseDate: String
    var icon: UIImage? = nil
    
    //Data formatters
    var formattedDate:String? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatterGet.date(from: releaseDate){
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMM dd, yyyy"
            return dateFormatterPrint.string(from: date)
        }
        return nil
    }
}
