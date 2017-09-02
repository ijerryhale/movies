//
//  BoxOfficeViewController.swift
//  Movies
//
//  Created by Jerry Hale on 10/2/16.
//  Copyright © 2017 jhale. All rights reserved.
//

//		let alert = UIAlertController(title: "Notification!",
//									  message:"\(message)",
//									  preferredStyle: UIAlertControllerStyle.alert)
//		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//		self.present(alert, animated: true, completion: nil)


//		let containerController: ContainerController = childViewControllers.flatMap({ $0 as? ContainerController }).first!
//		let movieDetailViewController: MovieDetailViewController? = containerController.childViewControllers.flatMap({ $0 as? MovieDetailViewController }).first
//		let mdv = MovieDetailViewController?.view as! MovieDetailView

import UIKit

private let theaterOffset = 0

//	always a valid Contained
//	Object Type and Contained Object
//	Index, default to Index of zero
//	on Movies or Theaters button click
class ContainerController: UIViewController
{
	func trailerSegueUnwind()
	{
		//	pop the TrailerController and push the MovieDetailViewController
		let tc: TrailerController = self.childViewControllers[0] as! TrailerController
		tc.performSegue(withIdentifier: S2_CONTAINER_UNWIND, sender: tc)
		self.performSegue(withIdentifier: S2_MOVIE_DETAIL, sender: self)
		
		let mdc: MovieDetailViewController? = self.childViewControllers.flatMap({ $0 as? MovieDetailViewController }).first

		mdc?.updateView()
	}

	func trailerSegueWind()
	{
		//	pop the MovieDetailViewController and push the TrailerController
		let mdc: MovieDetailViewController? = self.childViewControllers.flatMap({ $0 as? MovieDetailViewController }).first
		
		mdc?.performSegue(withIdentifier: S2_CONTAINER_UNWIND, sender: mdc)
		self.performSegue(withIdentifier: S2_MOVIE_TRAILER, sender: self)
	}

	func updateMovieDetailView()
	{
		var mdc: MovieDetailViewController? = self.childViewControllers[0] as? MovieDetailViewController
		
		if mdc == nil
		{
			let tdc: TheaterDetailController? = self.childViewControllers[0] as? TheaterDetailController
		
			if tdc == nil
			{
				let tc: TrailerController? = self.childViewControllers[0] as? TrailerController
				
				tc?.performSegue(withIdentifier: S2_CONTAINER_UNWIND, sender: tc)
			}
			else
			{
				tdc?.performSegue(withIdentifier: S2_CONTAINER_UNWIND, sender: tdc)
			}
			
			self.performSegue(withIdentifier: S2_MOVIE_DETAIL, sender: self)
			mdc = self.childViewControllers[0] as? MovieDetailViewController
		}

		mdc?.updateView()
	}

	func updateTheaterDetailView()
	{
		var tdc: TheaterDetailController? = self.childViewControllers[0] as? TheaterDetailController

		if tdc == nil
		{
			let mdc: MovieDetailViewController? = self.childViewControllers[0] as? MovieDetailViewController
		
			if mdc == nil
			{
				let tc: TrailerController? = self.childViewControllers[0] as? TrailerController
				
				tc?.performSegue(withIdentifier: S2_CONTAINER_UNWIND, sender: tc)
			}
			else
			{
				mdc?.performSegue(withIdentifier: S2_CONTAINER_UNWIND, sender: mdc)
			}
			
			self.performSegue(withIdentifier: S2_THEATER_DETAIL, sender: self)
			tdc = self.childViewControllers[0] as? TheaterDetailController
		}
		
		tdc?.updateView()
	}

	@IBAction func unwindToContainer(segue: UIStoryboardSegue)
	{
		let source = self.childViewControllers[0]
        source.willMove(toParentViewController: nil)
        source.view.removeFromSuperview()
        source.removeFromParentViewController()
	}

	// MARK: UIViewController overrides
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		//	print(segue.identifier)
			func transistion(dest : UIViewController)
			{
				self.addChildViewController(dest)
				let destView : UIView = dest.view
				
				destView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
				destView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
				self.view.addSubview(destView)
				
				dest.didMove(toParentViewController: self)
			}

