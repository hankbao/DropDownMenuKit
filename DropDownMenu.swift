/**
	Copyright (C) 2015 Quentin Mathe
 
	Date:  May 2015
	License:  MIT
 */

import UIKit

@objc public protocol DropDownMenuDelegate {
	func didTapInDropDownMenuBackground(_ menu: DropDownMenu)
}

public enum DropDownMenuRevealDirection {
	case up
	case down
}

open class DropDownMenu : UIView, UIGestureRecognizerDelegate {

	open weak var delegate: DropDownMenuDelegate?
	open var container: UIView! {
		didSet {
			removeFromSuperview()
			container.addSubview(self)
		}
	}
	// The content view fills the entire container, so we can use it to fade 
	// the background view in and out.
	//
	// By default, it contains the menu view, but other subviews can be added to 
	// it and laid out by overriding -layoutSubviews.
	open let contentView: UIView
	// This hidden offset can be used to customize the position of the menu at
	// the end of the hiding animation.
	//
	// If the container doesn't extend under the toolbar and navigation bar,
	// this is useful to ensure the hiding animation continues until the menu is
	// positioned outside of the screen, rather than stopping the animation when 
	// the menu is covered by the toolbar or navigation bar.
	open var hiddenContentOffset = CGFloat(0)
	// This visible offset can be used to customize the position of the menu 
	// at the end of the showing animation.
	//
	// If the container extends under the toolbar and navigation bar, this is 
	// useful to ensure the menu won't be covered by the toolbar or navigation 
	// bar once the showing animation is done.
	open var visibleContentInsetTop = CGFloat(0) {
		didSet {
            setNeedsLayout()
		}
	}
    open var visibleContentInsetBottom = CGFloat(0) {
        didSet {
            setNeedsLayout()
        }
    }
	open var direction = DropDownMenuRevealDirection.down
	open let menuView: UIView
    open var menuContentSize: CGSize

	// The background view to be faded out with the background alpha, when the 
	// menu slides over it
	open var backgroundView: UIView? {
		didSet {
			oldValue?.removeFromSuperview()
			backgroundView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			if let backgroundView = backgroundView {
				insertSubview(backgroundView, belowSubview: contentView)
			}
		}
	}
	open var backgroundAlpha = CGFloat(1)
	
	// MARK: - Initialization
	
    public init(frame: CGRect, menuView: UIView) {
		contentView = UIView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
		contentView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
		
		self.menuView = menuView
		menuView.autoresizingMask = .flexibleWidth

        var size = frame.size
        size.height = menuView.bounds.height
        menuContentSize = size

		contentView.addSubview(menuView)

		super.init(frame: frame)
		
		let gesture = UITapGestureRecognizer(target: self, action: #selector(DropDownMenu.tap(_:)))
		gesture.delegate = self
		addGestureRecognizer(gesture)

		autoresizingMask = [.flexibleWidth, .flexibleHeight]
		isHidden = true

		addSubview(contentView)
	}

	required public init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Layout
	
	open override func layoutSubviews() {
		super.layoutSubviews()

        backgroundView?.frame.origin.y = visibleContentInsetTop
        if direction == .down {
            contentView.frame.origin.y = visibleContentInsetTop
        }
        else {
            contentView.frame.origin.y = container.bounds.height - contentView.frame.height - visibleContentInsetBottom
        }

        let visibleHeight = container.bounds.height - visibleContentInsetTop - visibleContentInsetBottom

        backgroundView?.frame.size.height = visibleHeight
		menuView.frame.size.height = min(menuContentSize.height, visibleHeight)
		contentView.frame.size.height = menuView.frame.size.height
	}

	// MARK: - Actions
	
	@IBAction open func tap(_ sender: AnyObject) {
		delegate?.didTapInDropDownMenuBackground(self)
	}
	
	// If we declare a protocol method private, it is not called anymore.
	open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		precondition(gestureRecognizer.view == self)

		guard let touchedView = touch.view else {
			return true
		}
		return !touchedView.isDescendant(of: menuView)
	}
	
	@IBAction open func show() {
		precondition(container != nil, "DropDownMenu.container must be set in [presentingController viewDidAppear:]")
		
		if !isHidden {
			return
		}

		backgroundView?.alpha = 0
		if direction == .down {
			contentView.frame.origin.y = -(contentView.frame.height + hiddenContentOffset)
		}
		else {
			contentView.frame.origin.y = container.frame.height + hiddenContentOffset
		}
		isHidden = false

		UIView.animate(withDuration: 0.4,
		                    delay: 0,
		   usingSpringWithDamping: 1,
		    initialSpringVelocity: 1,
		                  options: UIViewAnimationOptions(),
		               animations: {
			if self.direction == .down {
				self.contentView.frame.origin.y = self.visibleContentInsetTop
			}
			else {
				self.contentView.frame.origin.y = self.container.frame.height - self.contentView.frame.height  - self.visibleContentInsetBottom
			}
			self.backgroundView?.alpha = self.backgroundAlpha
		},
		               completion: nil)
	}
	
	@IBAction open func hide() {
	
		if isHidden {
			return
		}

		if direction == .down {
			contentView.frame.origin.y = visibleContentInsetTop
		}
		else {
			contentView.frame.origin.y = container.frame.height - contentView.frame.height - visibleContentInsetTop
		}
		isHidden = false
		
		UIView.animate(withDuration: 0.4,
		                    delay: 0,
		   usingSpringWithDamping: 1,
		    initialSpringVelocity: 1,
		                  options: UIViewAnimationOptions(),
		               animations: {
			if self.direction == .down {
				self.contentView.frame.origin.y = -(self.contentView.frame.height + self.hiddenContentOffset)
			}
			else {
				self.contentView.frame.origin.y = self.container.frame.height + self.hiddenContentOffset
			}
			self.backgroundView?.alpha = 0
		},
				       completion: { (Bool) in
			self.isHidden = true
		})
	}
}
