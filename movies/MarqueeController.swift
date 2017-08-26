//
//  MarqueeController.swift
//  Movies
//
//  Created by Jerry Hale on 9/8/16.
//  Copyright © 2017 jhale. All rights reserved.
//

import Foundation
import UIKit
//
//let POSTER_WIDTH:CGFloat = 134;
//let POSTER_HGHT:CGFloat = 194;

let POSTER_WIDTH:CGFloat = 241;
let POSTER_HGHT:CGFloat = 349;

let POSTER_BORDER_WIDTH:CGFloat = 2;
let POSTER_BORDER_HGHT:CGFloat = 2;

let POSTER_CONTENT_WIDTH:CGFloat = POSTER_WIDTH + (2 * POSTER_BORDER_WIDTH);
let POSTER_CONTENT_HGHT:CGFloat = POSTER_HGHT + (2 * POSTER_BORDER_HGHT);

class PosterContentView: UIView
{
	var poster :UIImageView
	
    override init (frame : CGRect)
	{
		poster = UIImageView(frame: CGRect(x: 1, y: 1, width: frame.size.width - 2, height: frame.size.height - 2))
		poster.clipsToBounds = true

		super.init(frame : frame)
		
		addSubview(poster)
	}

    required init(coder aDecoder: NSCoder) { fatalError("This class does not support NSCoding") }

	override func draw(_ rect: CGRect)
	{
		UIColor(white: 1, alpha: 0.7).setStroke()
		UIBezierPath(rect:rect).stroke()
	}
}

class MarqueeController: UIViewController
{
	//	if you're real fast you can
	//	tap two different posters
	var waitingtap = true
	var scrollView: UIScrollView!
	
	@IBAction func unwindToMarquee(segue: UIStoryboardSegue) { waitingtap = true }
	@IBAction func tapPreferencesBtn(sender: UIButton)
	{ self.performSegue(withIdentifier: S2_PREFERENCE, sender: self) }

	func segue_to_box_office(sender: UITapGestureRecognizer)
	{
		//	print("segue_to_box_office")
		var loc: CGPoint = sender.location(in: sender.view)

		//	only worry about taps in marquee
		let hitFrame = CGRect(x: (scrollView.frame.size.width / 2)
										- (POSTER_CONTENT_WIDTH / 2),
										y: scrollView.frame.origin.y,
										width: POSTER_CONTENT_WIDTH,
										height: scrollView.frame.size.height)
		
		if hitFrame.contains(loc) == false { return }
		else if waitingtap == false { return }

		waitingtap = false
		
		loc.y += scrollView.contentOffset.y - 16
		
		//	print("mouse location: ", loc)
		for i in 0..<scrollView.subviews[0].subviews.count - 1
		{
			if scrollView.subviews[0].subviews[i].frame.contains(loc)
			{
				gState = [KEY_CO_STATE : COType.cot_movie_detail, KEY_CO_INDEX : i]

				self.performSegue(withIdentifier: S2_BOX_OFFICE,
							sender: nil)
				break
			}
		}
	}

	override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }

	//	MARK: UIViewController overrides
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.identifier == S2_PREFERENCE
		{
			let pc = (segue.destination as? PreferenceController)!
			pc.callingViewControler = self
		}
	}

    override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue
	{
		return CustomUnwindSegue(identifier: identifier, source: fromViewController, destination: toViewController)
    }
	
	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("MarqueeController viewWillDisappear ") }
	
	override func viewDidLoad()
	{	super.viewDidLoad(); print("MarqueeController viewDidLoad ")
	
		view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.segue_to_box_office(sender:))))

		let marqueeView = UIView(frame: CGRect(x: 0, y: 0,
											width: self.view.frame.width,
											height: self.view.frame.height))
		marqueeView.clipsToBounds = false;
		marqueeView.accessibilityIdentifier = "marqueeView"
		
		var	y:CGFloat = POSTER_BORDER_HGHT
		let m:[[String: AnyObject]] = gMovie

		for i in 0...gMovie.count - 1
		{
			let movie = m[i]

			let contentView =
				PosterContentView(frame: CGRect(x: (self.view.frame.size.width / 2)
																- (POSTER_CONTENT_WIDTH / 2),
																y: y,
																width: POSTER_CONTENT_WIDTH,
																height: POSTER_CONTENT_HGHT))
			contentView.backgroundColor = UIColor.darkGray
			contentView.isUserInteractionEnabled = true;
			contentView.poster.image = getPosterImage(movie: movie as AnyObject)
			//	if portrait orientation POSTER_CONTENT_HGHT else POSTER_CONTENT_WIDTH
			y += POSTER_CONTENT_HGHT + POSTER_BORDER_HGHT
			//	index += 1
			
			marqueeView.addSubview(contentView)
		}

		scrollView = UIScrollView(frame: CGRect(x: 0, y: 16,
											width: self.view.frame.width,
											height: self.view.frame.height - 32))
		
		scrollView.backgroundColor = UIColor.black
		scrollView.addSubview(marqueeView)
		scrollView.contentSize = CGSize(width: self.view.frame.width, height: y)
		
		view.addSubview(scrollView)
		view.backgroundColor = UIColor.black
		//	bring prefs button forward
		view.bringSubview(toFront: view.subviews[0])
	}
}
