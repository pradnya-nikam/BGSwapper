//
//  ViewModel.swift
//  BGSwapper
//
//  Created by Pradnya Nikam on 23/07/19.
//  Copyright © 2019 prad. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final class ViewModel: BindableObject {
  
  let willChange = PassthroughSubject<Void, Never>()
  var overlayImage: UIImage? {
          willSet {
              willChange.send()
          }
  }
  
}
