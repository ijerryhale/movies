//
//  ViewControllerShowDate.swift
//  movies
//
//  Created by Jerry Hale on 4/11/17.
//  Copyright © 2017 jhale. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerShowDate: UIViewController
{
	@IBOutlet weak var tableView: UITableView!
	
	//	MARK: UIViewController overrides
	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("ViewControllerShowDate viewWillDisappear ") }

	override func viewDidLoad()
	{ super.viewDidLoad(); print("ViewControllerShowDate viewDidLoad ")

		tableView.register(UINib(nibName: VALUE_SHOWDATE_CELL, bundle: nil), forCellReuseIdentifier: VALUE_SHOWDATE_CELL)
	}
}

extension ViewControllerShowDate : UITableViewDelegate
{
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		UserDefault.setDayOffset(indexPath.row)
		
		tableView.reloadData()
	}
}

extension ViewControllerShowDate : UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 7  }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        let cell = tableView.dequeueReusableCell(withIdentifier: VALUE_SHOWDATE_CELL, for: indexPath) as! ShowDate_Cell

		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEE, MMM dd"
		dateFormatter.locale = Locale(identifier: "en_US")

		let today = Date()
		let day = Calendar.current.date(byAdding: .day, value: indexPath.row, to: today)

		switch indexPath.row
		{
			case 0:
				cell.name?.text = "Today"
			case 1:
				cell.name?.text = "Tomorrow"
			default:
				cell.name?.text = dateFormatter.string(from: day!)
		}

		let dayoffset = UserDefault.getDayOffset()
		
		if indexPath.row == dayoffset { cell.checkmark.text = "\u{2713}" }
		else { cell.checkmark.text = "" }
        return cell
    }
}
