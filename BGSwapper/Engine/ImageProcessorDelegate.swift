//
//  ImageProcessorDelegate.swift
//  BGSwapper
//
//  Created by Pradnya Nikam on 29/07/19.
//  Copyright © 2019 prad. All rights reserved.
//

import Foundation
import UIKit

protocol ImageProcessorDelegate {
  func imageProcessingCompletion(processedImageWithEdges: UIImage, processedImageWithClearBackground: UIImage)
}
