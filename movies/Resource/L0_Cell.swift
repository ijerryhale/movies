//
//  L0_Cell.swift
//  movies
//
//  Created by Jerry Hale on 3/21/18.
//  Copyright © 2018 jhale. All rights reserved.
//

import UIKit

protocol SectionHeaderDelegate {
	func ShowSectionDetail(_ header: L0_Cell, section: Int)
    func toggleSectionIsExpanded(_ header: L0_Cell, section: Int)
}

class L0_Cell: UITableViewHeaderFooterView
{
	let disclosureButton = UIButton()

	var delegate: SectionHeaderDelegate?
    var section: Int = 0
	
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override init(reuseIdentifier: String?)
    { super.init(reuseIdentifier: reuseIdentifier)

		let red = CGFloat((0x666666 & 0xFF0000) >> 16) / 255.0
		let green = CGFloat((0x666666 & 0x00FF00) >> 8) / 255.0
		let blue = CGFloat(0x666666 & 0x00FF) / 255.0
	
		contentView.backgroundColor = UIColor(red: red,
											green: green,
											blue: blue,
											alpha: 1.0)

        let marginGuide = contentView.layoutMarginsGuide
	
        disclosureButton.setImage(UIImage(named: "carat.png"), for: UIControlState.normal)
		disclosureButton.setImage(UIImage(named: "carat-open.png"), for: UIControlState.selected)

        contentView.addSubview(disclosureButton)

        disclosureButton.translatesAutoresizingMaskIntoConstraints = false
        disclosureButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        disclosureButton.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
		disclosureButton.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true

		disclosureButton.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant:4).isActive = true
	
		disclosureButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(L0_Cell.tapExpandCollapse(_:))))

		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(L0_Cell.tapShowDetail(_:))))
	}
	
	@objc func tapShowDetail(_ gestureRecognizer: UITapGestureRecognizer)
	{
		let	cell = gestureRecognizer.view as? L0_Cell

		delegate?.ShowSectionDetail(self, section: (cell?.section)!)
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
