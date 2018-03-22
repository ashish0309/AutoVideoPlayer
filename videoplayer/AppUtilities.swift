//
//  AppUtilities.swift
//  AutoPlayVideo
//
//  Created by Ashish Singh on 7/21/17.
//  Copyright © 2017 Ashish. All rights reserved.
//

import UIKit
import Foundation

class AppUtilities: NSObject {
    class func sizeOfString (string: String,
                             constrainedToWidth width: Double,
                             forFont font: UIFont) -> CGSize {
        return NSString(string: string).boundingRect(with: CGSize(width: width,
                                                                  height: Double.greatestFiniteMagnitude),
                                                             options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                             attributes: [NSAttributedStringKey.font: font],
                                                             context: nil).size
    }
}
