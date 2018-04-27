//
//  ViewControllerBoxOffice.swift
//  movies
//
//  Created by Jerry Hale on 10/2/16.
//  Copyright © 2018 jhale. All rights reserved.
//
//	3/20/18 - rewrote most of this to account
//	for using Sections in UITableView

import QuartzCore
import CoreLocation
import MapKit
import UIKit

//	set to false to disallow
//	expand/collapse of L1_Cell
let L1_CELL_CAN_EXPAND_COLLAPSE = true

//	set to true to intially
//	display all L1_Cell's
//	as expanded
let L1_CELL_INIT_EXPANDED = false

//	set to true to allow only
//	one L1_Cell to be expanded
//	at a time
let L1_CELL_SINGLE_ROW_SELECT = true


public struct Section {

    var dict = [String : Any]()
    var cellIdentifier: String
    var isExpanded: Bool
	var cell = [[String : Any]]()
	
	public init(id: String, name: String, isExpanded: Bool = false)
	{
		self.dict[KEY_ID] = id
        self.dict[KEY_NAME] = name

        self.isExpanded = isExpanded
        self.cellIdentifier = VALUE_L0_CELL_THEATER
    }

	public init(tmsid: String, title: String, rating: String, isExpanded: Bool = false)
	{
        self.dict[KEY_TMS_ID] = tmsid
        self.dict[KEY_TITLE] = title
        self.dict[KEY_RATING] = rating
		
		self.isExpanded = isExpanded
		self.cellIdentifier = VALUE_L0_CELL_MOVIE
    }
}

//	MARK: LazyDistance
class LazyDistance
{
	var theaterAddress: String
	var state = OpState.new
	var currentDist: String = ""

	init(theaterAddress: String)
	{
		self.theaterAddress = theaterAddress
	}
}

//	MARK: PendingDistanceOperations
class PendingDistanceOperations
{
	lazy var inProgress = [Int:Operation]()
	
	lazy var operationQueue: OperationQueue = {
		var queue = OperationQueue()
		queue.name = UUID().uuidString
		queue.maxConcurrentOperationCount = 1
		return queue
	}()
}
//	tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
extension UITableView
{
    //	the table section headers that are visible in the table view. (read-only)
    //	the value of this property is an array containing UITableViewHeaderFooterView objects, each representing a visible cell in the table view.
    //	derived From: [http://stackoverflow.com/a/31029960/5191100](http://stackoverflow.com/a/31029960/5191100)

	func indicesOfVisibleSections() -> Array<Int>?
    {
        //	can't just use indexPathsForVisibleRows, since it
        //	won't return index paths for empty sections.
        var visibleSectionIndex = Array<Int>()

        for i in 0..<self.numberOfSections
        {
            var headerRect: CGRect?
            // In plain style, the section headers are floating on the top,
            // so the section header is visible if any part of the section's rect is still visible.
            // In grouped style, the section headers are not floating,
            // so the section header is only visible if it's actual rect is visible.
            if (self.style == .plain) {
				headerRect = self.rect(forSection: i)
            } else {
				headerRect = self.rectForHeader(inSection: i)
            }

            if headerRect != nil
            {
                // The "visible part" of the tableView is based on the content offset and the tableView's size.
                let visiblePartOfTableView: CGRect = CGRect(
                    x: self.contentOffset.x,
                    y: self.contentOffset.y,
                    width: self.bounds.size.width,
                    height: self.bounds.size.height
                )

                if (visiblePartOfTableView.intersects(headerRect!)) { visibleSectionIndex.append(i) }
            }
        }

        return (visibleSectionIndex)
    }
}

//	MARK: ViewControllerBoxOffice
class ViewControllerBoxOffice: UIViewController
{
    @IBOutlet weak var	showdate: UILabel!
	@IBOutlet weak var	tableView: UITableView!
	
	var rowDictionary = [Section]()
	var singleRowSelect = false

