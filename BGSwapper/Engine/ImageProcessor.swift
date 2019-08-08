//
//  ImageProcessor.swift
//  BGSwapper
//
//  Created by Pradnya Nikam on 29/07/19.
//  Copyright © 2019 prad. All rights reserved.
//

import Foundation
import Vision
import CoreML
import UIKit

//This is the size required by the deep learning algorithm.
let imageWidth = 513
let imageHeight = 513

class ImageProcessor {
  //  let labelNames = [
  //     "background", "aeroplane", "bicycle", "bird", "boat", "bottle", "bus",
  //     "car", "cat", "chair", "cow", "diningtable", "dog", "horse", "motorbike",
  //     "person", "pottedplant", "sheep", "sofa", "train", "tv"
  //   ]
  
  // MARK: - Step 1: Image Classification
  
  public var delegate: ImageProcessorDelegate?
  var imageMetadata: ImageMetaData?
  
  /// - Tag: MLModelSetup
  private lazy var classificationRequest: VNCoreMLRequest = {
    do {
      let model = try VNCoreMLModel(for: DeepLabV3().model)
      
      let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
        self?.processMLResults(fromRequest: request, error: error)
      })
      request.imageCropAndScaleOption = .scaleFit
      return request
    } catch {
      fatalError("Failed to load Vision ML model: \(error)")
    }
  }()
  
  func performProcessing(onImage image: UIImage) {
    self.imageMetadata = ImageMetaData(originalImage: image)
    guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from image.") }
    let handler = VNImageRequestHandler(ciImage: ciImage, orientation: CGImagePropertyOrientation.up)
    do {
      try handler.perform([self.classificationRequest])
    } catch {
      /*
       This handler catches general image processing errors. The `classificationRequest`'s
       completion handler `processClassifications(_:error:)` catches errors specific
       to processing that request.
       */
      print("Failed to perform classification.\n\(error.localizedDescription)")
    }
  }
  
  func processMLResults(fromRequest request: VNRequest, error: Error?) {
    guard let results = request.results else {
      print("Unable to classify image.\n\(error!.localizedDescription)")
      return
    }
    let output = results as [Any]
    
    if output.isEmpty {
      print("Nothing recognized.")
    } else {
      if let firstValueObservation = output.first as? VNCoreMLFeatureValueObservation, let multiArray = firstValueObservation.featureValue.multiArrayValue {
        print( "Result:\n \(firstValueObservation.featureValue)")
        imageMLProcessingCompleted(multiArray: multiArray)
      }
    }
  }
  
  private func imageMLProcessingCompleted(multiArray: MLMultiArray) {
    if let processedImageWithEdges = self.createImageWithEdges(multiArray: multiArray), let processedImageWithClearBackground = clearImageBackgroundPixels() {
      //Update UI via delegate
      self.imageMetadata?.processedImageWithEdges = processedImageWithEdges
      self.imageMetadata?.processedImageWithClearBackground = processedImageWithClearBackground
      self.delegate?.imageProcessingCompletion(processedImageWithEdges: processedImageWithEdges, processedImageWithClearBackground: processedImageWithClearBackground)
    }
  }
  
  // MARK: - Step 2: Edge Detection using ML Model output.
  
  private func createImageWithEdges(multiArray: MLMultiArray)-> UIImage? {
    let multiArrayWithEdges: MLMultiArray
    do {
      multiArrayWithEdges = try MLMultiArray(shape: multiArray.shape, dataType: multiArray.dataType)
    } catch {
      print("Error while creating new multi array")
      return nil
    }
    //Co-ordinates of all pixels that are part of the 'background'
    var backgroundPixels = [(Int, Int)]()
    for y in 0..<imageHeight {
      for x in 0..<imageWidth
      {
        let elementIndex =  [x,y].map({NSNumber(value: $0)})
        let elementValue = multiArray[elementIndex]
        if(elementValue.intValue > 0) {
          let edgeIndices = getEdgesOf(elementValue: elementValue.intValue, x: x,y: y, maxX: imageWidth, maxY: imageHeight)
          var edgeDetected = false
          for edgeIndex in edgeIndices {
            let edgeIndexIndexInNSNumber = edgeIndex.map({NSNumber(value: $0)})
            //check if an edge element is not equal to current element -
            if multiArray[edgeIndexIndexInNSNumber].intValue != elementValue.intValue {
              edgeDetected = true
              break;
            }
          }
          edgeDetected ? (multiArrayWithEdges[elementIndex] = elementValue) : (multiArrayWithEdges[elementIndex] = 0)
        } else {
          backgroundPixels.append((x,y))
          multiArrayWithEdges[elementIndex] = 0
        }
      }
    }
    imageMetadata?.backgroundPixels = backgroundPixels
    if let processedImageWithEdges = multiArrayWithEdges.cgImage() {
      return UIImage(cgImage: processedImageWithEdges)
    }
    return nil
  }
  
  /**
   Returns array of  'edges' of a given element in a 2D matrix
   */
  private func getEdgesOf(elementValue: Int, x: Int, y: Int, maxX: Int, maxY: Int)-> [[Int]] {
    var arrayOfEdges = [[Int]]()
    (x > 0 && y > 0 )       ? arrayOfEdges.append([x-1, y-1]) : ()
    (y > 0)                 ? arrayOfEdges.append([x  , y-1]) : ()
    (x < maxX && y > 0)     ? arrayOfEdges.append([x+1, y-1]) : ()
    (x < maxX)              ? arrayOfEdges.append([x+1, y])   : ()
    (x < maxX && y < maxY)  ? arrayOfEdges.append([x+1, y+1]) : ()
    (y < maxY)              ? arrayOfEdges.append([x  , y+1]) : ()
    (x > 0 && y < maxY)     ? arrayOfEdges.append([x-1, y+1]) : ()
    (x < maxX)              ? arrayOfEdges.append([x-1, y])   : ()
    return arrayOfEdges
  }
  
  // MARK: - Step 3: Edit original image to remove background using the list of background pixels created in the last step
  func clearImageBackgroundPixels() -> UIImage? {
    guard let originalImage = self.imageMetadata?.originalImage, let backgroundPixels = self.imageMetadata?.backgroundPixels else {
      return nil
    }
    let image = originalImage.resized(toSize:
      CGSize(width: imageWidth, height: imageHeight))
    let rgba = RGBAImage(image: image)!
    backgroundPixels.forEach { (y,x) in
      let index = y * rgba.width + x
      var pixel = rgba.pixels[index]
      pixel.alpha = 1
      rgba.pixels[index] = pixel
    }
    let newImage = rgba.toUIImage()
    return newImage
  }
}
