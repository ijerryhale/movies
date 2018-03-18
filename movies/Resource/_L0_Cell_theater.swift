//
//  L0_Cell_theater.swift
//  movies
//
//  Created by Jerry Hale on 5/26/17.
//  Copyright © 2017 jhale. All rights reserved.
//

import UIKit

class L0_Cell_theater: UITableViewCell
{
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var distance: UILabel!
	@IBOutlet weak var indicator: UIActivityIndicatorView!

	required init?(coder aDecoder: NSCoder)
	{	
		super.init(coder: aDecoder)
	}
}