	@IBAction func tapAllTheatersBtn(sender: UIButton)
	{
		gState = .theater
		gCurrMovie = 0
		gCurrTheater = 0
		
		all_theaters()
		tableView.reloadData()
		tableView.scrollToRow(at: [0, NSNotFound], at: .top, animated: false)
		
		(childViewControllers.first as! ViewControllerContainer).updateTheaterDetailView(false)
	}

	@IBAction func tapAllMoviesBtn(sender: UIButton)
	{
		gState = .movie
		gCurrMovie = 0
		gCurrTheater = 0

		all_movies()
		tableView.reloadData()
		tableView.scrollToRow(at: [0, NSNotFound], at: .top, animated: false)

		(childViewControllers.first as! ViewControllerContainer).updateMovieDetailView()
	}

	@IBAction func unwindToBoxOffice(segue: UIStoryboardSegue) { /*print("unwindToBoxOffice") */ }

    let pendingOperations = PendingDistanceOperations()

    func startOperationForDistance(distance: LazyDistance, section: Int, lat: Double, long: Double)
	{
		//	MARK: CaculateDistance Operation
		class CaculateDistance: Operation
		{
			var lat: Double = 0.0
			var long: Double = 0.0
			let lazyDistance: LazyDistance
			
			init(lazyDistance: LazyDistance, lat: Double, long: Double)
			{
				self.lat = lat
				self.long = long
				self.lazyDistance = lazyDistance
			}
			
			override func main()
			{
				if self.isCancelled { return }

				DispatchQueue.main.async(execute: {
				
				//	let theaterAddress = "555 El Rancho Drive, Sparks NV 89431"
				let location = UserLocation.shared.locationManager.location

				let c0 = CLLocation(latitude: (location?.coordinate.latitude)!,
					                    longitude: (location?.coordinate.longitude)!)
				let c1 = CLLocation(latitude: self.lat,
									longitude: self.long)

				let distanceInMeters = c0.distance(from: c1) // result is in meters

				self.lazyDistance.currentDist = String(format: "%.2f miles", distanceInMeters * 0.000621371 )
				})
				self.lazyDistance.state = .done
			}
		}
		
        if distance.state == .new
		{
			if let _ = pendingOperations.inProgress[section] { return }
			
			let calcDistance = CaculateDistance(lazyDistance: distance, lat: lat, long: long)
			
			calcDistance.completionBlock = {
				
				if calcDistance.isCancelled { return }

				DispatchQueue.main.async(execute: {
					self.pendingOperations.inProgress.removeValue(forKey: section)
					self.tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
					
					//	self.tableView.reloadRows(at: [indexPath as IndexPath], with: .none)
				})
			}
			
			pendingOperations.inProgress[section] = calcDistance
			pendingOperations.operationQueue.addOperation(calcDistance)
        }
    }
	
    func loadDistanceforOnScreenSections()
	{
        if let sectionArray = tableView.indicesOfVisibleSections()
		{
            let allPendingOperations = Set(pendingOperations.inProgress.keys)
			
            var toBeCancelled = allPendingOperations
            let visibleIndices = Set(sectionArray as [Int])
            toBeCancelled.subtract(visibleIndices)
			
            var toBeStarted = visibleIndices
            toBeStarted.subtract(allPendingOperations)
			
            for section in toBeCancelled
			{
                if let pendingDownload = pendingOperations.inProgress[section]
				{
                    pendingDownload.cancel()
                }
				
                pendingOperations.inProgress.removeValue(forKey: section)
			}

            for section in toBeStarted
			{
				let s = rowDictionary[section] as Section

				guard
					let theater = gTheater.filter({ $0.theater[KEY_ID] as? String == s.dict[KEY_ID] as? String }).first
					else { fatalError("no theater returned") }
				
				let lat = theater.theater[KEY_LAT] as! String
				let long = theater.theater[KEY_LONG] as! String

                startOperationForDistance(distance: theater.distance, section: section,
										  lat: Double(lat)!, long: Double(long)!)
            }
        }
    }
	
