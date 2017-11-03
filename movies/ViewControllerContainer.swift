//
//  ViewControllerContainer.swift
//  movies
//
//  Created by Jerry Hale on 10/2/16.
//  Copyright © 2017 jhale. All rights reserved.
//

import UIKit

//	MARK: ViewControllerContainer
class ViewControllerContainer: UIViewController
{
	func trailerSegueUnwind()
	{
		//	pop the ViewControllerTrailer and push the ViewControllerMovieDetail
		let tc: ViewControllerTrailer = self.childViewControllers[0] as! ViewControllerTrailer
		tc.performSegue(withIdentifier: S2_CONTAINER_UNWIND, sender: tc)
		self.performSegue(withIdentifier: S2_MOVIE_DETAIL, sender: self)
		
		let mdc: ViewControllerMovieDetail? = self.childViewControllers.flatMap({ $0 as? ViewControllerMovieDetail }).first

		mdc?.updateView()
	}

	func trailerSegueWind()
	{
		//	pop the ViewControllerMovieDetail and push the ViewControllerTrailer
		let mdc: ViewControllerMovieDetail? = self.childViewControllers.flatMap({ $0 as? ViewControllerMovieDetail }).first
		
		mdc?.performSegue(withIdentifier: S2_CONTAINER_UNWIND, sender: mdc)
		self.performSegue(withIdentifier: S2_MOVIE_TRAILER, sender: self)
	}

	func updateMovieDetailView()
	{
		var mdc: ViewControllerMovieDetail? = self.childViewControllers[0] as? ViewControllerMovieDetail
		
		if mdc == nil
		{
			let tdc: ViewControllerTheaterDetail? = self.childViewControllers[0] as? ViewControllerTheaterDetail
		
			if tdc == nil
			{
				let tc: ViewControllerTrailer? = self.childViewControllers[0] as? ViewControllerTrailer
				
				tc?.performSegue(withIdentifier: S2_CONTAINER_UNWIND, sender: tc)
			}
			else
			{
				tdc?.performSegue(withIdentifier: S2_CONTAINER_UNWIND, sender: tdc)
			}
			
			self.performSegue(withIdentifier: S2_MOVIE_DETAIL, sender: self)
			mdc = self.childViewControllers[0] as? ViewControllerMovieDetail
		}

		mdc?.updateView()
	}

	func updateTheaterDetailView()
	{
		var tdc: ViewControllerTheaterDetail? = self.childViewControllers[0] as? ViewControllerTheaterDetail

		if tdc == nil
		{
			let mdc: ViewControllerMovieDetail? = self.childViewControllers[0] as? ViewControllerMovieDetail
		
			if mdc == nil
			{
				let tc: ViewControllerTrailer? = self.childViewControllers[0] as? ViewControllerTrailer
				
				tc?.performSegue(withIdentifier: S2_CONTAINER_UNWIND, sender: tc)
			}
			else
			{
				mdc?.performSegue(withIdentifier: S2_CONTAINER_UNWIND, sender: mdc)
			}
			
			self.performSegue(withIdentifier: S2_THEATER_DETAIL, sender: self)
			tdc = self.childViewControllers[0] as? ViewControllerTheaterDetail
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

	//	MARK: UIViewController overrides
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
			transistion(dest: segue.destination as! ViewControllerMovieDetail)
			
			(segue.destination as! ViewControllerMovieDetail).updateView()
		}
		else if segue.identifier == S2_THEATER_DETAIL
		{ transistion(dest: segue.destination as! ViewControllerTheaterDetail) }
		else { transistion(dest: segue.destination as! ViewControllerTrailer) }
	}
	
	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("ViewControllerContainer viewWillDisappear") }

	override func viewDidLoad()
	{ super.viewDidLoad(); print("ViewControllerContainer viewDidLoad")

		if gState[KEY_CO_STATE] as! COType == .cot_theater_detail
		{
			self.performSegue(withIdentifier: S2_THEATER_DETAIL, sender: self)
		}
		else { self.performSegue(withIdentifier: S2_MOVIE_DETAIL, sender: self) }
	}
}

//		let alert = UIAlertController(title: "Notification!",
//									  message:"\(message)",
//									  preferredStyle: UIAlertControllerStyle.alert)
//		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//		self.present(alert, animated: true, completion: nil)

//		let ViewControllerContainer: ViewControllerContainer = childViewControllers.flatMap({ $0 as? ViewControllerContainer }).first!
//		let ViewControllerMovieDetail: ViewControllerMovieDetail? = ViewControllerContainer.childViewControllers.flatMap({ $0 as? ViewControllerMovieDetail }).first
//		let mdv = ViewControllerMovieDetail?.view as! MovieDetailView
