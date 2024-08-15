//
//  LoadMoreCell.swift
//  EssentialFeediOS
//
//  Created by Afsal on 15/08/2024.
//

import UIKit

public class LoadMoreCell: UITableViewCell {
  
  private lazy var spinner: UIActivityIndicatorView = {
    let spinnner = UIActivityIndicatorView(style: .medium)
    contentView.addSubview(spinnner)
    
    spinnner.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      spinnner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      spinnner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      spinnner.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
      spinnner.widthAnchor.constraint(greaterThanOrEqualToConstant: 40)
    ])
    
    return spinnner
  }()
  
  private lazy var messageLabel: UILabel = {
    let label = UILabel()
    label.textColor = .tertiaryLabel
    label.font = .preferredFont(forTextStyle: .footnote)
    label.numberOfLines = 0
    label.textAlignment = .center
    label.adjustsFontForContentSizeCategory = true
    contentView.addSubview(label)
    
    label.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
      contentView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
      label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      contentView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 8)
    ])
    
    return label
  }()
  
  public var isLoading: Bool {
    get { spinner.isAnimating }
    set {
      if newValue {
        spinner.startAnimating()
      } else {
        spinner.stopAnimating()
      }
    }
  }
  
  public var message: String? {
    get { messageLabel.text }
    set { messageLabel.text = newValue }
  }
  
}
