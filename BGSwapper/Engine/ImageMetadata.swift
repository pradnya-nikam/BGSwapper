//
//  ImageMetadata.swift
//  BGSwapper
//
//  Created by Pradnya Nikam on 05/08/19.
//  Copyright © 2019 prad. All rights reserved.
//

import Foundation
import CoreImage
import CoreML
import CoreGraphics
import UIKit

struct ImageMetaData {
  var originalImage: UIImage
  var processedImageMultiArray: MLMultiArray?
  var processedImageWithEdges: CGImage?
  var processedImageMultiArrayWithEdges: MLMultiArray?
  var backgroundPixels = [(Int, Int)]()
}
