//
//  ImageMetadata.swift
//  BGSwapper
//
//  Created by Pradnya Nikam on 05/08/19.
//  Copyright © 2019 prad. All rights reserved.
//

import Foundation
import CoreML
import UIKit

struct ImageMetaData {
  var originalImage: UIImage
  
  //Output of the coreML model.
  //A 2D array which represents the classification of every pixel of the image. (0=background)
  var processedImageMultiArray: MLMultiArray?
  
  //Image containing only the edges of the subject in the original images
  var processedImageWithEdges: UIImage?
  
  //Co-ordinates of all pixels that are part of the 'background'
  var backgroundPixels = [(Int, Int)]()
  
  //Desired result:
  //Image with transparentBackground
  var processedImageWithClearBackground: UIImage?
}
