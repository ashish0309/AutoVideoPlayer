//
//  ViewController.swift
//  AutoPlayVideo
//
//  Created by Ashish Singh on 7/21/17.
//  Copyright © 2017 Ashish. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let shotTableViewCellIdentifier = "ShotTableViewCell"
    let loadingCellTableViewCellCellIdentifier = "LoadingCellTableViewCell"
    var refreshControl: UIRefreshControl!
    let videos = [
                  "https://i.pinimg.com/564x/ba/a3/07/baa307a7de3030f0073c56fa95ab2a3c.jpg",
                  "https://v.pinimg.com/videos/720p/77/4f/21/774f219598dde62c33389469f5c1b5d1.mp4",
                  "https://i.pinimg.com/564x/ef/17/51/ef17519f5e473adc01dfd64c35cf44d4.jpg",
                  "https://i.pinimg.com/564x/6f/5f/fb/6f5ffb82a1f9a9f7e478b8a2486831f5.jpg",
                  "https://v.pinimg.com/videos/720p/75/40/9a/75409a62e9fb61a10b706d8f0c94de9a.mp4",
                  "https://v.pinimg.com/videos/720p/0d/29/18/0d2918323789eabdd7a12cdd658eda04.mp4",
                  "https://i.pinimg.com/564x/97/a5/51/97a5513d3c512eb382e564ba542d917b.jpg",
                  "https://v.pinimg.com/videos/720p/dd/24/bb/dd24bb9cd68e9e25d1def88cad0a9ea7.mp4",
                  "https://i.pinimg.com/564x/72/c1/a8/72c1a8aabbfe782643c4a5e739ec0ed2.jpg",
                  "https://v.pinimg.com/videos/720p/d5/15/78/d51578c69d36c93c6e20144e9f887c73.mp4",
                  "https://v.pinimg.com/videos/720p/c2/6d/2b/c26d2bacb4a9f6402d2aa0721193e06e.mp4",
                  "https://i.pinimg.com/564x/e2/fc/bc/e2fcbc98ceeb7d9316f8b4c889440bf7.jpg",
                  "https://v.pinimg.com/videos/720p/62/81/60/628160e025f9d61b826ecc921b9132cd.mp4",
                  "https://v.pinimg.com/videos/720p/5f/aa/3d/5faa3d057eb31dd05876f622ea2e7502.mp4",
                  "https://v.pinimg.com/videos/720p/65/b0/54/65b05496c385c89f79635738adc3b15d.mp4",
                  "https://i.pinimg.com/564x/3c/52/d3/3c52d31a1b388ea584175f7859fb23e7.jpg",
                  "https://i.pinimg.com/564x/4c/32/ee/4c32ee62af42bacec8c50ddfd10ade63.jpg",
                  "https://i.pinimg.com/564x/94/cb/29/94cb29d0279e376c6d89fe9a31191f94.jpg",
                  "https://v.pinimg.com/videos/720p/86/a1/c6/86a1c63fc58b2e1ef18878b7428912dc.mp4"
                ]
    
    let videoImages = [
                       "https://i.pinimg.com/videos/thumbnails/originals/77/4f/21/774f219598dde62c33389469f5c1b5d1-00001.jpg",
                       "https://i.pinimg.com/videos/thumbnails/originals/75/40/9a/75409a62e9fb61a10b706d8f0c94de9a-00001.jpg",
                       "https://i.pinimg.com/videos/thumbnails/originals/0d/29/18/0d2918323789eabdd7a12cdd658eda04-00001.jpg",
                       "https://i.pinimg.com/videos/thumbnails/originals/dd/24/bb/dd24bb9cd68e9e25d1def88cad0a9ea7-00001.jpg",
                       "https://i.pinimg.com/videos/thumbnails/originals/d5/15/78/d51578c69d36c93c6e20144e9f887c73-00001.jpg",
                       "https://i.pinimg.com/videos/thumbnails/originals/c2/6d/2b/c26d2bacb4a9f6402d2aa0721193e06e-00001.jpg",
                       "https://i.pinimg.com/videos/thumbnails/originals/62/81/60/628160e025f9d61b826ecc921b9132cd-00001.jpg",
                       "https://i.pinimg.com/videos/thumbnails/originals/5f/aa/3d/5faa3d057eb31dd05876f622ea2e7502-00001.jpg",
                       "https://i.pinimg.com/videos/thumbnails/originals/65/b0/54/65b05496c385c89f79635738adc3b15d-00001.jpg",
                       "https://i.pinimg.com/videos/thumbnails/originals/86/a1/c6/86a1c63fc58b2e1ef18878b7428912dc-00001.jpg"
                      ]
    let videoIndexes = [1:0, 4:1, 5:2, 7:3, 9:4, 10:5, 12:6, 13:7, 14:8, 18:9]
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        var cellNib = UINib(nibName:shotTableViewCellIdentifier, bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: shotTableViewCellIdentifier)
        cellNib = UINib(nibName:loadingCellTableViewCellCellIdentifier, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: loadingCellTableViewCellCellIdentifier)
        tableView.separatorStyle = .none
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appEnteredFromBackground),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pausePlayeVideos()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: shotTableViewCellIdentifier, for: indexPath) as! ShotTableViewCell
        if let videoIndex = videoIndexes[indexPath.row] {
            cell.configureCell(imageUrl: videoImages[videoIndex], description: "Video", videoUrl: videos[indexPath.row])
        }
        else{
            cell.configureCell(imageUrl: videos[indexPath.row], description: "Image", videoUrl: nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let videoCell = cell as? ASAutoPlayVideoLayerContainer, let _ = videoCell.videoURL {
            ASVideoPlayerController.sharedVideoPlayer.removeLayerFor(cell: videoCell)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pausePlayeVideos()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            pausePlayeVideos()
        }
    }
    
    func pausePlayeVideos(){
        ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView)
    }
    
    @objc func appEnteredFromBackground() {
        ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView, appEnteredFromBackground: true)
    }
}

