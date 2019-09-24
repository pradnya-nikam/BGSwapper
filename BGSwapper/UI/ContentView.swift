//
//  ContentView.swift
//  BGSwapper
//
//  Created by Pradnya Nikam on 22/07/19.
//  Copyright © 2019 prad. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  var data: ViewModel
  var imageProcessor: ImageProcessor
  @State private var showImagePicker: Bool = false
  @State private var image: UIImage? = nil
  
  private var overlayImage: UIImage {
    self.data.overlayImage!
  }
  
  var body: some View {
    ScrollView{
      //View 3: Button
      Button(action: {
        self.showImagePicker = true
      }) {
        Text("Upload Image")
      }
      .sheet(isPresented: $showImagePicker, onDismiss: {
        //This is only called when the image picker is manually dismissed
        self.showImagePicker = false
      }, content: {
        //View 4: Image Picker
        ImagePicker(isShown: self.$showImagePicker, uiImage: self.$image, onDismiss: {
          //Called when the image picker is programmatically dismissed
          //for example when an image is chosen
            self.showImagePicker = false
            if(self.image != nil) {
              self.imageProcessor.performProcessing(onImage: self.image!)
              self.data.mainImage = self.image
            }
          })
        })
      
      Text("Original Image")
        .bold()
      ZStack {
        //Main Image
        if(self.data.mainImage != nil) {
          Image(uiImage: self.data.mainImage!)
            .resizable()
            .scaledToFit()
            .frame(width: 513, height: 513)
          
        } else {
          Text("No main Image set")
        }
        
        //Overlay Image
        if(self.data.overlayImage != nil) {
          Image(uiImage: self.data.overlayImage!)
            .resizable()
            .scaledToFit()
            .opacity(0.7)
        } else {
          Text("Processing...")
        }
      }
      //Processed image
      if(self.data.processedImage != nil) {
        Text("Processed Image")
          .bold()
        Image(uiImage: self.data.processedImage!)
          .resizable()
          .scaledToFit()
          .frame(width: 513, height: 513)
      }
    }
  }
  
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(data: ViewModel(), imageProcessor: ImageProcessor())
  }
}
#endif
