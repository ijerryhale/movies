//
//  L1_Cell_movie.swift
//  movies
//
//  Created by Jerry Hale on 5/25/17
//  Copyright © 2018-2020 jhale. All rights reserved
//

import UIKit

class L1_Cell_movie: UITableViewCell
{
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var rating: UILabel!
	
	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
	}
}
