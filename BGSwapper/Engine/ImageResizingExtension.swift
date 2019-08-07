//
//  ImageResizingExtension.swift
//  BGSwapper
//
//  Created by Pradnya Nikam on 07/08/19.
//  Copyright © 2019 prad. All rights reserved.
//

import Foundation
import UIKit
import func AVFoundation.AVMakeRect

extension UIImage {
  func resized(toSize size: CGSize)-> UIImage {
      let rect = AVMakeRect(aspectRatio: self.size, insideRect: CGRect(origin: .zero, size: size))
      let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
              self.draw(in: rect)
          }
    }
}
