//
//  L0_Cell_movie.swift
//  movies
//
//  Created by Jerry Hale on 3/20/18.
//  Copyright © 2018 jhale. All rights reserved.
//

import UIKit

class L0_Cell_movie: L0_Cell
{
	var title = UILabel()
	var rating = UILabel()

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override init(reuseIdentifier: String?)
    { super.init(reuseIdentifier: reuseIdentifier)

		let marginGuide = contentView.layoutMarginsGuide
		let red = CGFloat((0x333333 & 0xFF0000) >> 16) / 255.0
		let green = CGFloat((0x333333 & 0x00FF00) >> 8) / 255.0
		let blue = CGFloat(0x333333 & 0x00FF) / 255.0

		title.font = UIFont(name: "Arial", size: 16)
		title.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)

		title.translatesAutoresizingMaskIntoConstraints = false
		title.textAlignment = .left
		title.lineBreakMode = .byTruncatingMiddle

        contentView.addSubview(title)

		title.topAnchor.constraint(equalTo: marginGuide.topAnchor, constant:6).isActive = true
		title.leftAnchor.constraint(equalTo: marginGuide.leftAnchor, constant:10).isActive = true
		title.rightAnchor.constraint(equalTo: marginGuide.rightAnchor, constant:-20).isActive = true

		title.isUserInteractionEnabled = true
		title.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(L0_Cell.tapExpandCollapse(_:))))

		rating.font = UIFont(name: "Arial", size: 14)
		rating.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)

		rating.translatesAutoresizingMaskIntoConstraints = false
		rating.textAlignment = .left

        contentView.addSubview(rating)

		rating.topAnchor.constraint(equalTo: marginGuide.topAnchor, constant:8).isActive = true
		rating.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant:-8).isActive = true
		rating.isUserInteractionEnabled = true
		
		rating.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(L0_Cell.tapExpandCollapse(_:))))
    }
}
