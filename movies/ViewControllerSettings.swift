//
//  ViewControllerSettings.swift
//  movies
//
//  Created by Jerry Hale on 10/7/17.
//  Copyright © 2018 jhale. All rights reserved.
//

import CoreLocation
import UIKit

class ViewControllerSettings: UIViewController
{
	@IBOutlet weak var useCurrentLoc: UISwitch!
	@IBOutlet weak var postalCode: UITextField!

	@IBOutlet weak var showdateBtn: UIButton!
	
	@IBOutlet weak var version: UILabel!
	@IBOutlet weak var build: UILabel!

	private func get_show_date() -> String
	{
		let dayoffset = UserDefault.getDayOffset()

		switch dayoffset
		{
			case 0:
			return ("Today ")
			case 1:
			return ("Tommorrow ")
			default:
				let today = Date()
				let day = Calendar.current.date(byAdding: .day, value: dayoffset, to: today)

				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "EEE, MMM dd"
				dateFormatter.locale = Locale(identifier: "en_US")
			return (dateFormatter.string(from: day!) + " ")
		}
	}

	func notif_showdate(notification: Notification)
	{ print("notif_showdate")
		self.showdateBtn.setTitle(get_show_date(), for: .normal)
	}
	
	@objc func done(_ : UIBarButtonItem) { dismiss(animated: false, completion:nil); }
	
	override func viewDidLoad()
	{ super.viewDidLoad(); print("ViewControllerSettings viewDidLoad")

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(ViewControllerSettings.done(_:)))

//		if UserDefault.usingCurrentLocation()
//		{
//			useCurrentLoc.isOn = true
//			postalCode.isEnabled = false
//		}
//		else { useCurrentLoc.isOn = false }

		postalCode.text = UserDefault.getPostalCode()
		
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build: String = Bundle.main.object(forInfoDictionaryKey: "BUILD_TAG") as! String

		self.version.text = version
		self.build.text = build

		self.showdateBtn.setTitle(get_show_date(), for: .normal)
		
		NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:NOTIF_DEFAULT_DAY_OFFSET_CHANGED),
               object:nil, queue:nil, using:notif_showdate)
	}
	
	@IBAction func postalCodeChangedValue(_ sender: UITextField)
	{
		UserDefault.setPostalCode(sender.text!)
	}
	
//	@IBAction func useCurrentLocChangedValue(_ sender: UISwitch)
//	{
//		UserDefault.setUsingCurrentLocation(sender.isOn)
//
//		if sender.isOn == true { postalCode.isEnabled = false }
//		else { postalCode.isEnabled = true }
//	}
	
	@IBAction func resetBtnChangedValue(_ sender: UIButton)
	{
		postalCode.isEnabled = true
		
		//	UserDefault.setUsingCurrentLocation(false)
		UserDefault.setLastUpdate(Date())
		UserDefault.setDayOffset(0)
		UserDefault.setPostalCode("92315")
		
		self.view.setNeedsDisplay()
	}
	
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

