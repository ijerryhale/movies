//
//  ViewControllerTheaterDetail.swift
//  movies
//
//  Created by Jerry Hale on 4/2/17
//  Copyright © 2018-2020 jhale. All rights reserved
//

import UIKit

//	MARK: ViewControllerTheaterDetail
class ViewControllerTheaterDetail: UIViewController
{
	@IBOutlet weak var poster: UIImageView!
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var address: UILabel!
	@IBOutlet weak var buyTicketsBtn: UIButton!
	
	func updateView(_ enableBuyTickets: Bool)
	{
		let theater = gTheater[gCurrTheater].theater
		
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
		
		if enableBuyTickets { buyTicketsBtn.isEnabled = true }
		else { buyTicketsBtn.isEnabled = false }
	}

	@IBAction func showMapBtnPressed() { (parent?.parent as! ViewControllerBoxOffice).performSegue(withIdentifier: S2_MAP, sender: self) }

	@objc func segue_to_marquee()
	{ (parent?.parent as! ViewControllerBoxOffice).performSegue(withIdentifier: S2_MARQUEE, sender: self) }

	//	MARK: UIViewController overrides
	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("ViewControllerTheaterDetail viewWillDisappear ") }

	override func viewDidLoad()
	{
		super.viewDidLoad(); print("ViewControllerTheaterDetail viewDidLoad ")
		poster.image = UIImage(named: "ticket.png")
		poster.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(segue_to_marquee)))
	}
}
