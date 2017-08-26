//
//  TheaterDetailController.swift
//  Movies
//
//  Created by Jerry Hale on 4/2/17.
//  Copyright © 2017 jhale. All rights reserved.
//

import UIKit

class TheaterDetailController: UIViewController
{
	@IBOutlet weak var poster: UIImageView!
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var address: UILabel!
	@IBOutlet weak var phoneNumber: UILabel!

	func updateView()
	{
		let index = gState[KEY_CO_INDEX] as! Int
		let theater = gTheater[index]
		
		name.text = theater[KEY_NAME] as? String
		
		let aa = theater[KEY_ADDRESS]
		var a = aa?[KEY_STREET] as! String

		a += "\n"
		a += aa?[KEY_CITY] as! String
		a += ", "
		a += aa?[KEY_STATE] as! String
		a += " "
		a += aa?[KEY_POSTAL_CODE] as! String
		
		address.text = a
		phoneNumber.text = theater[KEY_TEL] as? String
	}

	func segue_to_marquee()
	{ (parent?.parent as! BoxOfficeController).performSegue(withIdentifier: S2_MARQUEE, sender: self) }

	//	MARK: UIViewController overrides
	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("TheaterDetailController viewWillDisappear ") }

	override func viewDidLoad()
	{
		super.viewDidLoad(); print("TheaterDetailController viewDidLoad ")
		poster.image = UIImage(named: "ticket.png")
		poster.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(segue_to_marquee)))
	}
}
