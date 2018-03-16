//
//  AppImageView.swift
//  AutoPlayVideo
//
//  Created by Ashish Singh on 7/22/17.
//  Copyright © 2017 Ashish. All rights reserved.
//

import Foundation
import UIKit

private var xoAssociationKey: UInt8 = 0

extension UIImageView {
    @nonobjc static var imageCache = NSCache<NSString,AnyObject>()
    var imageURL: String? {
        get {
            return objc_getAssociatedObject(self, &xoAssociationKey) as! String?
        }
        set(newValue) {
            guard let urlString = newValue else {
                objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
                self.image = nil
                return
            }
            objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            if let image = UIImageView.imageCache.object(forKey: "\((urlString as NSString).hash)" as NSString) as? UIImage{
                self.image = image
                return
            }
            DispatchQueue.global().async {
                guard let url = URL(string: urlString as String) else {
                    return
                }
                do{
                    let data = try Data(contentsOf: url)
                    let image = UIImage(data: data)
                    if let fetchedImage = image {
                        DispatchQueue.main.async {
                            UIImageView.imageCache.setObject(fetchedImage, forKey: "\(urlString.hash)" as NSString)
                            if let pastImageUrl = self.imageURL, url.absoluteString == pastImageUrl {
                                let animation = CATransition()
                                animation.type = kCATransitionFade
                                animation.duration = 0.3
                                self.layer.add(animation, forKey: "transition")
                                self.image = fetchedImage
                            }
                            else{
                                self.image = nil
                            }
                        }
                    }
                }
                catch{
                    
                }
                
            }
        }
    }
}
