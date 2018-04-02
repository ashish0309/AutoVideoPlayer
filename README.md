# AutoVideoPlayer
Play/pause videos automatically in UITableview when an UITableViewCell is in focus, videos can be easily embedded in any UITableViewCell subclass.
Can be easily extended to support UICollectionView

* Easily implement video player in any UITableView subclass
* Automatic video play when video view is visible and option to easily pause/play any video
* Mute/Unmute videos
* Videos are cached in memory and will be removed when there is memory pressure
* The scroll of UITableView is super smooth since video assets are downloaded on background thread and played only when assets are      completely downloaded ensuring the main thead is never blocked
* Option to provide different bit rate for videos
* Works when the app comes again from background

It can also be used to play videos in any subclass of UIView.

## Demo
![](https://i.imgur.com/Q4ElIJt.gif)


## Download
Drag and drop the VideoPlayLibrary folder in your project
## Usage

#### Adopt ASAutoPlayVideoLayerContainer protocol in your UITableviewCell subclass like below.

```
var videoLayer: AVPlayerLayer = AVPlayerLayer()
    
var videoURL: String? {
    didSet {
        if let videoURL = videoURL {
            ASVideoPlayerController.sharedVideoPlayer.setupVideoFor(url: videoURL)
        }
        videoLayer.isHidden = videoURL == nil
    }
}
```
Implement following method to return the visible height of the UITableViewCell
```
func visibleVideoHeight() -> CGFloat {
  //return visible height of the Video Player layer
}
```

#### ViewController Code

Put following code in viewDidLoad
```
NotificationCenter.default.addObserver(self,
                                       selector: #selector(self.appEnteredFromBackground),
                                       name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
```

Add following code to play/pause when view appears/disappears
```
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    pausePlayeVideos()
}
```
Add following methods

```
@objc func appEnteredFromBackground() {
    ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView, appEnteredFromBackground: true)
}

func pausePlayeVideos(){
    ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView)
}
```

Add following code in UITableView delegate and datasource methods
```
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //if cell adopts ASAutoPlayVideoLayerContainer protocol then
    //set videoURL if you want to show video or else nil
}

func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let videoCell = cell as? ASAutoPlayVideoLayerContainer, videoCell.videoURL != nil {
        ASVideoPlayerController.sharedVideoPlayer.removeLayerFor(cell: videoCell)
    }
}
```
Add following code to pause/play videos when scroll stops
```
func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
        pausePlayeVideos()
    }
}
func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    pausePlayeVideos()
}
```
