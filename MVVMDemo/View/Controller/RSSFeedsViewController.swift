//
//  ViewController.swift
//  MVVMDemo
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/8/18.
//  Copyright © 2018 Demo. All rights reserved.
//

import UIKit

class RSSFeedsViewController: UIViewController {

    //MARK: Store & Computed Properties
    
    //ViewModel reference
    var feedsViewModel:RSSFeedsViewModel!{
        didSet{
            feedsViewModel.feedsViewModelDelegate = self
        }
    }
    
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topRatedAppsCollectionView: UICollectionView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var collectionDisplayModeBarButton: UIBarButtonItem!
    private var imageDownloadsInProgress = [IndexPath:Operation]()
    
    private var showActivity:Bool{
        get{
            return !activityIndicator.isAnimating
        }
        set {
            DispatchQueue.main.async {
                if newValue{
                    self.activityIndicator.startAnimating()
                    self.statusLbl.text = self.feedsViewModel.loadingMsg
                    self.statusLbl.isHidden = false
                    self.containerView.isHidden = true
                }else{
                    self.activityIndicator.stopAnimating()
                    self.statusLbl.isHidden = true
                    self.containerView.isHidden = false
                }
            }
        }
    }
    
    
    //MARK: View Controller Life Cycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.feedsViewModel = RSSFeedsViewModel.shared
        self.title = feedsViewModel.feedsTitle
        statusLbl.isHidden = true
        containerView.isHidden = true
        feedsViewModel.initFeedsLayoutStyle()
        
        //Load top rated apps list from iTunes RSS API
        loadRSSFeeds()
    }

    
    //MARK: Custom Functions
    
    
    
    /// Loads RSS feeds with the given preferences
    private func loadRSSFeeds(){
        
        //Reset previously loaded apps
        feedsViewModel.resetFeedsList()
        
        //Show activity indicator
        showActivity = true
        
        //Fetch RSS feeds
        RSSFeedsViewModel.fetchRSSFeeds(){ (status:Bool) in
            if status{
                self.feedsViewModel = RSSFeedsViewModel.shared
                DispatchQueue.main.async {
                    self.topRatedAppsCollectionView.reloadData()
                    self.collectionDisplayModeBarButton.isEnabled = !self.feedsViewModel.feedsList.isEmpty
                    self.showActivity = false
                    self.refreshButton.isEnabled = true
                }
            }else {
                self.showActivity = false
                DispatchQueue.main.async {
                    self.containerView.isHidden = true
                    self.statusLbl.text = self.feedsViewModel.appsNotFoundMsg
                    self.statusLbl.isHidden = false
                    self.refreshButton.isEnabled = true
                }
            }
        }
    }
    
    
    /// Toggles the feeds collectionview layout between list and grid styles
    ///
    /// - Parameter sender: UIBarButtonItem which invokes this function
    @IBAction func toggleCollectionViewDisplayMode(_ sender: Any) {
        feedsViewModel.toggleFeedsLayoutStyle()
    }

    
    /// Refreshes RSS feeds to pull latest changes in iTunes
    ///
    /// - Parameter sender: UIBarButtonItem which invokes this function
    @IBAction func refreshRSSFeeds(_ sender: Any) {
        //Disable refresh button until current refresh action completes
        refreshButton.isEnabled = false
        loadRSSFeeds()
    }
    
    
    
    /// Dwonloads the feed's artwork image in background with downloadTask / dataTask (if changes made by uncommenting some code)
    ///
    /// - Parameters:
    ///   - artworkURL: Feed's icon artwork image URL string
    ///   - indexPath: Current RSS feed's cell view indexpath in collection view
    private func downloadArtwork(withURL artworkURL:String, forAppAtIndexPath indexPath:IndexPath){
        
        //Check if image download is already in progress
        if imageDownloadsInProgress[indexPath] == nil &&
            feedsViewModel.feedsList.count > 0 {
            
            //Nested function
            func updateImageInCellWith(indexPath:IndexPath){
                DispatchQueue.main.async {
                    if self.feedsViewModel.feedsList.count > 0 {
                        self.topRatedAppsCollectionView.reloadItems(at: [indexPath])
                    }
                }
            }
            
            /************************************************************************************************
             Comment this code (till line 156) and uncomment next block to download image with dataTask
             ************************************************************************************************/

            
            //Download feed icon image in background session downloadTask API. This will download image even in case of app crash / app sent to inactive state / system kills the app.
            let imgDownloadOperation = ImageDownloadOperation(withURL: artworkURL, completionHandler: {  (image, error) -> Void in
                if let image = image, self.feedsViewModel.feedsList.count > 0{
                    var feedModel = self.feedsViewModel.feedsList[indexPath.row]
                    feedModel.icon = image
                    self.feedsViewModel.feedsList[indexPath.row] = feedModel
                    self.imageDownloadsInProgress.removeValue(forKey: indexPath)
                    updateImageInCellWith(indexPath: indexPath)
                }
            })
            imageDownloadsInProgress[indexPath] = imgDownloadOperation
            imgDownloadOperation.start()
            

            
            /************************************************************************************************
                Uncomment this code  to reusing network operation to download image with dataTask
            ************************************************************************************************/
            
            
//            struct ImageDownloadRequest: Requestable {
//                var URI:String
//                var httpMethod = HTTPMethod.get
//                init(artworkURL: String) {
//                    self.URI = artworkURL
//                }
//            }
//
//            //Invoke web service with the request configuration created
//            let imgDownloadOperation = NetworkOperation(withRequest: ImageDownloadRequest(artworkURL:artworkURL), completionHandler: { (response, error) -> Void in
//
//                //Validate & decode response with JSONDecoder API
//                if let response = response, let image = UIImage(data:response){
//
//                    var feedModel = self.feedsViewModel.feedsList[indexPath.row]
//                    feedModel.icon = image
//                    self.feedsViewModel.feedsList[indexPath.row] = feedModel
//                    self.imageDownloadsInProgress.removeValue(forKey: indexPath)
//                    updateImageInCellWith(indexPath: indexPath)
//                }
//            })
//            imageDownloadsInProgress[indexPath] = imgDownloadOperation
//            imgDownloadOperation.start()
            
        }

    }
    
}