		if segue.identifier == S2_MOVIE_DETAIL
		{
			transistion(dest: segue.destination as! MovieDetailViewController)
			
			(segue.destination as! MovieDetailViewController).updateView()
		}
		else if segue.identifier == S2_THEATER_DETAIL
		{ transistion(dest: segue.destination as! TheaterDetailController) }
		else { transistion(dest: segue.destination as! TrailerController) }
	}
	
	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("ContainerController viewWillDisappear") }

	override func viewDidLoad()
	{ super.viewDidLoad(); print("ContainerController viewDidLoad")

		if gState[KEY_CO_STATE] as! COType == .cot_theater_detail
		{
			self.performSegue(withIdentifier: S2_THEATER_DETAIL, sender: self)
		}
		else { self.performSegue(withIdentifier: S2_MOVIE_DETAIL, sender: self) }
	}
}


class BoxOfficeViewController: UIViewController
{
	@IBOutlet weak var	tableView: UITableView!
    @IBOutlet weak var	showdate: UILabel!
	
	@IBOutlet weak var	prefsbtn: UIButton!

	let _l0_dict = [KEY_CAN_EXPAND : false, KEY_IS_EXPANDED : true, KEY_IS_VISIBLE : true,
					KEY_CELL_IDENTIFIER : VALUE_L0_CELL, KEY_ADDITIONAL_ROWS : 0 ] as [String : Any]

	let _l1_dict = [KEY_CAN_EXPAND : true, KEY_IS_EXPANDED : false, KEY_IS_VISIBLE : true,
					KEY_CELL_IDENTIFIER : VALUE_L1_CELL, KEY_ADDITIONAL_ROWS : 0 ] as [String : Any]

	let _l2_dict = [KEY_CAN_EXPAND : false, KEY_IS_EXPANDED : false, KEY_IS_VISIBLE : false,
					KEY_CELL_IDENTIFIER : VALUE_L2_CELL, KEY_ADDITIONAL_ROWS : 0 ] as [String : Any]

	var singleRowSelect = true
	var rowDictionary = [[String : Any]]()

	@IBAction func tapAllTheatersBtn(sender: UIButton)
	{
		gState[KEY_CO_STATE] = COType.cot_theater_detail
		gState[KEY_CO_INDEX] = 0

		all_theaters()

		tableView.reloadData()
		self.tableView.scrollToRow(at: [0, 0], at: .top, animated: true)

		(childViewControllers.first as! ContainerController).updateTheaterDetailView()
	}

	@IBAction func tapAllMoviesBtn(sender: UIButton)
	{
		gState[KEY_CO_STATE] = COType.cot_movie_detail
		gState[KEY_CO_INDEX] = 0
		
		all_movies()

		tableView.reloadData()
		self.tableView.scrollToRow(at: [0, 0], at: .top, animated: true)

		(childViewControllers.first as! ContainerController).updateMovieDetailView()
	}
	
	@IBAction func tapPreferencesBtn(sender: UIButton)
	{ self.performSegue(withIdentifier: S2_PREFERENCE, sender: self) }

	@IBAction func unwindToBoxOffice(segue: UIStoryboardSegue) { /*print("unwindToBoxOffice") */ }

	private func all_theaters()
	{
		rowDictionary.removeAll()

		var startRow = 0
		var rowNum = -1
		
		for j in 0...gTheater.count - 1
		{
			startRow = rowNum + 1
			rowNum += 1

			var additionalRows = 0
			var l0_dict = _l0_dict

			/* l0_dict["rowNum"] = rowNum for dbug */
			l0_dict[KEY_ID] = gTheater[j][KEY_ID]
			l0_dict[KEY_NAME] = gTheater[j][KEY_NAME]

			var nowShowing = gTheater[j][KEY_NOW_SHOWING] as! [[String : AnyObject]]

			//	sort the Movies by Movie Rating, Movie Title
			nowShowing.sort {
			
				let lhsrating = $0[KEY_RATING]! as! String
				let rhsrating = $1[KEY_RATING]! as! String
				
			   if lhsrating != rhsrating
			   { return lhsrating < rhsrating }
				else { return ($0[KEY_TITLE]! as! String) < ($1[KEY_TITLE]! as! String) }
			}

			for ns in nowShowing
			{
				rowNum += 1

				let tms_id = ns[KEY_TMS_ID] as! String

				var l1_dict = _l1_dict

				l1_dict[KEY_TITLE] = ns[KEY_TITLE] as! String
				l1_dict[KEY_RATING] = ns[KEY_RATING] as! String
				l1_dict[KEY_TMS_ID] = tms_id
				
				let alltimes = ns[KEY_ALL_TIMES] as! NSArray

				additionalRows += alltimes.count + 1

				/*	l1_dict["rowNum"] = rowNum for dbug */
				l1_dict[KEY_ADDITIONAL_ROWS] = alltimes.count
				l1_dict[KEY_ID] = gTheater[j][KEY_ID]
				
				rowDictionary.append(l1_dict)
				
				for time in alltimes
				{
					rowNum += 1
					
					var l2_dict = _l2_dict
					
					/* l2_dict["rowNum"] = rowNum for dbug */
					l2_dict[KEY_TIME] = (time as! [String : AnyObject])[KEY_TIME] as! String
					l2_dict[KEY_TMS_ID] = tms_id
					l2_dict[KEY_ID] = gTheater[j][KEY_ID]
					rowDictionary.append(l2_dict)
				}
			}

			l0_dict[KEY_ADDITIONAL_ROWS] = additionalRows
			rowDictionary.insert(l0_dict, at: startRow)
		}
	}

