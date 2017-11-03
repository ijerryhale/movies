//
//  Marquee_Cell.swift
//  movies
//
//  Created by Jerry Hale on 9/1/17.
//  Copyright © 2017 jhale. All rights reserved.
//

import UIKit

class Marquee_Cell: UITableViewCell
{
	@IBOutlet weak var poster: UIImageView!
	@IBOutlet weak var indicator: UIActivityIndicatorView!

	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
	}
}
