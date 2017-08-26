//
//  SelectableCell.swift
//  Movies
//
//  Created by Jerry Hale on 4/11/17.
//  Copyright © 2017 jhale. All rights reserved.
//

import UIKit

enum SelectableCellState {
	case unchecked
	case checked
	case halfchecked
}

class SelectableCell: UITableViewCell
{
	var itemText : UILabel!
	var selectableCellState : SelectableCellState
	
	@IBOutlet weak var tapTransitionsOverlay: UIView!

	required init?(coder aDecoder: NSCoder)
	{
		selectableCellState = .unchecked
	
		super.init(coder: aDecoder)
	}

	override func layoutSubviews()
	{
		super.layoutSubviews()
		
		setupInterface()
	}
	
	func setupInterface()
	{
		clipsToBounds = true
		
		tapTransitionsOverlay.backgroundColor = UIColor(red: 0.15, green: 0.54, blue: 0.93, alpha: 1.0)
	}

	func toggleCheck() -> SelectableCellState
	{
		if selectableCellState == .checked
		{
			selectableCellState = .unchecked
			styleDisabled()
		}
		else
		{
			selectableCellState = .checked
			styleEnabled()
		}
		
		return selectableCellState
	}

	func check()
	{
		selectableCellState = .checked
		styleEnabled()
	}

	func uncheck()
	{
		selectableCellState = .unchecked
		styleDisabled()
	}

	func styleEnabled()
	{
		self.backgroundView?.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.93, alpha: 1.0)
	}

	func styleDisabled()
	{
		self.backgroundView?.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
	}

	func tapTransistion()
	{
		print("tapTransistion")
		tapTransitionsOverlay.alpha = 1.0;

		UIView.beginAnimations("tapTransition", context: nil)
		UIView.setAnimationDuration(2.0)
		tapTransitionsOverlay.alpha = 0.0
		UIView.commitAnimations()
		
	}
}