	//	containerController.childViewControllers.flatMap({ $0 as? MovieDetailViewController }).first
	private func all_movies()
	{
		rowDictionary.removeAll()

		var startRow = 0
		var rowNum = -1
		
		//	loop thru all Movies
		for i in 0...gMovie.count - 1
		{
			startRow = rowNum + 1
			rowNum += 1

			var additionalRows = 0
			var l0_dict = _l0_dict

			//	add Movie title and tms_id to dictionary
			let	this_tms_id = gMovie[i][KEY_TMS_ID] as! String
			
			l0_dict[KEY_TMS_ID] = gMovie[i][KEY_TMS_ID]
			l0_dict[KEY_TITLE] = gMovie[i][KEY_TITLE]
			l0_dict[KEY_RATING] = gMovie[i][KEY_RATING]
			/* l0_dict["rowNum"] = rowNum for dbug */

			for j in 0...gTheater.count - 1
			{
				for ns in gTheater[j][KEY_NOW_SHOWING] as! [AnyObject]	//	loop thru nowShowing for this theater
				{
					if this_tms_id == ns[KEY_TMS_ID] as! String
					{
						rowNum += 1

						var l1_dict = _l1_dict

						l1_dict[KEY_NAME] = gTheater[j][KEY_NAME]
						l1_dict[KEY_TMS_ID] = this_tms_id
						l1_dict[KEY_ID] = gTheater[j][KEY_ID]
						
						let alltimes = ns[KEY_ALL_TIMES] as! NSArray

						additionalRows += alltimes.count + 1

						/*	l1_dict["rowNum"] = rowNum for dbug */
						l1_dict[KEY_ADDITIONAL_ROWS] = alltimes.count

						rowDictionary.append(l1_dict)
						
						for time in alltimes
						{
							rowNum += 1
							
							var l2_dict = _l2_dict
							
							/* l2_dict["rowNum"] = rowNum for dbug */
							l2_dict[KEY_TIME] = (time as! [String : AnyObject])[KEY_TIME] as! String
							l2_dict[KEY_TMS_ID] = this_tms_id
							l2_dict[KEY_ID] = gTheater[j][KEY_ID]
							rowDictionary.append(l2_dict)
						}
						
						break
					}
				}
			}

			l0_dict[KEY_ADDITIONAL_ROWS] = additionalRows
			rowDictionary.insert(l0_dict, at: startRow)
		}
	}

	func disablePrefsBtn() { prefsbtn.isEnabled = false }
	func enablePrefsBtn() { prefsbtn.isEnabled = true }


