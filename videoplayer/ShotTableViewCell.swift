//
//  ShotTableViewCell.swift
//  AutoPlayVideo
//
//  Created by Ashish Singh on 7/21/17.
//  Copyright © 2017 Ashish. All rights reserved.
//

import UIKit
import AVFoundation
class ShotTableViewCell: UITableViewCell, ASAutoPlayVideoLayerContainer {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var shotImageView: UIImageView!
    var playerController: ASVideoPlayerController?
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    
    var videoURL: String? {
        didSet{
            if videoURL != nil{
                ASVideoPlayerController.sharedVideoPlayer.setUpNewPlayerObjectForURL(url: videoURL!)
            }
            videoLayer.isHidden = videoURL == nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shotImageView.layer.cornerRadius = 5
        shotImageView.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        shotImageView.clipsToBounds = true
        shotImageView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        shotImageView.layer.borderWidth = 0.5
        videoLayer.backgroundColor = UIColor.clear.cgColor
        videoLayer.videoGravity = AVLayerVideoGravity.resize
        shotImageView.layer.addSublayer(videoLayer)
    }
    
    func configureCell(imageUrl: String?, description: String, videoUrl: String?){
        self.descriptionLabel.text = description
        self.shotImageView.imageURL = imageUrl
        self.videoURL = videoUrl
    }

    override func prepareForReuse() {
        shotImageView.imageURL = nil
        super.prepareForReuse()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width: CGFloat = bounds.size.width - 30 - 16
        videoLayer.frame = CGRect(x: 0, y: 0, width: width, height: width * 0.9)
    }
    
    func visibleVideoHeight() -> CGFloat {
        var frame: CGRect? = self.superview?.superview?.convert(shotImageView.frame, from: shotImageView)
        if let convertedFrame = frame, let superView = self.superview?.superview {
            frame = convertedFrame.intersection(superView.frame)
            return frame!.size.height
        }
        return 0
    }
}
