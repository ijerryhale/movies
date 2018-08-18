//
//  ViewControllerMarquee.swift
//  movies
//
//  Created by Jerry Hale on 9/8/16.
//  Copyright © 2018 jhale. All rights reserved.
//

import QuartzCore
import Foundation
import UIKit

//	MARK: LazyPoster
class LazyPoster
{
	var urlString: String
	var state = OpState.new
	var image = UIImage()
	
	init(title: String, urlString: Any)
	{
		if urlString is NSNull { self.urlString = "" }
		else { self.urlString = urlString as! String }
		
		self.image = createGenericPoster(title)
	}
}

//	MARK: PendingMarqueeOperations
class PendingMarqueeOperations
{
	lazy var inProgress = [NSIndexPath:Operation]()
	
	lazy var operationQueue: OperationQueue = {
		var queue = OperationQueue()
		queue.name = UUID().uuidString
		queue.maxConcurrentOperationCount = 1
		return (queue)
	}()
}

//	MARK: ViewControllerMarquee
class ViewControllerMarquee: UIViewController
{
	@IBOutlet weak var postalCode: UITextField!
	@IBOutlet weak var showdateBtn: UIButton!
	@IBOutlet weak var	tableView: UITableView!

	@IBAction func unwindToMarquee(segue: UIStoryboardSegue) { }
	@IBAction func postalCodeChangedValue(_ sender: UITextField)
	{
		//	FIX THIS!!
		var postalCode = sender.text
		
		if (postalCode != "95014"
			&& postalCode != "10021"
			&& postalCode != "60601"
			&& postalCode != "90024") { postalCode = "95014"; self.postalCode.text = postalCode }

		UserDefault.setPostalCode(postalCode!)
	}

	@IBAction func tapGetBtn(_ sender: Any)
	{
		(UIApplication.shared.delegate as! AppDelegate).rebuild_theaters()
		{
			(result) -> () in

			gCurrMovie = 0
			gCurrTheater = 0

			self.tableView.reloadData()
			self.tableView.scrollToRow(at: [0, NSNotFound], at: .top, animated: false)
		}
	}
	
	let pendingOperations = PendingMarqueeOperations()

	func notif_showdate(notification: Notification)
	{ print("ViewControllerSettings notif_showdate");
	
		self.showdateBtn.setTitle(get_show_date(), for: .normal)
	}

    func startOperationForPoster(poster: LazyPoster, indexPath: NSIndexPath)
	{
		//	MARK: DownloadImage Operation
		class DownloadImage: Operation
		{
			let lazyPoster: LazyPoster
			
			init(lazyPoster: LazyPoster) { self.lazyPoster = lazyPoster }

			override func main()
			{
				if self.isCancelled { return }
				
				if lazyPoster.urlString.isEmpty == false
				{
					let url = DataHelper.get_URL_POSTER(lazyPoster.urlString)
					let da = DataAccess()
			
					if let imgdata = da.getCachedPoster(url), let image = UIImage(data: imgdata as Data)
					{
						DispatchQueue.main.async(execute: { self.lazyPoster.image = image })
					}
					else
					{
						let data = NSData(contentsOf: url!)
						
						guard
							let imgdata = data, let image = UIImage(data: imgdata as Data)
							else { return }

						DispatchQueue.main.async(execute: { self.lazyPoster.image = image })
						
						da.cachePoster(url, data: data! as Data)
					}
				}
				
				self.lazyPoster.state = .done
			}
		}

        if poster.state == .new
		{
			if let _ = pendingOperations.inProgress[indexPath] { return }
			
			let downloadImg = DownloadImage(lazyPoster: poster)
			
			downloadImg.completionBlock = {
				
				if downloadImg.isCancelled { return }
				
				DispatchQueue.main.async(execute: {
					self.pendingOperations.inProgress.removeValue(forKey: indexPath)
					self.tableView.reloadRows(at: [indexPath as IndexPath], with: .fade)
				})
			}
			
			pendingOperations.inProgress[indexPath] = downloadImg
			pendingOperations.operationQueue.addOperation(downloadImg)
        }
    }

    func loadImageforOnScreenCells()
	{
        if let pathsArray = tableView.indexPathsForVisibleRows
		{
            let allPendingOperations = Set(pendingOperations.inProgress.keys)
            
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray as [NSIndexPath])
            toBeCancelled.subtract(visiblePaths)
            
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations)
            
            for indexPath in toBeCancelled
			{
                if let pendingDownload = pendingOperations.inProgress[indexPath]
				{
                    pendingDownload.cancel()
                }
                
                pendingOperations.inProgress.removeValue(forKey: indexPath)
			}

