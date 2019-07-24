//
//  ContentView.swift
//  BGSwapper
//
//  Created by Pradnya Nikam on 22/07/19.
//  Copyright © 2019 prad. All rights reserved.
//

import SwiftUI

struct ContentView: View {
//  @EnvironmentObject var data: ViewModel
    
//  private var overlayImage: UIImage {
//        self.data.overlayImage!
//    }
  
    var body: some View {
      VStack{
        Image("pradImage")
          .resizable()
          .aspectRatio(contentMode: .fill)
//        if(self.data.overlayImage != nil) {
//          Image(uiImage: overlayImage)
//        }
      }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