	private func all_theaters()
	{
		rowDictionary.removeAll()

		var rowNum = -1
		
		for j in 0...gTheater.count - 1
		{
			rowNum += 1

			var additionalRows = 0
			
			var section = Section(id: gTheater[j].theater[KEY_ID] as! String,
									name: gTheater[j].theater[KEY_NAME] as! String)

			var nowShowing = gTheater[j].theater[KEY_NOW_SHOWING] as! [[String : AnyObject]]

			//	sort the Movies by Movie Rating, Movie Title
			nowShowing.sort {

				var lhsrating = $0[KEY_RATING]! as! String
				var rhsrating = $1[KEY_RATING]! as! String
				
				if lhsrating == "" { lhsrating = "NR" }
				if rhsrating == "" { rhsrating = "NR" }

			   if lhsrating != rhsrating
			   { return lhsrating > rhsrating }
				else { return ($0[KEY_TITLE]! as! String) < ($1[KEY_TITLE]! as! String) }
			}

			for ns in nowShowing
			{
				rowNum += 1

				let tms_id = ns[KEY_TMS_ID] as! String

				var l1_dict = [KEY_CAN_EXPAND : (L1_CELL_CAN_EXPAND_COLLAPSE ? true : false),
								KEY_IS_EXPANDED : (L1_CELL_INIT_EXPANDED ? true : false),
								KEY_IS_VISIBLE : true,
								KEY_CELL_IDENTIFIER : VALUE_L1_CELL,
								KEY_ADDITIONAL_ROWS : 0 ] as [String : Any]

				l1_dict[KEY_TITLE] = ns[KEY_TITLE] as! String
				l1_dict[KEY_RATING] = ns[KEY_RATING] as! String
				l1_dict[KEY_TMS_ID] = tms_id
				
				let alltimes = ns[KEY_ALL_TIMES] as! NSArray

				additionalRows += alltimes.count + 1

				/*	l1_dict["rowNum"] = rowNum for dbug */
				l1_dict[KEY_ADDITIONAL_ROWS] = alltimes.count
				l1_dict[KEY_ID] = gTheater[j].theater[KEY_ID]
				
				section.cell.append(l1_dict)
				
				for time in alltimes
				{
					rowNum += 1
					
					var l2_dict = [KEY_CAN_EXPAND : false,
									KEY_IS_EXPANDED : false,
									KEY_IS_VISIBLE : (L1_CELL_INIT_EXPANDED ? true : false),
									KEY_CELL_IDENTIFIER : VALUE_L2_CELL,
									KEY_ADDITIONAL_ROWS : 0 ] as [String : Any]
					
					/* l2_dict["rowNum"] = rowNum for dbug */
					l2_dict[KEY_TIME] = (time as! [String : AnyObject])[KEY_TIME] as! String
					l2_dict[KEY_TMS_ID] = tms_id
					l2_dict[KEY_ID] = gTheater[j].theater[KEY_ID]
					
					section.cell.append(l2_dict)
				}
			}

			section.dict[KEY_ADDITIONAL_ROWS] = additionalRows
			rowDictionary.append(section)
		}
	}

