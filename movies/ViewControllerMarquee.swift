//
//  ViewControllerMarquee.swift
//  movies
//
//  Created by Jerry Hale on 9/8/16.
//  Copyright © 2018 jhale. All rights reserved.
//

//	LazyPoster class and lazy loading code is based upon:
//	https://www.raywenderlich.com/76341/use-nsoperation-nsoperationqueue-swift

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
		return queue
	}()
}

//	MARK: ViewControllerMarquee
class ViewControllerMarquee: UIViewController
{
	@IBOutlet weak var	tableView: UITableView!

	@IBAction func unwindToMarquee(segue: UIStoryboardSegue) { }
	@IBAction func tapSettinsBtn(sender: UIButton) { self.performSegue(withIdentifier: S2_SETTINGS, sender: self) }

    let pendingOperations = PendingMarqueeOperations()

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
					if let data = DataAccess.get_DATA(lazyPoster.urlString)
					{
						self.lazyPoster.image = UIImage(data: data)!
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
                let indexPath = indexPath as NSIndexPath
				let thisPoster = gMovie[indexPath.row].poster
			
                startOperationForPoster(poster: thisPoster, indexPath: indexPath)
            }
        }
    }

	//	MARK: UIViewController overrides
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.identifier == S2_SETTINGS
		{
//			let pc = (segue.destination as? PreferenceViewController)!
//			pc.callingViewControler = self
		}
	}

    override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue
	{
		return CustomUnwindSegue(identifier: identifier, source: fromViewController, destination: toViewController)
    }
	
	override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }

	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("ViewControllerMarquee viewWillDisappear ") }

    override func viewDidLoad()
	{ super.viewDidLoad(); print("ViewControllerMarquee viewDidLoad ")
		
		self.view.accessibilityIdentifier = AXID_marqueeView
	
		tableView.layer.borderWidth = 1.0;
		tableView.layer.borderColor = UIColor.white.cgColor
		
		tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
		
		tableView.accessibilityLabel = AXLABEL_marqueeTableView

		tableView.register(UINib(nibName: VALUE_MARQUEE_CELL, bundle: nil), forCellReuseIdentifier: VALUE_MARQUEE_CELL)

		self.tableView.reloadData()
	}
}

//	MARK: UITableView Datasource Methods
extension ViewControllerMarquee : UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
        return gMovie.count
    }
    
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        let cell = tableView.dequeueReusableCell(withIdentifier: VALUE_MARQUEE_CELL, for: indexPath) as! Marquee_Cell
		
		let thisPoster = gMovie[indexPath.row].poster
		
		cell.poster.image = thisPoster.image
		
        switch thisPoster.state
		{
			case .failed:
				///	print(".failed")
				cell.indicator.stopAnimating()
			case .new:
				//	print(".new")
				cell.indicator.startAnimating()
				
				if (!tableView.isDragging && !tableView.isDecelerating)
				{
					self.startOperationForPoster(poster: thisPoster, indexPath: indexPath as NSIndexPath)
				}

			case .done:
				//	print(".done")
				cell.indicator.stopAnimating()
        }
        
        return (cell)
    }
}

//	MARK: UITableView Delegate Methods
extension ViewControllerMarquee : UITableViewDelegate
{
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
	{
		pendingOperations.operationQueue.isSuspended = true
    }
    
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
		gState = [KEY_CO_STATE : COType.movie_detail, KEY_CO_INDEX : indexPath.row]

		self.performSegue(withIdentifier: S2_BOX_OFFICE,
							sender: nil)
    }
}
