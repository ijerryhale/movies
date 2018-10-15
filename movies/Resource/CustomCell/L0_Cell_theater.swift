//
//  L0_Cell_theater.swift
//  movies
//
//  Created by Jerry Hale on 3/21/18.
//  Copyright © 2018 jhale. All rights reserved.
//

import UIKit

class L0_Cell_theater: L0_Cell
{
	var name = UILabel()
	var distance = UILabel()
	var indicator = UIActivityIndicatorView(style: .gray)
	
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override init(reuseIdentifier: String?)
    { super.init(reuseIdentifier: reuseIdentifier)

		let red = CGFloat((0x333333 & 0xFF0000) >> 16) / 255.0
		let green = CGFloat((0x333333 & 0x00FF00) >> 8) / 255.0
		let blue = CGFloat(0x333333 & 0x00FF) / 255.0

		//	indicator.hidesWhenStopped = false
		//	indicator.startAnimating()
		indicator.translatesAutoresizingMaskIntoConstraints = false
		
		contentView.addSubview(indicator)
		
		indicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		indicator.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant:-24).isActive = true

		name.font = UIFont(name: "Arial", size: 16)
		name.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
		
		name.translatesAutoresizingMaskIntoConstraints = false
		name.textAlignment = .left
		name.lineBreakMode = .byTruncatingMiddle

        contentView.addSubview(name)

		name.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant:28).isActive = true
		name.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.68).isActive = true
		name.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

		name.isUserInteractionEnabled = true
		name.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(L0_Cell.tapExpandCollapse(_:))))

		distance.font = UIFont(name: "Arial", size: 14)
		distance.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)

		distance.translatesAutoresizingMaskIntoConstraints = false
		distance.textAlignment = .left

        contentView.addSubview(distance)
		
		distance.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		distance.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant:-8).isActive = true
	
		distance.isUserInteractionEnabled = true
		distance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(L0_Cell.tapExpandCollapse(_:))))
	}
}
