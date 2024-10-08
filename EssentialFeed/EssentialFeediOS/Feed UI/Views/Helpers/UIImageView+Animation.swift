//
//  UIImageView+Animation.swift
//  EssentialFeediOS
//
//  Created by Afsal on 03/07/2024.
//

import UIKit

extension UIImageView {
  func setImageAnimated(_ newImage: UIImage?) {
    image = newImage
    
    guard newImage != nil else { return }
    alpha = 0
    UIView.animate(withDuration: 0.25) {
      self.alpha = 1
    }
  }
}

