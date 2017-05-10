/*
	Copyright (C) 2016 Quentin Mathe
 
	Date:  August 2016
	License:  MIT
 */

import UIKit
import DropDownMenuKit

class ViewController: UIViewController, DropDownMenuDelegate {

	var titleView: DropDownTitleView!
	@IBOutlet var navigationBarMenu: DropDownMenu!
	@IBOutlet var toolbarMenu: DropDownMenu!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let title = prepareNavigationBarMenuTitleView()

		prepareNavigationBarMenu(title)
		prepareToolbarMenu()
		updateMenuContentOffsets()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		navigationBarMenu.container = view
		toolbarMenu.container = view
	}

	func prepareNavigationBarMenuTitleView() -> String {
		// Both title label and image view are fixed horizontally inside title
		// view, UIKit is responsible to center title view in the navigation bar.
		// We want to ensure the space between title and image remains constant, 
		// even when title view is moved to remain centered (but never resized).
		titleView = DropDownTitleView(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
		titleView.addTarget(self,
		            action: #selector(ViewController.willToggleNavigationBarMenu(_:)),
		          for: .touchUpInside)
		titleView.addTarget(self,
		                    action: #selector(ViewController.didToggleNavigationBarMenu(_:)),
		          for: .valueChanged)
		titleView.titleLabel.textColor = UIColor.black
		titleView.title = "Large"

		navigationItem.titleView = titleView
		
		return titleView.title!
	}
	
	func prepareNavigationBarMenu(_ currentChoice: String) {
		navigationBarMenu = DropDownMenu(frame: view.bounds)
		navigationBarMenu.delegate = self

        let texts = ["Large.0", "Small.0", "Large.1", "Small.1", "Large.2", "Small.2", "Large.3", "Small.3", "Large.4", "Small.4", "Large.5", "Small.5", "Large.6", "Small.6", "Large.7", "Small.7", "Large.8", "Small.8", "Large.9", "Small.9"]
        let cells: [DropDownMenuCell] = texts.map {
            let cell = DropDownMenuCell()

            cell.textLabel!.text = $0
            cell.menuAction = #selector(ViewController.choose(_:))
            cell.menuTarget = self
            if currentChoice == $0 {
                cell.accessoryType = .checkmark
            }

            return cell
        }

        navigationBarMenu.menuCells = cells
		navigationBarMenu.selectMenuCell(cells[1])
		
		// If we set the container to the controller view, the value must be set
		// on the hidden content offset (not the visible one)
		navigationBarMenu.visibleContentInsetTop = navigationController!.navigationBar.frame.size.height + statusBarHeight()
        navigationBarMenu.visibleContentInsetBottom = navigationController!.toolbar.frame.size.height

		// For a simple gray overlay in background
		navigationBarMenu.backgroundView = UIView(frame: navigationBarMenu.bounds)
		navigationBarMenu.backgroundView!.backgroundColor = UIColor.black
		navigationBarMenu.backgroundAlpha = 0.7
	}

	func prepareToolbarMenu() {
		toolbarMenu = DropDownMenu(frame: view.bounds)
		toolbarMenu.delegate = self
		
		let selectCell = DropDownMenuCell()
		
		selectCell.textLabel!.text = "Select"
		selectCell.imageView!.image = UIImage(named: "Ionicons-ios-checkmark-outline")
		selectCell.showsCheckmark = false
		selectCell.menuAction = #selector(ViewController.select as (ViewController) -> () -> ())
		selectCell.menuTarget = self
		
		let sortKeys = ["Name", "Date", "Size"]
		let sortCell = DropDownMenuCell()
		let sortSwitcher = UISegmentedControl(items: sortKeys)

		sortSwitcher.selectedSegmentIndex = sortKeys.index(of: "Name")!
		sortSwitcher.addTarget(self, action: #selector(ViewController.sort(_:)), for: .valueChanged)

		sortCell.customView = sortSwitcher
		sortCell.textLabel!.text = "Sort"
		sortCell.imageView!.image = UIImage(named: "Ionicons-ios-search")
		sortCell.showsCheckmark = false

		toolbarMenu.menuCells = [selectCell, sortCell]
		toolbarMenu.direction = .up

        toolbarMenu.visibleContentInsetTop = navigationController!.navigationBar.frame.size.height + statusBarHeight()
        toolbarMenu.visibleContentInsetBottom = navigationController!.toolbar.frame.size.height

		// For a simple gray overlay in background
		toolbarMenu.backgroundView = UIView(frame: toolbarMenu.bounds)
		toolbarMenu.backgroundView!.backgroundColor = UIColor.black
		toolbarMenu.backgroundAlpha = 0.7
	}

	func updateMenuContentOffsets() {
		navigationBarMenu.visibleContentInsetTop = navigationController!.navigationBar.frame.size.height + statusBarHeight()
		toolbarMenu.visibleContentInsetBottom = navigationController!.toolbar.frame.size.height
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		coordinator.animate(alongsideTransition: { (context) in
			// If we put this only in -viewDidLayoutSubviews, menu animation is 
			// messed up when selecting an item
			self.updateMenuContentOffsets()
		}, completion: nil)
	}

	@IBAction func choose(_ sender: AnyObject) {
		titleView.title = (sender as! DropDownMenuCell).textLabel!.text
	}

	@IBAction func select() {
		print("Sent select action")
	}

	@IBAction func sort(_ sender: AnyObject) {
		print("Sent sort action")
	}

	@IBAction func showToolbarMenu() {
		if titleView.isUp {
			titleView.toggleMenu()
		}
		toolbarMenu.show()
	}

	@IBAction func willToggleNavigationBarMenu(_ sender: DropDownTitleView) {
		toolbarMenu.hide()

		if sender.isUp {
			navigationBarMenu.hide()
		}
		else {
			navigationBarMenu.show()
		}
	}

	@IBAction func didToggleNavigationBarMenu(_ sender: DropDownTitleView) {
		print("Sent did toggle navigation bar menu action")
	}

	func didTapInDropDownMenuBackground(_ menu: DropDownMenu) {
		if menu == navigationBarMenu {
			titleView.toggleMenu()
		}
		else {
			menu.hide()
		}
	}
}

func statusBarHeight() -> CGFloat {
    let statusBarSize = UIApplication.shared.statusBarFrame.size
    return min(statusBarSize.width, statusBarSize.height)
}
