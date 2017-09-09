//
//  ContainerController.swift
//  Movies
//
//  Created by Jerry Hale on 10/2/16.
//  Copyright © 2017 jhale. All rights reserved.
//

import UIKit

//	MARK: ContainerController
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

//		let alert = UIAlertController(title: "Notification!",
//									  message:"\(message)",
//									  preferredStyle: UIAlertControllerStyle.alert)
//		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//		self.present(alert, animated: true, completion: nil)

//		let containerController: ContainerController = childViewControllers.flatMap({ $0 as? ContainerController }).first!
//		let movieDetailViewController: MovieDetailViewController? = containerController.childViewControllers.flatMap({ $0 as? MovieDetailViewController }).first
//		let mdv = MovieDetailViewController?.view as! MovieDetailView