	//	containerController.childViewControllers.flatMap({ $0 as? ViewControllerMovieDetail }).first
	private func all_movies()
	{
		rowDictionary.removeAll()

		var rowNum = -1
		
		//	loop thru all Movies
		for i in 0...gMovie.count - 1
		{
			rowNum += 1

			var additionalRows = 0

			//	add Movie title and tms_id to dictionary
			let	this_tms_id = gMovie[i].movie[KEY_TMS_ID] as! String
			
			var section = Section(tmsid: this_tms_id,
								title: gMovie[i].movie[KEY_TITLE] as! String,
								rating: gMovie[i].movie[KEY_RATING] as! String)

			for j in 0...gTheater.count - 1
			{
				for ns in gTheater[j].theater[KEY_NOW_SHOWING] as! [AnyObject]	//	loop thru nowShowing for this theater
				{
					if this_tms_id == ns[KEY_TMS_ID] as! String
					{
						rowNum += 1

						var l1_dict = [KEY_CAN_EXPAND : (L1_CELL_CAN_EXPAND_COLLAPSE ? true : false),
										KEY_IS_EXPANDED : (L1_CELL_INIT_EXPANDED ? true : false),
										KEY_IS_VISIBLE : true,
										KEY_CELL_IDENTIFIER : VALUE_L1_CELL,
										KEY_ADDITIONAL_ROWS : 0 ] as [String : Any]

						l1_dict[KEY_NAME] = gTheater[j].theater[KEY_NAME]
						l1_dict[KEY_TMS_ID] = this_tms_id
						l1_dict[KEY_ID] = gTheater[j].theater[KEY_ID]
						
						let alltimes = ns[KEY_ALL_TIMES] as! NSArray

						additionalRows += alltimes.count + 1

						/*	l1_dict["rowNum"] = rowNum for dbug */
						l1_dict[KEY_ADDITIONAL_ROWS] = alltimes.count

						section.cell.append(l1_dict)
						
						for time in alltimes
						{
							rowNum += 1
							
							var l2_dict = [KEY_CAN_EXPAND : false,
											KEY_IS_EXPANDED : false,
											KEY_IS_VISIBLE : (L1_CELL_INIT_EXPANDED ? true : false),
											KEY_CELL_IDENTIFIER : VALUE_L2_CELL,
											KEY_ADDITIONAL_ROWS : 0 ] as [String : Any]
							
							/* l2_dict["rowNum"] = rowNum for dbug */
							l2_dict[KEY_TIME] = (time as! [String : AnyObject])[KEY_TIME] as! String
							l2_dict[KEY_TMS_ID] = this_tms_id
							l2_dict[KEY_ID] = gTheater[j].theater[KEY_ID]
							
							section.cell.append(l2_dict)
						}
						
						break
					}
				}
			}

			rowDictionary.append(section)
		}
	}

	//	update Show Date
	func notif_dayoffset_changed(notification: Notification) { print("ViewControllerBoxOffice notif_dayoffset_changed"); self.showdate.text = get_show_date() }

	//	MARK: UIViewController overrides
	deinit
	{
		NotificationCenter.default.removeObserver(Notification.Name(rawValue:NOTIF_DAY_OFFSET_CHANGED))
	}

	//	func canRotate() -> Void { }
    override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue
	{
		return CustomUnwindSegue(identifier: identifier, source: fromViewController, destination: toViewController)
    }

	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		//	print(segue.identifier)
		if segue.identifier == S2_SETTINGS
		{

		}
	}
	
	override func viewWillAppear(_ animated: Bool)
	{ super.viewWillAppear(animated); print("ViewControllerBoxOffice viewWillAppear ")

		//	observe for changes to DayOffset
		NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:NOTIF_DAY_OFFSET_CHANGED),
               object:nil, queue:nil, using:notif_dayoffset_changed)
	}

	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("ViewControllerBoxOffice viewWillDisappear ")

		if (isMovingFromParentViewController)
		{
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
	}

	override func viewDidLoad()
	{ super.viewDidLoad(); print("ViewControllerBoxOffice viewDidLoad ")

		//	only called from ViewControllerMarquee

		tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        tableView.register(UINib(nibName: VALUE_L0_CELL_MOVIE, bundle: nil), forCellReuseIdentifier: VALUE_L0_CELL_MOVIE)
        tableView.register(UINib(nibName: VALUE_L0_CELL_THEATER, bundle: nil), forCellReuseIdentifier: VALUE_L0_CELL_THEATER)
        tableView.register(UINib(nibName: VALUE_L1_CELL_MOVIE, bundle: nil), forCellReuseIdentifier: VALUE_L1_CELL_MOVIE)
        tableView.register(UINib(nibName: VALUE_L1_CELL_THEATER, bundle: nil), forCellReuseIdentifier: VALUE_L1_CELL_THEATER)
		tableView.register(UINib(nibName: VALUE_L2_CELL, bundle: nil), forCellReuseIdentifier: VALUE_L2_CELL)

		//	MV006798690000
		all_movies()
	
		tableView.reloadData()
		tableView.scrollToRow(at: [gCurrMovie, NSNotFound], at: .top, animated: false)

		switch UserDefault.getDayOffset()
		{
			case 0:
				showdate.text = "Today"
			case 1:
				showdate.text = "Tommorrow"
			default:
				let day = Calendar.current.date(byAdding: .day, value: UserDefault.getDayOffset(), to: Date())
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "EEE, MMM dd"
				dateFormatter.locale = Locale(identifier: "en_US")

				showdate.text = dateFormatter.string(from: day!)
		}
	}
}

