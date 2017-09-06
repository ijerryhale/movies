//
//  MarqueeViewController.swift
//  Movies
//
//  Created by Jerry Hale on 9/8/16.
//  Copyright © 2017 jhale. All rights reserved.
//

import Foundation
import UIKit

public enum RowState { case new, downloaded, failed }

//	MARK: MarqueeViewController
class MarqueeViewController: UIViewController
{
	@IBOutlet weak var	tableView: UITableView!

	@IBAction func unwindToMarquee(segue: UIStoryboardSegue) { }
	@IBAction func tapPreferencesBtn(sender: UIButton) { self.performSegue(withIdentifier: S2_PREFERENCE, sender: self) }

    let pendingOperations = PendingOperations()

	override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }

    func loadImagesforOnScreenCells()
	{
        if let pathsArray = tableView.indexPathsForVisibleRows
		{
            let allPendingOperations = Set(pendingOperations.downloadInProgress.keys)
            
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray as [NSIndexPath])
            toBeCancelled.subtract(visiblePaths)
            
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations)
            
            for indexPath in toBeCancelled
			{
                if let pendingDownload = pendingOperations.downloadInProgress[indexPath]
				{
                    pendingDownload.cancel()
                }
                
                pendingOperations.downloadInProgress.removeValue(forKey: indexPath)
			}

            for indexPath in toBeStarted
			{
                let indexPath = indexPath as NSIndexPath
				let tmsid = gMovie[indexPath.row][KEY_TMS_ID] as! String
		
				guard
					let thisPoster = gLazyPoster.filter({ $0.tms_id == tmsid }).first
					else { fatalError("loadImagesforOnScreenCells returned NULL LazyPoster") }

                startOperationsForPoster(poster: thisPoster, indexPath: indexPath)
            }
        }
    }
    
    func startOperationsForPoster(poster: LazyPoster, indexPath: NSIndexPath)
	{
        switch poster.state
		{
			case .new:
				
				if let _ = pendingOperations.downloadInProgress[indexPath] { return }
				
				let downloader = ImageDownloader(lazyPoster: poster)
				
				downloader.completionBlock = {
					
					if downloader.isCancelled { return }
					
					DispatchQueue.main.async(execute: {
						self.pendingOperations.downloadInProgress.removeValue(forKey: indexPath)
						self.tableView.reloadRows(at: [indexPath as IndexPath], with: .left)
					})
					
				}
				
				pendingOperations.downloadInProgress[indexPath] = downloader
				pendingOperations.downloadQueue.addOperation(downloader)

			default:
				print("None.")
        }
        
    }
	
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
	{ super.viewDidLoad(); print("MarqueeViewController viewDidLoad ")
		
		self.view.accessibilityIdentifier = AXID_marqueeView
	
		tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
		
		tableView.accessibilityLabel = AXLABEL_marqueeTableView

		tableView.register(UINib(nibName: VALUE_MARQUEE_CELL, bundle: nil), forCellReuseIdentifier: VALUE_MARQUEE_CELL)

		self.tableView.reloadData()
	}
}

//	MARK: UITableView Datasource Methods
extension MarqueeViewController : UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
        return gLazyPoster.count
    }
    
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        let cell = tableView.dequeueReusableCell(withIdentifier: VALUE_MARQUEE_CELL, for: indexPath) as! Marquee_Cell
		
		let tmsid = gMovie[indexPath.row][KEY_TMS_ID] as! String
		
		guard
            let thisPoster = gLazyPoster.filter({ $0.tms_id == tmsid }).first
			else { fatalError("cellForRowAt returned NULL LazyPoster") }
		
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
					self.startOperationsForPoster(poster: thisPoster, indexPath: indexPath as NSIndexPath)
				}

			case .downloaded:
				//	print(".downloaded")
				cell.indicator.stopAnimating()
        }
        
        return cell
    }
}

//	MARK: UITableView Delegate Methods
extension MarqueeViewController : UITableViewDelegate
{
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
	{
		pendingOperations.downloadQueue.isSuspended = true
    }
    
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
	{
        if !decelerate
		{
            loadImagesforOnScreenCells()
			pendingOperations.downloadQueue.isSuspended = false
 		}
    }
    
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
	{
        loadImagesforOnScreenCells()
        pendingOperations.downloadQueue.isSuspended = false
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		gState = [KEY_CO_STATE : COType.cot_movie_detail, KEY_CO_INDEX : indexPath.row]

		self.performSegue(withIdentifier: S2_BOX_OFFICE,
							sender: nil)
    }
}