            for indexPath in toBeStarted
			{
				startOperationForPoster(poster: gMovie[indexPath.row].poster, indexPath: indexPath as NSIndexPath)
            }
        }
    }

	@objc func canRotate() -> Void {}
	//	MARK: UIViewController overrides
    override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue
	{
		return CustomUnwindSegue(identifier: identifier, source: fromViewController, destination: toViewController)
    }

	override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning(); print("ViewControllerMarquee didReceiveMemoryWarning")}
	override func viewWillAppear(_ animated: Bool)
	{ super.viewWillAppear(animated); print("ViewControllerMarquee viewWillAppear")

		//	called on seque from ViewControllerBoxOffice
		//	and on intial application launch

		//	NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:NOTIF_LAST_UPDATE_CHANGED),
        //       object:nil, queue:nil, using:notif_defaults_changed)
		//	NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:NOTIF_POSTAL_CODE_CHANGED),
        //       object:nil, queue:nil, using:notif_defaults_changed)
        
		NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:NOTIF_DAY_OFFSET_CHANGED),
               object:nil, queue:nil, using:notif_showdate)

		postalCode.text = UserDefault.getPostalCode()
		postalCode.delegate = self
		
		gState = .marquee
		tableView.scrollToRow(at: [0, gCurrMovie], at: .middle, animated: true)
	}

	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("ViewControllerMarquee viewWillDisappear")

		//	only called on seque to ViewControllerBoxOffice

		if (self.isMovingFromParentViewController) { UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation") }
		
		//	NotificationCenter.default.removeObserver(Notification.Name(rawValue:NOTIF_LAST_UPDATE_CHANGED))
		//	NotificationCenter.default.removeObserver(Notification.Name(rawValue:NOTIF_POSTAL_CODE_CHANGED))
		NotificationCenter.default.removeObserver(Notification.Name(rawValue:NOTIF_DAY_OFFSET_CHANGED))
	}

	@objc func doneButtonAction() { postalCode.resignFirstResponder() }

    override func viewDidLoad()
	{ super.viewDidLoad(); print("ViewControllerMarquee viewDidLoad")

		//	only called on app launch
		
		view.accessibilityIdentifier = AXID_marqueeView
	
		tableView.layer.borderWidth = 1.0;
		tableView.layer.borderColor = UIColor.white.cgColor
		
		tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
		
		tableView.accessibilityLabel = AXLABEL_marqueeTableView
		tableView.register(UINib(nibName: VALUE_MARQUEE_CELL, bundle: nil), forCellReuseIdentifier: VALUE_MARQUEE_CELL)

		tableView.reloadData()
	
		showdateBtn.setTitle(get_show_date(), for: .normal)
		
		let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
		doneToolbar.barStyle = UIBarStyle.default

		var items = [UIBarButtonItem]()

		items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
		items.append(UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(ViewControllerMarquee.doneButtonAction)))

		doneToolbar.items = items
		doneToolbar.sizeToFit()

		postalCode.inputAccessoryView = doneToolbar
	}
}

//	MARK: UITextFieldDelegate Delegate Methods
extension ViewControllerMarquee : UITextFieldDelegate
{
	func textFieldShouldReturn(_ textField: UITextField) -> Bool
	{
		textField.resignFirstResponder()
		
		return (true)
	}
}

//	MARK: UITableView Datasource Methods
extension ViewControllerMarquee : UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{ return (gMovie.count) }
    
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        let cell = tableView.dequeueReusableCell(withIdentifier: VALUE_MARQUEE_CELL, for: indexPath) as! Marquee_Cell
		
		cell.poster.image = gMovie[indexPath.row].poster.image
		
        switch gMovie[indexPath.row].poster.state
		{
			case .failed:
				//	print(".failed")
				cell.indicator.stopAnimating()
			case .new:
				//	print(".new")
				cell.indicator.startAnimating()
				
				if (!tableView.isDragging && !tableView.isDecelerating)
				{
					self.startOperationForPoster(poster: gMovie[indexPath.row].poster, indexPath: indexPath as NSIndexPath)
				}
			case .done:
				cell.indicator.stopAnimating()
				//	print(".done")
        }
        
        return (cell)
    }
}

//	MARK: UITableView Delegate Methods
extension ViewControllerMarquee : UITableViewDelegate
{
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
	{ pendingOperations.operationQueue.isSuspended = true }
    
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
	{
        if !decelerate
		{
            loadImageforOnScreenCells()
			pendingOperations.operationQueue.isSuspended = false
 		}
    }
    
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
	{
        loadImageforOnScreenCells()
        pendingOperations.operationQueue.isSuspended = false
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		//	moving to ViewControllerBoxOffice - this indexPath.row
		//	becomes ViewControllerBoxOffice indexPath.section
		gState = .movie
		gCurrMovie = indexPath.row
		
		self.performSegue(withIdentifier: S2_BOX_OFFICE, sender: nil)
    }
}