//	MARK: SectionHeaderDelegate Methods
extension ViewControllerBoxOffice: SectionHeaderDelegate
{
	func showSectionDetail(_ header: L0_Cell, section: Int)
	{
    	if (childViewControllers[0].childViewControllers[0] is ViewControllerTrailer) { return }
		
		switch gState
		{
			case .movie:
				//	if we are showing Movie detail
				//	and click is on L0 row show
				//	Movie detail

				gCurrMovie
					= gMovie.index{ $0.movie[KEY_TMS_ID] as! String == rowDictionary[section].dict[KEY_TMS_ID] as! String }!

				(childViewControllers.first as! ViewControllerContainer).updateMovieDetailView()
			case .theater:
				//	do opposite for Theater detail
				//	and click is on L0 row show
				//	Theater detail

				gCurrTheater
					= gTheater.index{ $0.theater[KEY_ID] as! String == rowDictionary[section].dict[KEY_ID] as! String }!
				
				(childViewControllers.first as! ViewControllerContainer).updateTheaterDetailView(false)
			default:
				print("unexpected COType in toggleSectionIsExpanded")
		}

    }

    func toggleSectionIsExpanded(_ header: L0_Cell, section: Int)
    {
    	if (childViewControllers[0].childViewControllers[0] is ViewControllerTrailer) { return }

        let isExpanded = !rowDictionary[section].isExpanded
		
        //	toggle collapse
 		header.setIsExpanded(isExpanded)
        rowDictionary[section].isExpanded = isExpanded
		
		switch gState
		{
			case .movie:
				//	if we are showing Movie detail
				//	and click is on L0 row show
				//	Movie detail

				gCurrMovie
					= gMovie.index{ $0.movie[KEY_TMS_ID] as! String == rowDictionary[section].dict[KEY_TMS_ID] as! String }!

				(childViewControllers.first as! ViewControllerContainer).updateMovieDetailView()
			case .theater:
				//	do opposite for Theater detail
				//	and click is on L0 row show
				//	Theater detail

				gCurrTheater
					= gTheater.index{ $0.theater[KEY_ID] as! String == rowDictionary[section].dict[KEY_ID] as! String }!

				(childViewControllers.first as! ViewControllerContainer).updateTheaterDetailView(false)
			default:
				print("unexpected COType in toggleSectionIsExpanded")
		}

        tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
}

//	MARK: UITableView Datasource Methods
extension ViewControllerBoxOffice : UITableViewDataSource
{
	func numberOfSections(in tableView: UITableView) -> Int { return (rowDictionary.count) }

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
        return rowDictionary[section].isExpanded ? rowDictionary[section].cell.count : 0
    }

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
		let rowDict = rowDictionary[section]
		let cellID = rowDict.cellIdentifier

		if cellID == VALUE_L0_CELL_MOVIE
		{
			let	movieHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: cellID)  as? L0_Cell_movie ?? L0_Cell_movie(reuseIdentifier: cellID)

