//
//  L0_Cell.swift
//  movies
//
//  Created by Jerry Hale on 3/21/18.
//  Copyright © 2018 jhale. All rights reserved.
//

import UIKit

protocol SectionHeaderDelegate {
	func showSectionDetail(_ header: L0_Cell, section: Int)
    func toggleSectionIsExpanded(_ header: L0_Cell, section: Int)
}

class L0_Cell: UITableViewHeaderFooterView
{
	let disclosureButton = UIButton()
	let backgroundview = UIView()
	var delegate: SectionHeaderDelegate?
    var section: Int = 0
	
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override init(reuseIdentifier: String?)
    { super.init(reuseIdentifier: reuseIdentifier)

		contentView.backgroundColor = UIColor.clear
		
		backgroundview.setCornerRadius(3)
		backgroundview.backgroundColor = UIColor.themeColor(THEME_COLOR)

		contentView.addSubview(backgroundview)
	
		backgroundview.translatesAutoresizingMaskIntoConstraints = false
		backgroundview.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4).isActive = true
		backgroundview.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.98).isActive = true
		
		backgroundview.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2).isActive = true
		backgroundview.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.92).isActive = true

        disclosureButton.setImage(UIImage(named: "carat.png"), for: UIControlState.normal)
		disclosureButton.setImage(UIImage(named: "carat-open.png"), for: UIControlState.selected)

        contentView.addSubview(disclosureButton)

        disclosureButton.translatesAutoresizingMaskIntoConstraints = false
		disclosureButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		disclosureButton.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant:12).isActive = true
	
		disclosureButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(L0_Cell.tapExpandCollapse(_:))))

		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(L0_Cell.tapShowDetail(_:))))
	}
	
	@objc func tapShowDetail(_ gestureRecognizer: UITapGestureRecognizer)
	{
		let	cell = gestureRecognizer.view as? L0_Cell

		delegate?.showSectionDetail(self, section: (cell?.section)!)
    }

	@objc func tapExpandCollapse(_ gestureRecognizer: UITapGestureRecognizer)
	{
        guard let cell = gestureRecognizer.view as? UILabel else
        {
			let cell = gestureRecognizer.view as? UIButton

			delegate?.toggleSectionIsExpanded(self, section: (cell?.superview?.superview as! L0_Cell).section)

			return
        }

		delegate?.toggleSectionIsExpanded(self, section: (cell.superview?.superview as! L0_Cell).section)
    }

    func setIsExpanded(_ isExpanded: Bool) { disclosureButton.isSelected = isExpanded }
}