	//	MARK: UIViewController overrides
    override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue
	{
		return CustomUnwindSegue(identifier: identifier, source: fromViewController, destination: toViewController)
    }

	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		//	print(segue.identifier)
		if segue.identifier == S2_PREFERENCE
		{
			let pc = (segue.destination as? PreferenceViewController)!
			pc.callingViewControler = self
		}
	}

	//	func canRotate() -> Void { }
	
	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("BoxOfficeViewController viewWillDisappear ")
		
		if (isMovingFromParentViewController)
		{
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
	}

	override func viewWillAppear(_ animated: Bool)
	{ super.viewWillAppear(animated); print("BoxOfficeViewController viewWillAppear ")
	
		let movie = gMovie[gState[KEY_CO_INDEX] as! Int]
		
		if gState[KEY_CO_STATE] as! COType == .cot_movie_detail
		{
			for i in 0...rowDictionary.count - 1
			{
				if rowDictionary[i][KEY_CELL_IDENTIFIER] as! String == VALUE_L0_CELL
				{
					if rowDictionary[i][KEY_TMS_ID] as! String == movie[KEY_TMS_ID] as! String
					{
						//	print(movie[KEY_TITLE])
						DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100))
						{
							self.tableView.scrollToRow(at: [0, i], at: .middle, animated: false)
						}
						break
					}
				}
			}
		}
	}
	
	override func viewDidLoad()
	{ super.viewDidLoad(); print("BoxOfficeViewController viewDidLoad ")
	
		switch gDayOffset
		{
			case 0:
				showdate.text = "Today"
			case 1:
				showdate.text = "Tommorrow"
			default:
				let day = Calendar.current.date(byAdding: .day, value: gDayOffset + DAY_OFFSET, to: Date())
				let _df = DateFormatter()
				_df.dateFormat = "EEE, MMM dd"
				_df.locale = Locale(identifier: "en_US")

				showdate.text = _df.string(from: day!)
		}
		
		tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
		tableView.separatorColor = UIColor.clear;

        tableView.register(UINib(nibName: VALUE_L0_CELL_MOVIE, bundle: nil), forCellReuseIdentifier: VALUE_L0_CELL_MOVIE)
        tableView.register(UINib(nibName: VALUE_L0_CELL_THEATER, bundle: nil), forCellReuseIdentifier: VALUE_L0_CELL_THEATER)
		
        tableView.register(UINib(nibName: VALUE_L1_CELL_MOVIE, bundle: nil), forCellReuseIdentifier: VALUE_L1_CELL_MOVIE)
        tableView.register(UINib(nibName: VALUE_L1_CELL_THEATER, bundle: nil), forCellReuseIdentifier: VALUE_L1_CELL_THEATER)

		tableView.register(UINib(nibName: VALUE_L2_CELL, bundle: nil), forCellReuseIdentifier: VALUE_L2_CELL)
		
		tableView.contentInset = UIEdgeInsetsMake(2, 0, 0, 0);
	
		//	MV006798690000
		if gState[KEY_CO_STATE] as! COType == .cot_theater_detail { all_theaters() }
		else { all_movies() }
	
		tableView.reloadData()
	}
}

// MARK: UITableView Datasource Methods
extension BoxOfficeViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return rowDictionary.count  }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let rowDict = rowDictionary[indexPath.row] as AnyObject
		var cellID = rowDict[KEY_CELL_IDENTIFIER] as! String

		if cellID == VALUE_L0_CELL
		{
			if gState[KEY_CO_STATE] as! COType == .cot_theater_detail { cellID += "_theater" }
			else {  cellID += "_movie" }
		}
		else if cellID == VALUE_L1_CELL
		{
			if gState[KEY_CO_STATE] as! COType == .cot_movie_detail { cellID += "_theater" }
			else {  cellID += "_movie" }
		}
		
		let	cell = tableView.dequeueReusableCell(withIdentifier:cellID, for: indexPath)

		if gState[KEY_CO_STATE] as! COType == .cot_movie_detail
		{
			if rowDict[KEY_CELL_IDENTIFIER] as! String == VALUE_L0_CELL
			{
				(cell as! L0_Cell_movie).title?.text = (rowDict[KEY_TITLE] as! String)
				
				var rating = ""

				switch rowDict[KEY_RATING] as! String
				{
					case "PG-13", "R", "NC17", "PG", "G":
						rating = rowDict[KEY_RATING] as! String
					default:
						rating = ""
				}
			
				(cell as! L0_Cell_movie).rating.text = rating
			}
			else if rowDict[KEY_CELL_IDENTIFIER] as! String == VALUE_L1_CELL
			{
				(cell as! L1_Cell_theater).name?.text = (rowDict[KEY_NAME] as! String)
			}
			else
			{
				(cell as! L2_Cell).time?.text = (rowDict[KEY_TIME] as! String)
			}
		}
		else if gState[KEY_CO_STATE] as! COType == .cot_theater_detail
		{
			if rowDict[KEY_CELL_IDENTIFIER] as! String == VALUE_L0_CELL
			{
				(cell as! L0_Cell_theater).name?.text = (rowDict[KEY_NAME] as! String)
			}
			else if rowDict[KEY_CELL_IDENTIFIER] as! String == VALUE_L1_CELL
			{
				(cell as! L1_Cell_movie).title?.text = (rowDict[KEY_TITLE] as! String)

				var rating = ""

				switch rowDict[KEY_RATING] as! String
				{
					case "PG-13", "R", "NC17", "PG", "G":
						rating = rowDict[KEY_RATING] as! String
					default:
						rating = ""
				}
			
				(cell as! L1_Cell_movie).rating.text = rating
			}
			else
			{
				(cell as! L2_Cell).time?.text = (rowDict[KEY_TIME] as! String)
			}
		}

		if rowDict[KEY_IS_VISIBLE] as! Bool == true { cell.isHidden = false }
		else { cell.isHidden = true }

		return cell
    }
}

