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
      ZStack{
        //Main Image
        if(self.data.mainImage != nil) {
          Image(uiImage: self.data.mainImage!)
          .resizable()
          .aspectRatio(contentMode: .fit)
        } else {
          Text("No main Image set")
        }

        //Overlay Image
        if(self.data.overlayImage != nil) {
          Image(uiImage: self.data.overlayImage!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .opacity(0.8)
        } else {
            Text("Processing...")
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