// MARK: - UIScrollViewDelegate
extension RSSFeedsViewController: UIScrollViewDelegate{
   
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate{
            loadVisibleCellIcons()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadVisibleCellIcons()
    }
    
    func loadVisibleCellIcons(){
        if feedsViewModel.feedsList.count > 0{
            for indexPath in topRatedAppsCollectionView.indexPathsForVisibleItems{
                let feedItemModel = feedsViewModel.feedsList[indexPath.row]
                if feedItemModel.icon == nil{
                    downloadArtwork(withURL: feedItemModel.artworkURL, forAppAtIndexPath: indexPath)
                }
            }
        }
    }
}


// MARK: - RSSFeedsViewModelDelegate
extension RSSFeedsViewController: RSSFeedsViewModelDelegate {
    func feedsLayoutDidChanged(toType feedsLayoutStyle:FeedsLayoutStyle){
        
        var layout: UICollectionViewFlowLayout{
            let layout = UICollectionViewFlowLayout()
            let numberOfColumns = CGFloat((feedsLayoutStyle == .list) ? 1 : 2)
            let itemWidth = (UIScreen.main.bounds.size.width - 20 - (numberOfColumns - 1)) / numberOfColumns
            layout.itemSize = CGSize(width:itemWidth, height:100)
            return layout
        }
        //Change toggle button title and change layout without reloading collection view
        let layoutFlipSideStyle:FeedsLayoutStyle = (feedsLayoutStyle == .list) ? .grid : .list
        collectionDisplayModeBarButton.title = layoutFlipSideStyle.rawValue
        topRatedAppsCollectionView.setCollectionViewLayout(layout, animated: true, completion: { status -> Void in
            self.topRatedAppsCollectionView.setContentOffset(.zero, animated: true)
        })
    }
}


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

// Configure collection view items by defining collection view's delegate & datasource functions
extension RSSFeedsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return feedsViewModel.feedsSectionCount
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return feedsViewModel.feedsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        //Initialize app collection cell object with reuse identifier based on the display style preferred
        let appDetailsCell = collectionView.dequeueReusableCell(withReuseIdentifier: feedsViewModel.getFeedsLayoutStyle().reuseIdentifier, for: indexPath) as! AppDetailsListViewCell
        
        
        //Get model object for current cell
        let feedViewModel = feedsViewModel.feedsList[indexPath.row]
        
        //Configure with grid cell details
        if let appIcon = feedViewModel.icon{
            appDetailsCell.iconView.image = appIcon
        }else{
            //Show placeholder icon image for time being
            appDetailsCell.iconView.image = #imageLiteral(resourceName: "Placeholder")
            self.downloadArtwork(withURL: feedViewModel.artworkURL, forAppAtIndexPath: indexPath)
        }
        appDetailsCell.name.text = feedViewModel.name
        appDetailsCell.artistName.text = feedViewModel.artistName
        appDetailsCell.releaseDate.text = feedViewModel.formattedDate
        
        return appDetailsCell
    }

}

