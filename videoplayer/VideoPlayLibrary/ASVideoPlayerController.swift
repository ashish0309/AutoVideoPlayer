//
//  VideoPlayerController.swift
//  AutoPlayVideo
//
//  Created by Ashish Singh on 12/3/17.
//  Copyright © 2017 Ashish. All rights reserved.
//

import UIKit
import AVFoundation

protocol ASAutoPlayVideoLayerContainer {
    var videoURL: String? { get set }
    var videoLayer: AVPlayerLayer { get set }
    func visibleVideoHeight() -> CGFloat
}

class ASVideoPlayerController: NSObject, NSCacheDelegate {
    static private var playerViewControllerKVOContext = 0
    static let sharedVideoPlayer = ASVideoPlayerController()
    
    private var videoURL: String?
    private var observingURLs = Dictionary<String, Bool>()
    private var videoCache = NSCache<NSString, ASVideoObject>()
    private var videoLayers = VideoLayers()
    private var currentLayer: AVPlayerLayer?
    
    override init() {
        super.init()
        videoCache.delegate = self
    }
    
    func setUpNewPlayerObjectForURL(url: String) {
        if let _ = self.videoCache.object(forKey: url as NSString) {
            return
        }
        guard let URL = URL(string: url) else {
            return
        }
        let asset = AVURLAsset(url: URL)
        let requestedKeys = ["playable"]
        asset.loadValuesAsynchronously(forKeys: requestedKeys) { [unowned self] in
            let player = AVPlayer()
            let item = AVPlayerItem(asset: asset)
            DispatchQueue.main.async {
                self.videoCache.setObject(ASVideoObject(player: player, item: item, url: url), forKey: url as NSString)
                let videoObject = self.videoCache.object(forKey: url as NSString)
                videoObject?.player.replaceCurrentItem(with: videoObject?.playerItem)
                //try to play video again in case when playvideo method was called and
                //asset was not obtained, so, earlier video must have not run
                if self.videoURL == url, let layer = self.currentLayer {
                    self.playVideoWithLayer(layer: layer, url: url)
                }
            }
        }
    }
    
    func playVideoWithLayer(layer: AVPlayerLayer, url: String) {
        videoURL = url
        currentLayer = layer
        if let vObject = self.videoCache.object(forKey: url as NSString) {
            layer.player = vObject.player
            vObject.playOn = true
            addObservers(url: url, vObject: vObject)
        }
        //give chance for current video player to be ready to play
        DispatchQueue.main.async {
            if let vObject = self.videoCache.object(forKey: url as NSString), vObject.player.currentItem?.status == .readyToPlay  {
                vObject.playOn = true
            }
        }
    }
    
    private func pauseVideoWithLayer(layer: AVPlayerLayer, url: String) {
        videoURL = nil
        currentLayer = nil
        if let vObject = self.videoCache.object(forKey: url as NSString) {
            vObject.playOn = false
            vObject.play = false
            removeObserverFor(url: url)
        }
    }
    
    func removeLayerFor(cell: ASAutoPlayVideoLayerContainer) {
        if let url = cell.videoURL {
            removeFromSuperLayer(layer: cell.videoLayer, url: url)
        }
    }
    
    private func removeFromSuperLayer(layer: AVPlayerLayer, url: String) {
        videoURL = nil
        currentLayer = nil
        if let vObject = self.videoCache.object(forKey: url as NSString) {
            vObject.playOn = false
            removeObserverFor(url: url)
        }
        layer.player = nil
    }
    
    private func addObservers(url: String, vObject: ASVideoObject) {
        if self.observingURLs[url] == false || self.observingURLs[url] == nil {
            vObject.player.currentItem?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: &ASVideoPlayerController.playerViewControllerKVOContext)
            NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: vObject.player.currentItem)
            self.observingURLs[url] = true
        }
    }
    
    private func removeObserverFor(url: String) {
        if let vObject = self.videoCache.object(forKey: url as NSString) {
            if let currentItem = vObject.player.currentItem, observingURLs[url] == true {
                currentItem.removeObserver(self, forKeyPath: "status", context: &ASVideoPlayerController.playerViewControllerKVOContext)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: currentItem)
                observingURLs[url] = false
            }
        }
    }

    //play video again in case the current player has finished playing
    @objc func playerDidFinishPlaying(note: NSNotification) {
        if let playerItem = note.object as? AVPlayerItem, let currentPlayer = currentVideoObject()?.player {
            if let currentItem = currentPlayer.currentItem, currentItem == playerItem {
                currentPlayer.seek(to: kCMTimeZero)
                currentPlayer.play()
            }
        }
    }
    
    private func currentVideoObject() -> ASVideoObject? {
        if let currentVideoUrl = videoURL {
            if let vObject = videoCache.object(forKey: currentVideoUrl as NSString) {
                return vObject
            }
        }
        return nil
    }
    
    private func pauseRemoveLayer(layer: AVPlayerLayer,url: String, layerHeight: CGFloat) {
        pauseVideoWithLayer(layer: layer, url: url)
    }
    
    // Play video only when current videourl's player is readytoplay
     override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        // Make sure the this KVO callback was intended for this view controller.
        guard context == &ASVideoPlayerController.playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if keyPath == "status" {
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newStatus: AVPlayerItemStatus
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
                if newStatus == .readyToPlay {
                    if let item = object as? AVPlayerItem, let currentItem = currentVideoObject()?.player.currentItem {
                        if item == currentItem && currentVideoObject()?.playOn == true {
                            currentVideoObject()?.playOn = true
                        }
                    }
                }
            }
            else {
                newStatus = .unknown
            }
            
            if newStatus == .failed {
                
            }
        }
    }
    
    //play uitablecell's videoplayer that has max visible height when the scroll stops
    //max height should be atleast comparable to the video layer height
    func pausePlayeVideosFor(tableView: UITableView, appEnteredFromBackground: Bool = false) {
        let visisbleCells = tableView.visibleCells
        var cell: ASAutoPlayVideoLayerContainer?
        var maxHeight: CGFloat = 0.0
        for cellView in visisbleCells {
            if let containerCell = cellView as? ASAutoPlayVideoLayerContainer, let videoCellUrl = containerCell.videoURL {
                let height = containerCell.visibleVideoHeight()
                if maxHeight < height {
                    maxHeight = height
                    cell = containerCell
                }
                pauseRemoveLayer(layer: containerCell.videoLayer, url: videoCellUrl, layerHeight: height)
            }
        }
        if let vCell = cell, let videoCellUrl = vCell.videoURL, maxHeight > vCell.videoLayer.bounds.size.height - 30 {
            if appEnteredFromBackground {
                setUpNewPlayerObjectForURL(url: videoCellUrl)
            }
            playVideoWithLayer(layer: vCell.videoLayer, url: videoCellUrl)
        }
    }
    
    //set observing urls false when objects are removed from cache
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        if let videoObject = obj as? ASVideoObject {
            observingURLs[videoObject.url] = false
        }
    }
    
    deinit {
        
    }
}
