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

		title.font = UIFont(name: "HelveticaNeue", size: 16)
		
		let red = CGFloat((0x333333 & 0xFF0000) >> 16) / 255.0
		let green = CGFloat((0x333333 & 0x00FF00) >> 8) / 255.0
		let blue = CGFloat(0x333333 & 0x00FF) / 255.0

		title.textColor = UIColor(red: red,
								green: green,
								blue: blue,
								alpha: 1.0)

		title.translatesAutoresizingMaskIntoConstraints = false
		title.textAlignment = .left

		title.isUserInteractionEnabled = true
		title.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(L0_Cell.tapExpandCollapse(_:))))

        contentView.addSubview(title)

		title.heightAnchor.constraint(equalTo: marginGuide.heightAnchor).isActive = true

		title.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
		title.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true

		title.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant:28).isActive = true

		rating.font = UIFont(name: "HelveticaNeue", size: 12)
		
		rating.textColor = UIColor(red: red,
								green: green,
								blue: blue,
								alpha: 1.0)

		rating.translatesAutoresizingMaskIntoConstraints = false
		rating.textAlignment = .left

        contentView.addSubview(rating)

		rating.heightAnchor.constraint(equalTo: marginGuide.heightAnchor).isActive = true

		rating.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
		rating.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true

		rating.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant:-8).isActive = true

		rating.isUserInteractionEnabled = true
		rating.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(L0_Cell.tapExpandCollapse(_:))))
    }
}
