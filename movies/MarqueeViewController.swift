//
//  MarqueeViewController.swift
//  Movies
//
//  Created by Jerry Hale on 9/8/16.
//  Copyright © 2017 jhale. All rights reserved.
//

import Foundation
import UIKit

//	MARK: MoviePoster
class MoviePoster
{
    let title: String
    var urlString: String
    
    var state = RowState.new
    var image = UIImage()
	
    init(title: String, urlString: Any)
	{
        self.title = title

		if (urlString is NSNull)
		{
			self.urlString = ""
		}
		else
		{
			self.urlString = urlString as! String
		}

		let image = UIImage(named: "filmclip.png")
		
		UIGraphicsBeginImageContext((image?.size)!)
		
		image?.draw(in: CGRect(x: 0, y: 0, width: (image?.size.width)!, height: (image?.size.height)!))

		let titleString =
					NSMutableAttributedString(string: title,
				attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 17)!])
		
		titleString.addAttribute(
				NSForegroundColorAttributeName,
					value: UIColor.white,
					range: NSRange(location:0, length:titleString.length))
		
		let paraStyle = NSMutableParagraphStyle()
		paraStyle.alignment = .center

		titleString.addAttribute(NSParagraphStyleAttributeName, value:paraStyle,			range:NSRange(location:0, length:titleString.length))
		
		titleString.draw(in: CGRect(x: 10, y: 50, width: (image?.size.width)! - 20, height: (image?.size.height)!))

		self.image = UIGraphicsGetImageFromCurrentImageContext()!;
		UIGraphicsEndImageContext()
    }
}

//	MARK: PendingOperations
class PendingOperations
{
    lazy var downloadInProgress = [NSIndexPath:Operation]()
    
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Dowload Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}

//	MARK: ImageDownloader Operation
class ImageDownloader: Operation
{
    let moviePoster: MoviePoster
    
    init(moviePoster: MoviePoster) { self.moviePoster = moviePoster }
    
    override func main()
	{
        if self.isCancelled { return }
		
		print(moviePoster.urlString)
		if moviePoster.urlString.isEmpty == false
		{
			if let data = DataAccess.get_DATA(moviePoster.urlString)
			{
				self.moviePoster.image = UIImage(data: data)!
			}
		}

		self.moviePoster.state = .downloaded
	}
}

class MarqueeViewController: UIViewController
{
	@IBOutlet weak var	tableView: UITableView!

	@IBAction func unwindToMarquee(segue: UIStoryboardSegue) { }
	@IBAction func tapPreferencesBtn(sender: UIButton) { self.performSegue(withIdentifier: S2_PREFERENCE, sender: self) }

	var poster = [MoviePoster]()
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
                let recordToProcess = poster[indexPath.row]
                startOperationsForPoster(poster: recordToProcess, indexPath: indexPath)
            }
        }
    }
    
    func startOperationsForPoster(poster: MoviePoster, indexPath: NSIndexPath)
	{
        switch poster.state
		{
			case .new:
				
				if let _ = pendingOperations.downloadInProgress[indexPath] { return }
				
				let downloader = ImageDownloader(moviePoster: poster)
				
				downloader.completionBlock = {
					
					if downloader.isCancelled { return }
					
					DispatchQueue.main.async(execute: {
						self.pendingOperations.downloadInProgress.removeValue(forKey: indexPath)
						self.tableView.reloadRows(at: [indexPath as IndexPath], with: .fade)
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

		tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
		
		tableView.register(UINib(nibName: VALUE_MARQUEE_CELL, bundle: nil), forCellReuseIdentifier: VALUE_MARQUEE_CELL)

		for i in 0...gMovie.count - 1
		{
			let movie:[[String: AnyObject]] = gMovie
			let title = movie[i][KEY_TITLE] as! String
			
			var urlString = ""

			print(movie[i][KEY_POSTER])
			if (movie[i][KEY_POSTER] is NSNull) == false
			{
				urlString = movie[i][KEY_POSTER] as! String
			}
			
			
			let moviePoster = MoviePoster(title: title, urlString: urlString)
			
			self.poster.append(moviePoster)
		}

		self.tableView.reloadData()
	}
}

//	MARK: UITableView Datasource Methods
extension MarqueeViewController : UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
        return poster.count
    }
    
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        let cell = tableView.dequeueReusableCell(withIdentifier: VALUE_MARQUEE_CELL, for: indexPath) as! Marquee_Cell
		let thisPoster = poster[indexPath.row]

		cell.poster.image = thisPoster.image
		
        switch thisPoster.state
		{
			case .failed:
				cell.indicator.stopAnimating()
			case .new:
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