			movieHeader.title.text = rowDict.dict[KEY_TITLE] as? String
			
			var rating = ""

			if (rowDict.dict[KEY_RATING] is NSNull) == false
			{
				switch rowDict.dict[KEY_RATING] as! String
				{
					case "PG-13", "R", "NC17", "PG", "G":
						rating = rowDict.dict[KEY_RATING] as! String
					default:
						rating = "NR"
				}
			}

			movieHeader.rating.text = rating

			movieHeader.setIsExpanded(rowDictionary[section].isExpanded)
			movieHeader.section = section
			movieHeader.delegate = self

			return (movieHeader)
		}
		else
		{
			let	theaterHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: cellID)  as? L0_Cell_theater ?? L0_Cell_theater(reuseIdentifier: cellID)

			theaterHeader.name.text = rowDict.dict[KEY_NAME] as? String

			guard
				let theater = gTheater.filter({ $0.theater[KEY_ID] as? String == rowDict.dict[KEY_ID] as? String }).first
				else { fatalError("no theater returned") }

				let thisDistance = theater.distance

	 			theaterHeader.distance.text = thisDistance.currentDist

				switch thisDistance.state
				{
					case .failed:
						//	print(".failed")
						theaterHeader.indicator.stopAnimating()
					case .new:
						//	print(".new")
						theaterHeader.indicator.startAnimating()

						let lat = theater.theater[KEY_LAT] as! String
						let long = theater.theater[KEY_LONG] as! String

						if (!tableView.isDragging && !tableView.isDecelerating)
						{
							self.startOperationForDistance(distance: thisDistance,
														section: section,
														lat: Double(lat)!, long: Double(long)!)
						}

					case .done:
						//	print(".done")
						theaterHeader.indicator.stopAnimating()
				}

			theaterHeader.setIsExpanded(rowDictionary[section].isExpanded)
			theaterHeader.section = section
			theaterHeader.delegate = self
			
			return (theaterHeader)
		}
    }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let rowDict = rowDictionary[indexPath.section].cell[indexPath.row]
		var cellID = rowDict[KEY_CELL_IDENTIFIER] as! String

		if cellID == VALUE_L1_CELL
		{
			if gState == .movie { cellID += "_theater" }
			else {  cellID += "_movie" }
		}

		let	cell = tableView.dequeueReusableCell(withIdentifier:cellID, for: indexPath)

		if rowDict[KEY_IS_VISIBLE] as! Bool == true { cell.isHidden = false }
		else { cell.isHidden = true }

		if gState == .movie
		{
			if cellID == VALUE_L1_CELL_THEATER
			{
				(cell as! L1_Cell_theater).name?.text = (rowDict[KEY_NAME] as! String)
			}
			else
			{
				(cell as! L2_Cell).time?.text = (rowDict[KEY_TIME] as! String)
			}
		}
		else if gState == .theater
		{
			if rowDict[KEY_CELL_IDENTIFIER] as! String == VALUE_L1_CELL
			{
				(cell as! L1_Cell_movie).title?.text = (rowDict[KEY_TITLE] as! String)

				var rating = "NR"

				if (rowDict[KEY_RATING] is NSNull) == false
				{
					switch rowDict[KEY_RATING] as! String
					{
						case "PG-13", "R", "NC17", "PG", "G":
							rating = rowDict[KEY_RATING] as! String
						default:
							rating = ""
					}
				}

				(cell as! L1_Cell_movie).rating.text = rating
			}
			else
			{
				(cell as! L2_Cell).time?.text = (rowDict[KEY_TIME] as! String)
			}
		}

		return (cell)
    }
}

