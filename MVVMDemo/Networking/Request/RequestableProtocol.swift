//
//  RequestProtocol.swift
//  MVVMDemo
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/8/18.
//  Copyright © 2018 Demo. All rights reserved.
//

import Foundation

enum HTTPMethod:String{
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol Requestable {
    var URI: String { get set }
    var httpMethod: HTTPMethod { get set }
    var timeoutInterval: TimeInterval { get set }
    var queryParams: [String:String]? { get set }
    var bodyParams: [String:Any]? { get set }
    var headers: [String:Any]? { get set }
}

/// Provided default implementations for requirements that are not mandatory for every request
extension Requestable{
    var queryParams: [String:String]? {
        get{
           return nil
        }
        set{
        }
    }
    
    var timeoutInterval: TimeInterval {
        get{
            return 30.0
        }
        set{
        }
    }

    var bodyParams: [String:Any]? {
        get{
            return nil
        }
        set{
        }
    }
    var headers: [String:Any]? {
        get{
            return nil
        }
        set{
        }
    }
}
