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
	var indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
	
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override init(reuseIdentifier: String?)
    { super.init(reuseIdentifier: reuseIdentifier)

		let marginGuide = contentView.layoutMarginsGuide
		
		//	indicator.hidesWhenStopped = false
		//	indicator.startAnimating()
		
		indicator.translatesAutoresizingMaskIntoConstraints = false
		
		contentView.addSubview(indicator)
		
		indicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		indicator.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant:-24).isActive = true

		name.font = UIFont(name: "HelveticaNeue", size: 16)
		name.textColor = UIColor.black
		name.translatesAutoresizingMaskIntoConstraints = false
		name.textAlignment = .left
		
        contentView.addSubview(name)

		name.heightAnchor.constraint(equalTo: marginGuide.heightAnchor).isActive = true
		
		name.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
		name.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true

		name.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant:24).isActive = true
		
		distance.font = UIFont(name: "HelveticaNeue", size: 12)
		distance.textColor = UIColor.black
		distance.translatesAutoresizingMaskIntoConstraints = false
		distance.textAlignment = .left

        contentView.addSubview(distance)
		
		distance.heightAnchor.constraint(equalTo: marginGuide.heightAnchor).isActive = true
		
		distance.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
		distance.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
		
		distance.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant:-8).isActive = true
		

		//	indicator.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant:-8).isActive = true
    }
}
