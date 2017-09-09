//
//  TheaterDetailController.swift
//  Movies
//
//  Created by Jerry Hale on 4/2/17.
//  Copyright © 2017 jhale. All rights reserved.
//

import UIKit

//	MARK: TheaterDetailController
class TheaterDetailController: UIViewController
{
	@IBOutlet weak var poster: UIImageView!
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var address: UILabel!

	func updateView()
	{
		let index = gState[KEY_CO_INDEX] as! Int
		let theater = gTheater[index].theater
		
		name.text = theater[KEY_NAME] as? String
		
		let aa = theater[KEY_ADDRESS]
		var addressString = aa?[KEY_STREET] as! String

		addressString += "\n"
		addressString += aa?[KEY_CITY] as! String
		addressString += ", "
		addressString += aa?[KEY_STATE] as! String
		addressString += " "
		addressString += aa?[KEY_POSTAL_CODE] as! String
		
		let phone = theater[KEY_TEL] as! String
		
		if !phone.isEmpty { addressString += "\n\n" + phone }

		address.text = addressString
	}

	@IBAction func showMapBtnPressed() { (parent?.parent as! BoxOfficeViewController).performSegue(withIdentifier: S2_MAP, sender: self) }

	func segue_to_marquee()
	{ (parent?.parent as! BoxOfficeViewController).performSegue(withIdentifier: S2_MARQUEE, sender: self) }

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
