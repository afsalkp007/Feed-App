//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Afsal on 28/06/2024.
//

import UIKit

extension UIRefreshControl {
  func simulatePullToRefresh() {
    simulate(event: .valueChanged)
  }
}
