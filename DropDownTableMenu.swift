//
//  DropDownTableMenu.swift
//  DropDownMenuKit
//
//  Created by Hank Bao on 2017/5/17.
//  Copyright (c) 2017 Quentin Mathé. All rights reserved.
//

import UIKit

open class DropDownTableMenu : DropDownMenu, UITableViewDataSource, UITableViewDelegate {

    open var menuTableView: UITableView { return menuView as! UITableView }
    open var menuCells = [DropDownMenuCell]() {
        didSet {
            menuTableView.reloadData()
            setNeedsLayout()
        }
    }
    open var hidesMenuOnSelect = false

    // MARK: - Initialization

    public init(frame: CGRect) {
        let tableView = UITableView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        tableView.alwaysBounceVertical = true

        super.init(frame: frame, menuView: tableView)

        tableView.dataSource = self
        tableView.delegate = self
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override open var menuContentSize: CGSize {
        get { return menuTableView.contentSize }
        set {}
    }

    // MARK: - Selection

    /// Selects the cell briefly and sends the cell menu action.
    ///
    /// If DropDownMenuCell.showsCheckmark is true, then the cell is marked with
    /// a checkmark and all other cells are unchecked.
    open func selectMenuCell(_ cell: DropDownMenuCell) {
        guard let index = menuCells.index(of: cell) else {
            fatalError("The menu cell to select must belong to the menu")
        }
        let indexPath = IndexPath(row: index, section: 0)

        menuTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        tableView(menuTableView, didSelectRowAt: indexPath)
    }

    // MARK: - Table View
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuCells.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return menuCells[indexPath.row]
    }
    
    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return menuCells[indexPath.row].menuAction != nil
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = menuCells[indexPath.row]
        
        for cell in menuCells {
            cell.accessoryType = .none
        }
        cell.accessoryType = cell.showsCheckmark ? .checkmark : .none
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if cell.menuAction == nil {
            return
        }
        
        UIApplication.shared.sendAction(cell.menuAction, to: cell.menuTarget, from: cell, for: nil)
        
        if hidesMenuOnSelect {
            hide()
        }
    }
}