//	MARK: UITableView Delegate Methods
extension ViewControllerBoxOffice : UITableViewDelegate
{
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return (42.0) }
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return (1.0) }

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		let cell: [String : Any] = rowDictionary[indexPath.section].cell[indexPath.row]

		if cell[KEY_IS_VISIBLE] as! Bool == true
		{
			switch cell[KEY_CELL_IDENTIFIER] as! String
			{
				case VALUE_L1_CELL:
					return (30.0)

				default:
					return (16.0)
			}
		}
	
		return (0)
    }

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		//	if ViewControllerTrailer is current embed
		//	just ignore clicks on the UITableView
		if (childViewControllers[0].childViewControllers[0] is ViewControllerTrailer) { return }

		var section = rowDictionary[indexPath.section]
		var rowDict = section.cell[indexPath.row]

		if rowDict[KEY_CELL_IDENTIFIER] as! String == VALUE_L1_CELL
		{
			if L1_CELL_SINGLE_ROW_SELECT == true
			{
				var index = 0
				for var rd in section.cell
				{
					if rd[KEY_CELL_IDENTIFIER] as! String == VALUE_L1_CELL
					{
						if rd[KEY_IS_EXPANDED] as! Bool == true
						{
							rd[KEY_IS_EXPANDED] = false
						}
					}
					else if rd[KEY_ADDITIONAL_ROWS] as! Int == 0
					{
						if rd[KEY_IS_VISIBLE] as! Bool == true
						{
							rd[KEY_IS_VISIBLE] = false
						}
					}

					rowDictionary[indexPath.section].cell[index] = rd

					index += 1
				}
			}

			if rowDict[KEY_CAN_EXPAND] as! Bool == true
			{
				var shouldExpand = false

				if rowDict[KEY_IS_EXPANDED] as! Bool == false { shouldExpand = true }

				rowDict[KEY_IS_EXPANDED] = shouldExpand

				for i in (indexPath.row + 1)...(indexPath.row + (rowDict[KEY_ADDITIONAL_ROWS] as! Int))
				{
					rowDictionary[indexPath.section].cell[i][KEY_IS_VISIBLE] = shouldExpand
				}
			}

			rowDictionary[indexPath.section].cell[indexPath.row] = rowDict
			
			tableView.reloadSections(NSIndexSet(index: indexPath.section) as IndexSet, with: .left)
		}

		var enableBuyTickets = true
		
		switch gState
		{
			case .movie:
				//	if click is on L1 or L2
				//	row show Theater detail
				if rowDict[KEY_CELL_IDENTIFIER] as! String == VALUE_L1_CELL { enableBuyTickets = false }

				gCurrTheater = gTheater.index{ $0.theater[KEY_ID] as! String == rowDict[KEY_ID] as! String }!

				(childViewControllers.first as! ViewControllerContainer).updateTheaterDetailView(enableBuyTickets)
			case .theater:
				//	if click is on L1 row it's a
				//	Movie, show Movie Detail
				gCurrMovie = gMovie.index{ $0.movie[KEY_TMS_ID] as! String == rowDict[KEY_TMS_ID] as! String }!
				
				if rowDict[KEY_CELL_IDENTIFIER] as! String == VALUE_L1_CELL
				{
					(childViewControllers.first as! ViewControllerContainer).updateMovieDetailView()
				}
				else	//	it's a Movie show time, show Theater Detail
				{
					//	L2 cells are always show times and
					//	have both KEY_TMS_ID and KEY_ID

					gCurrTheater = gTheater.index{ $0.theater[KEY_ID] as! String == rowDict[KEY_ID] as! String }!

					(childViewControllers.first as! ViewControllerContainer).updateTheaterDetailView(enableBuyTickets)
				}
			
			default:
				print("unexpected COType in didSelectRowAt")
		}
	}
	
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
	{
		if gState == .theater
		{
			pendingOperations.operationQueue.isSuspended = true
		}
    }
    
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
	{
		if gState == .theater
		{
			if !decelerate
			{
				loadDistanceforOnScreenSections()
				pendingOperations.operationQueue.isSuspended = false
			}
		}
    }
    
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
	{
		if gState == .theater
		{
			loadDistanceforOnScreenSections()
			pendingOperations.operationQueue.isSuspended = false
		}
	}
}
