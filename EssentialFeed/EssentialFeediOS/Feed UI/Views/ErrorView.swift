//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Afsal on 06/07/2024.
//

import UIKit

public final class ErrorView: UIView {
  @IBOutlet public weak var button: UIButton!

  public var message: String? {
    didSet {
      guard let message = message else { return hide() }
      showMessage(message)
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    alpha = 0
    button.setTitle(nil, for: .normal)
  }
  
  public var isVisible: Bool {
    return alpha > 0
  }
  
  private func showMessage(_ message: String) {
    alpha = 1
    button.setTitle(message, for: .normal)
  }
  
  @IBAction func hideMessage() {
    message = .none
  }
  
  private func hide() {
    UIView.animate(withDuration: 0.25, animations: { [weak self] in
      self?.alpha = 0
    }, completion: { [weak button] completed in
      if completed {
        button?.setTitle(nil, for: .normal)
      }
    })
  }
}