// MARK: UITableView Delegate Methods
extension BoxOfficeViewController : UITableViewDelegate
{
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		if rowDictionary[indexPath.row][KEY_IS_VISIBLE] as! Bool == false
		{
			return 0
		}

		switch rowDictionary[indexPath.row][KEY_CELL_IDENTIFIER] as! String
		{
			case VALUE_L0_CELL:
				return 30.0

			case VALUE_L1_CELL:
				return 20.0

			default:
				return 14.0
		}
    }


	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		//	if TrailerController is current embed
		//	just ignore clicks on the UITableView
		if (childViewControllers[0].childViewControllers[0] is TrailerController) { return }
		
		var rowDict = rowDictionary[indexPath.row] as [String:Any]

		if singleRowSelect == true
		&& rowDict[KEY_CELL_IDENTIFIER] as! String == VALUE_L1_CELL
		{
			var index = 0
			for var rd in rowDictionary
			{
				if rd[KEY_CELL_IDENTIFIER] as! String == VALUE_L1_CELL
				{
					if rd[KEY_IS_EXPANDED] as! Bool == true
					{
						rd[KEY_IS_EXPANDED] = false
					}
				}
				else if rd["additionalRows"] as! Int == 0
				{
					if rd["isVisible"] as! Bool == true
					{
						rd["isVisible"] = false
					}
				}

				rowDictionary[index] = rd

				index += 1
			}
		}

		if rowDict[KEY_CAN_EXPAND] as! Bool == true
		{
            var shouldExpandAndShowSubRows = false
			
            if rowDict[KEY_IS_EXPANDED] as! Bool == false
			{
                shouldExpandAndShowSubRows = true
            }

            rowDict[KEY_IS_EXPANDED] = shouldExpandAndShowSubRows
			
			for i in (indexPath.row + 1)...(indexPath.row + (rowDict[KEY_ADDITIONAL_ROWS] as! Int))
			{
				var d = rowDictionary[i] as [String:Any]

				d[KEY_IS_VISIBLE] = shouldExpandAndShowSubRows
				
				rowDictionary[i] = d
           }
		}

		switch gState[KEY_CO_STATE] as! COType
		{
			case .cot_movie_detail:
				//	if we are showing Movie detail
				//	and click is on L0 row show
				//	Movie detail - if click is on
				//	L1 or L2 row show Theater detail
				
				if rowDict[KEY_CELL_IDENTIFIER] as! String == VALUE_L0_CELL
				{
					let index = gMovie.index{ $0[KEY_TMS_ID] as! String == rowDict[KEY_TMS_ID] as! String }
					gState[KEY_CO_INDEX] = index

					//	print("cot_theater_detail LO_CELL")
					(childViewControllers[0] as! ContainerController).updateMovieDetailView()
					
				}
				else if rowDict[KEY_CELL_IDENTIFIER] as! String == VALUE_L1_CELL
				|| rowDict[KEY_CELL_IDENTIFIER] as! String == VALUE_L2_CELL
				{
					let index = gTheater.index{ $0[KEY_ID] as! String == rowDict[KEY_ID] as! String }
					gState[KEY_CO_INDEX] = index

					(childViewControllers[0] as! ContainerController).updateTheaterDetailView()
				}
			case .cot_theater_detail:
				//	do opposite for Theater detail
				//	and click is on L0 row show
				//	Theater detail - if click is on
				//	L1 or L2 row show Movie detail

				if rowDict[KEY_CELL_IDENTIFIER] as! String == VALUE_L0_CELL
				{
					//	print("cot_theater_detail LO_CELL")
					let index = gTheater.index{ $0[KEY_ID] as! String == rowDict[KEY_ID] as! String }
					gState[KEY_CO_INDEX] = index

					(childViewControllers[0] as! ContainerController).updateTheaterDetailView()
				}
				else if rowDict[KEY_CELL_IDENTIFIER] as! String == VALUE_L1_CELL
				|| rowDict[KEY_CELL_IDENTIFIER] as! String == VALUE_L2_CELL
				{
					let index = gMovie.index{ $0[KEY_TMS_ID] as! String == rowDict[KEY_TMS_ID] as! String }
					gState[KEY_CO_INDEX] = index

					(childViewControllers[0] as! ContainerController).updateMovieDetailView()

					//	print("cot_theater_detail L1_CELL")
				}
			default:
				print("unexpected COType in didSelectRowAt")
		}

		rowDictionary[indexPath.row] = rowDict

		tableView.reloadSections(NSIndexSet(index: indexPath.section) as IndexSet, with: UITableViewRowAnimation.fade)
    }
}
