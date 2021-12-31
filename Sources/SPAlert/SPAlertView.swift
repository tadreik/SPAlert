// The MIT License (MIT)
// Copyright © 2020 Ivan Vorobei (hello@ivanvorobei.by)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

/**
 Main view. Can be customisable if need.
 
 For change duration, check method `present` and pass duration and other specific property if need customise.
 
 Here available set window on which shoud be present.
 If you have some windows, you shoud configure it. Check property `presentWindow`.
 
 For disable dismiss by tap, check property `.dismissByTap`.
 
 Recomended call `SPAlert` and choose style func.
 */
@MainActor
final public class SPAlertView: UIView {
    
    // MARK: - Views
    
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.numberOfLines = 0
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        style.alignment = .center
        label.attributedText = NSAttributedString(string: "", attributes: [.paragraphStyle: style])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public var iconView: UIView!
    
    weak public var presentWindow: UIWindow? = UIApplication.shared.windows.first
    
    // MARK: - Properties
    
    public var dismissByTap: Bool = true
    
    public var completion: (() -> Void)? = nil
    
    // MARK: - Initializers
    
    public init(title: String, preset: SPAlertIconPreset) {
        super.init(frame: CGRect.zero)
        titleLabel.text = title
        iconView = preset.createView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Configure
    
    private func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        preservesSuperviewLayoutMargins = true
        insetsLayoutMarginsFromSafeArea = true
        layer.masksToBounds = true
        layer.cornerRadius = 10
        backgroundColor = .white
        addSubview(iconView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 24),
            
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 34),
            iconView.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        if dismissByTap {
            let tapGesterRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))
            addGestureRecognizer(tapGesterRecognizer)
        }
    }
    
    // MARK: - Present
    
    fileprivate var presentDismissDuration: TimeInterval = 0.2
    fileprivate var presentDismissScale: CGFloat = 0.8
    
    fileprivate var defaultContentColor: UIColor {
        let darkColor = UIColor(red: 127 / 255, green: 127 / 255, blue: 129 / 255, alpha: 1)
        let lightColor = UIColor(red: 88 / 255, green: 87 / 255, blue: 88 / 255, alpha: 1)
        guard let interfaceStyle = self.window?.traitCollection.userInterfaceStyle else {
            return lightColor
        }
        switch interfaceStyle {
        case .light: return lightColor
        case .dark: return darkColor
        case .unspecified: return lightColor
        @unknown default: return lightColor
        }
    }
    
    public func present(duration: TimeInterval = 3, completion: (() -> Void)? = nil) {
        guard let window = self.presentWindow else { return }
        window.addSubview(self)
        
        // Prepare for present
        
        self.completion = completion
        
        let contentСolor = defaultContentColor
        titleLabel.textColor = contentСolor
        iconView.tintColor = contentСolor
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 40),
            leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 20),
            trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -20)
        ])
        
        
        alpha = 0
        
        transform = transform.scaledBy(x: self.presentDismissScale, y: self.presentDismissScale)
        
        // Present
        
        UIView.animate(withDuration: presentDismissDuration, animations: {
            self.alpha = 1
            self.transform = CGAffineTransform.identity
        }, completion: { finished in
            if let iconView = self.iconView as? SPAlertIconAnimatable {
                iconView.animate()
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                self.dismiss()
            }
        })
    }
    
    @objc public func dismiss() {
        UIView.animate(withDuration: presentDismissDuration, animations: {
            self.alpha = 0
            self.transform = self.transform.scaledBy(x: self.presentDismissScale, y: self.presentDismissScale)
        }, completion: { [weak self] finished in
            self?.removeFromSuperview()
            self?.completion?()
        })
    }
    
}
