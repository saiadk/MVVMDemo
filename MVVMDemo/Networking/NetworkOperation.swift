//
//  NetworkOperation.swift
//  MVVMDemo
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/8/18.
//  Copyright © 2018 Demo. All rights reserved.
//

import UIKit
typealias serviceCompletionHandler = (Data?, Error?)-> Void


/// Allows to trigger a web service based on the request generator provided
class NetworkOperation: Operation, URLSessionTaskDelegate {

    let request:Requestable
    let completionHandler: (_ response: Data?, _ error: Error?) -> Void
    let timeoutInterval: TimeInterval
    
    
    /// Initilizes NetworkOperation class
    ///
    /// - Parameters:
    ///   - request: Request generator type that confirms Requestable protocol
    ///   - timeoutInterval:  request/response Interval decides how long it should try hitting a request & getting response
    ///   - completionHandler: Passes web service resutls
    init(withRequest request: Requestable, timeoutInterval:TimeInterval = 8.0, completionHandler: @escaping serviceCompletionHandler) {
        self.request = request
        self.timeoutInterval = timeoutInterval
        self.completionHandler = completionHandler
        super.init()
    }
    
    /// Entry point for webservice operation
    override open func main() {
        
        guard let serviceURL = self.getServiceURL() else{
            return completionHandler(nil, nil)
        }

        // Create URLSessionCofiguration object
        let urlSession = URLSession(configuration: self.getSessionConfig())
        let urlRequest: URLRequest = self.getURLReqeust(withServiceURL: serviceURL) as URLRequest
        let task = urlSession.dataTask(with: urlRequest, completionHandler: {
            (data: Data?, response: URLResponse?, error:Error?) -> Void in
            
            // Read the http status code in the http response
            guard let responseData = data as Data?,
                let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode == 200
                else {
                    self.completionHandler(nil, error)
                    return
            }
            self.completionHandler(responseData, nil)
            return
        })
        task.resume()
    }
    
    
    /// Returns service URL by adding query string to it from request generator if needed
    ///
    /// - Returns: Web service URL
    private func getServiceURL()->URL?{
        var serviceURL = request.URI
        if let queryStringDict = request.queryParams  {
            let queryString = queryStringDict.map({ "\($0.0)=\($0.1)" }).joined(separator: "&")
            serviceURL += queryString
        }
        return URL(string: serviceURL)
    }
    
    
    /// Returns session config object
    ///
    /// - Parameters:
    ///   - timeout: timeoutIntervalForRequest
    ///   - maxConnctionPerHost: httpMaximumConnectionsPerHost
    /// - Returns: URLSessionConfiguration
    private func getSessionConfig(_ timeout:TimeInterval = 30.0, maxConnctionPerHost:Int = 10) -> URLSessionConfiguration {
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.timeoutIntervalForRequest = timeout
        sessionConfig.httpMaximumConnectionsPerHost = maxConnctionPerHost
        sessionConfig.allowsCellularAccess = true
        sessionConfig.timeoutIntervalForResource = timeout
        sessionConfig.urlCache = nil
        sessionConfig.urlCredentialStorage = nil
        sessionConfig.httpCookieStorage = HTTPCookieStorage.shared
        return sessionConfig;
    }
    
    
    
    /// Returns NSMutableURLRequest object
    ///
    /// - Parameter serviceURL: Web service URL
    /// - Returns: NSMutableURLRequest object
    private func getURLReqeust(withServiceURL serviceURL:URL) -> NSMutableURLRequest{
        
        //Create and configure request object with data provided through Requestable object
        let requestObj:NSMutableURLRequest = NSMutableURLRequest(url: serviceURL)
        requestObj.httpMethod = request.httpMethod.rawValue
        requestObj.timeoutInterval = request.timeoutInterval
        requestObj.httpBody = self.getRequestBodyData()
        
        //Add request headers if necessary
        if let headers = request.headers {
            for (headerKey, headerValue) in headers{
                if let headerValue = headerValue as? String{
                    requestObj.setValue(headerValue, forHTTPHeaderField: headerKey)
                }
            }
        }
        
        return requestObj
    }
    
    
    /// Retunrs web service request body
    ///
    /// - Returns: Body as Data object
    private func getRequestBodyData()->Data? {
        guard let bodyParams = request.bodyParams else {
            return nil
        }
        do {
            let theJSONData = try JSONSerialization.data(withJSONObject: bodyParams, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            return theJSONData
        }
        catch _ {
            return nil
        }
    }
}
