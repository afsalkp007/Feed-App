//
//  UIRefreshControl+Refresh.swift
//  EssentialFeediOS
//
//  Created by Afsal on 06/07/2024.
//

import UIKit

extension UIRefreshControl {
  func update(_ isRefreshing: Bool) {
    isRefreshing ? beginRefreshing() : endRefreshing()
  }
}
