//
//  SceneDelegate.swift
//  BGSwapper
//
//  Created by Pradnya Nikam on 22/07/19.
//  Copyright © 2019 prad. All rights reserved.
//

import UIKit
import SwiftUI
import Vision
import CoreML

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  
//  let model = DeepLabV3()
  let viewModel = ViewModel()
  let image = #imageLiteral(resourceName: "humanAndDog")
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

    // Use a UIHostingController as window root view controller
    if let windowScene = scene as? UIWindowScene {
        let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(rootView: ContentView(data: viewModel))
        self.window = window
        window.makeKeyAndVisible()
    }
    processImage()
  }

  // MARK: - Image Classification
      
      /// - Tag: MLModelSetup
      lazy var classificationRequest: VNCoreMLRequest = {
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
  
  func processImage() {
    viewModel.mainImage = image
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
                if let image = multiArray.cgImage() {
                  viewModel.overlayImage = UIImage(cgImage: image)
                  print(image)
                }
              }
              
          }
      }
  
  
  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }

  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }


}

