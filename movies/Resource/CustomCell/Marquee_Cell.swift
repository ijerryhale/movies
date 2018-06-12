//
//  Marquee_Cell.swift
//  movies
//
//  Created by Jerry Hale on 9/1/17.
//  Copyright © 2018 jhale. All rights reserved.
//

//	405 x 600
//	0.675

//	373 x 552
import UIKit

class Marquee_Cell: UITableViewCell
{
	@IBOutlet weak var poster: UIImageView!
	@IBOutlet weak var indicator: UIActivityIndicatorView!
	
	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
	}
	
	override func didMoveToSuperview()
	{
		super.didMoveToSuperview()
		
		indicator.color = UIColor.black
	}
}
