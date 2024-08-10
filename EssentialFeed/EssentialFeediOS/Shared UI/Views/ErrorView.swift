//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Afsal on 06/07/2024.
//

import UIKit

public final class ErrorView: UIButton {
  var onHide: (() -> Void)?
  
  public var message: String? {
    didSet {
      guard let message = message else { return hideMessageAnimated() }
      showMessage(message)
    }
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }
  
  private var titleAttributes: AttributeContainer {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = NSTextAlignment.center

    return AttributeContainer([
      .paragraphStyle: paragraphStyle,
      .font:  UIFont.preferredFont(forTextStyle: .body)
    ])
  }
  
  private func configure() {
    var configuration = Configuration.plain()
    configuration.titlePadding = 0
    configuration.baseForegroundColor = .white
    configuration.background.backgroundColor = .errorBackgroundColor
    configuration.background.cornerRadius = 0
    self.configuration = configuration

    addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    hideMessage()
  }
  
  public var isVisible: Bool {
    return alpha > 0
  }
  
  private func showMessage(_ message: String) {
    configuration?.attributedTitle = AttributedString(message, attributes: titleAttributes)
    configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
    alpha = 1
  }
  
  @objc func didTapButton() {
    message = .none
  }
  
  private func hideMessageAnimated() {
    UIView.animate(withDuration: 0.25, animations: { [weak self] in
      self?.alpha = 0
    }, completion: { [weak self] completed in
      if completed {
        self?.hideMessage()
        self?.removeFromSuperview()
      }
    })
  }
  
  private func hideMessage() {
    configuration?.attributedTitle = nil
    configuration?.contentInsets = .zero
    onHide?()
  }
}

extension UIColor {
  static var errorBackgroundColor: UIColor {
    return UIColor(red: 0.99951404330000004, green: 0.41759261489999999, blue: 0.4154433012, alpha: 1)
  }
}
