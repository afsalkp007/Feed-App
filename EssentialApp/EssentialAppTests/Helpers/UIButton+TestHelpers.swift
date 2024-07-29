//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Afsal on 28/06/2024.
//

import UIKit

extension UIButton {
  func simulateTap() {
    simulate(event: .touchUpInside)
  }
}

