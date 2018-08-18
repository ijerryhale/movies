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
	@IBOutlet weak var version: UILabel!
	@IBOutlet weak var build: UILabel!
	
	@IBAction func clearCache(_ sender: Any) { DataAccess().clearCachedData() }
	
	@IBAction func tapDoneBtn(_ sender: Any) { dismiss(animated: true, completion: nil) }

	override func viewDidLoad()
	{ super.viewDidLoad(); print("ViewControllerSettings viewDidLoad")

        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build: String = Bundle.main.object(forInfoDictionaryKey: "BUILD_TAG") as! String

		self.version.text = version
		self.build.text = build
	
	}
	
//	@IBAction func useCurrentLocChangedValue(_ sender: UISwitch)
//	{
//		UserDefault.setUsingCurrentLocation(sender.isOn)
//
//		if sender.isOn == true { postalCode.isEnabled = false }
//		else { postalCode.isEnabled = true }
//	}
}

