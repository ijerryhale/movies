//
//  MarqueeViewController.swift
//  Movies
//
//  Created by Jerry Hale on 9/8/16.
//  Copyright © 2017 jhale. All rights reserved.
//

import Foundation
import UIKit

class MarqueeViewController: UIViewController
{
	@IBOutlet weak var	tableView: UITableView!
	
	@IBAction func unwindToMarquee(segue: UIStoryboardSegue) { }
	@IBAction func tapPreferencesBtn(sender: UIButton)
	{ self.performSegue(withIdentifier: S2_PREFERENCE, sender: self) }

	override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }

	//	MARK: UIViewController overrides
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.identifier == S2_PREFERENCE
		{
			let pc = (segue.destination as? PreferenceViewController)!
			pc.callingViewControler = self
		}
	}

    override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue
	{
		return CustomUnwindSegue(identifier: identifier, source: fromViewController, destination: toViewController)
    }
	
	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("MarqueeViewController viewWillDisappear ") }
	
	override func viewDidLoad()
	{	super.viewDidLoad(); print("MarqueeViewController viewDidLoad ")

		tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
		tableView.separatorColor = UIColor.clear;

		tableView.register(UINib(nibName: VALUE_MARQUEE_CELL, bundle: nil), forCellReuseIdentifier: VALUE_MARQUEE_CELL)
	}
}

// MARK: UITableView Datasource Methods
extension MarqueeViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return (gMovie.count)  }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let	cell = tableView.dequeueReusableCell(withIdentifier:VALUE_MARQUEE_CELL, for: indexPath) as! Marquee_Cell

		let m:[[String: AnyObject]] = gMovie

		cell.poster.image = getPosterImage(movie: m[indexPath.row] as AnyObject)

		return (cell)
    }
}

// MARK: UITableView Delegate Methods
extension MarqueeViewController : UITableViewDelegate
{
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return (363)
    }

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		gState = [KEY_CO_STATE : COType.cot_movie_detail, KEY_CO_INDEX : indexPath.row]

		self.performSegue(withIdentifier: S2_BOX_OFFICE,
							sender: nil)
    }
}
