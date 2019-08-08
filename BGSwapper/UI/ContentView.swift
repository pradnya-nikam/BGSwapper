//
//  ContentView.swift
//  BGSwapper
//
//  Created by Pradnya Nikam on 22/07/19.
//  Copyright © 2019 prad. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  @ObjectBinding var data: ViewModel
    
  private var overlayImage: UIImage {
        self.data.overlayImage!
    }
  
    var body: some View {
      ScrollView{
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
      ContentView(data: ViewModel())
    }
}
#endif
