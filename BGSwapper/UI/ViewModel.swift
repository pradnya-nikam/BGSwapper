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

class ViewModel: ObservableObject {
  @Published var overlayImage: UIImage?
  @Published var mainImage: UIImage?
  @Published var processedImage: UIImage?
}
