//
//  ShowDate_Cell.swift
//  movies
//
//  Created by Jerry Hale on 10/10/17.
//  Copyright © 2017 jhale. All rights reserved.
//

import UIKit

class ShowDate_Cell: UITableViewCell
{
	@IBOutlet weak var name: UILabel!	
	@IBOutlet weak var checkmark: UILabel!
	
	required init?(coder aDecoder: NSCoder)
	{	
		super.init(coder: aDecoder)
	}
}
