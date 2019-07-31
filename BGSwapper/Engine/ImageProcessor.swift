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

let imageWidth = 513
let imageHeight = 513

class ImageProcessor {
  //  let labelNames = [
  //     "background", "aeroplane", "bicycle", "bird", "boat", "bottle", "bus",
  //     "car", "cat", "chair", "cow", "diningtable", "dog", "horse", "motorbike",
  //     "person", "pottedplant", "sheep", "sofa", "train", "tv"
  //   ]
  // MARK: - Image Classification
  
  public var delegate: ImageProcessorDelegate?
  
  /// - Tag: MLModelSetup
  private lazy var classificationRequest: VNCoreMLRequest = {
    do {
      /*
       Use the Swift class `MobileNet` Core ML generates from the model.
       To use a different Core ML classifier model, add it to the project
       and replace `MobileNet` with that model's generated Swift class.
       */
      let model = try VNCoreMLModel(for: DeepLabV3().model)
      
      let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
        self?.processClassifications(for: request, error: error)
      })
      request.imageCropAndScaleOption = .scaleFit
      return request
    } catch {
      fatalError("Failed to load Vision ML model: \(error)")
    }
  }()
  
  func processImage(image: UIImage) {
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
  
  func processClassifications(for request: VNRequest, error: Error?) {
    guard let results = request.results else {
      print("Unable to classify image.\n\(error!.localizedDescription)")
      return
    }
    // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
    let output = results as [Any]
    
    if output.isEmpty {
      print("Nothing recognized.")
    } else {
      if let firstValueObservation = output.first as? VNCoreMLFeatureValueObservation, let multiArray = firstValueObservation.featureValue.multiArrayValue {
        print( "Result:\n \(firstValueObservation.featureValue)")
        //Update UI via delegate
        if let image = self.createImage(multiArray: multiArray) {
          self.delegate?.imageProcessingCompletion(processedImage: UIImage(cgImage: image))
        }
      }
      
    }
  }

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

  private func createImage(multiArray: MLMultiArray)-> CGImage? {
    let newMultiArray: MLMultiArray
    do {
      newMultiArray = try MLMultiArray(shape: multiArray.shape, dataType: multiArray.dataType)
    } catch {
      print("Error while creating new multi array")
      return nil
    }

    for x in 0...imageWidth {
      for y in 0...imageHeight {
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
           edgeDetected ? (newMultiArray[elementIndex] = elementValue) : (newMultiArray[elementIndex] = 0)
        } else {
          newMultiArray[elementIndex] = 0
        }
      }
    }
    print(newMultiArray)
    if let image = newMultiArray.cgImage() {
      return image
    }
    return nil
  }
}
