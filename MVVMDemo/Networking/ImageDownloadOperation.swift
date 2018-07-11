//
//  ImageAsyncDownloadOperation.swift
//  MVVMDemo
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/8/18.
//  Copyright © 2018 Demo. All rights reserved.
//

import UIKit


fileprivate let imageCache = NSCache<NSString, UIImage>()
typealias imageDownloadCompletionHandler = (UIImage?, Error?)-> Void


class ImageDownloadOperation: Operation, URLSessionDownloadDelegate {
    
    let imageURL: String
    let completionHandler: (_ image: UIImage?, _ error: Error?) -> Void
    let timeoutInterval: TimeInterval
    
    init(withURL imageURL: String, timeoutInterval:TimeInterval = 8.0, completionHandler: @escaping imageDownloadCompletionHandler) {
        self.imageURL = imageURL
        self.timeoutInterval = timeoutInterval
        self.completionHandler = completionHandler
        super.init()

    }
    
    override open func main() {
        
        //Check if image is already added to cache and try to reuse, if yes.
        if let cachedImage = imageCache.object(forKey: imageURL as NSString) {
            print("Reusing cached image ...")
            self.completionHandler(cachedImage, nil)
        } else {
            //Download image in background session with downloadTask API
            downloadImageInBackground(imageURL)
        }

    }
    
    func downloadImageInBackground(_ imgURL:String) {
        
        let imgURL:URL! = URL(string: imgURL)
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: UUID().uuidString)
        let session = Foundation.URLSession(configuration: sessionConfig, delegate: self, delegateQueue: Foundation.OperationQueue.main)
        let task = session.downloadTask(with: imgURL)
        task.resume()
        
    }
    
    
    // MARK: - NSURLSessionDelegate
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let _ = downloadTask.originalRequest?.url?.absoluteString else{
            #if DEBUG
                print("Error: Failed to download image.")
            #endif
            self.completionHandler(nil, nil)
            return
        }
        do{
            let data = try Data(contentsOf: location)
            
            //Store image in cache to reuse without downloading again
            if let image = UIImage(data:data){
                imageCache.setObject(image, forKey: imageURL as NSString)
                self.completionHandler(image, nil)
                print("Downloading image ...")
                return
            }
        }catch _{
        }
        self.completionHandler(nil, nil)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?){
        //Invalidate session after each download to avoid memory leaks
        session.finishTasksAndInvalidate()
        if let error = error {
            #if DEBUG
                print("Failed to download image. Error:\(error)")
            #endif
            self.completionHandler(nil, error)
        }
    }
    
}

