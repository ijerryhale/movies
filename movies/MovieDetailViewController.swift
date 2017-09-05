//
//  MovieDetailViewController.swift
//  Movies
//
//  Created by Jerry Hale on 4/2/17.
//  Copyright © 2017 jhale. All rights reserved.
//

//	194 X 134

import UIKit

//	MARK: MovieDetailViewController
class MovieDetailViewController : UIViewController
{
	@IBOutlet weak var poster: UIImageView!
	@IBOutlet weak var filmtitle: UILabel!
	@IBOutlet weak var rating: UILabel!
	@IBOutlet weak var tomato: UIImageView!
	@IBOutlet weak var tomatorating: UILabel!
	@IBOutlet weak var releasedate: UILabel!
	@IBOutlet weak var runtime: UILabel!
	@IBOutlet weak var cast: UITextView!
	@IBOutlet weak var directors: UILabel!
	@IBOutlet weak var genre: UILabel!
	@IBOutlet weak var summary: UITextView!

	@IBOutlet weak var viewTrailerBtn: UIButton!
	@IBOutlet weak var viewIniTunesBtn: UIButton!
	@IBOutlet weak var buyTicketsBtn: UIButton!

	@IBAction func viewTrailerBtnPressed(_ sender: UIButton)
	{
		//	disable Prefs Button
		(parent?.parent as! BoxOfficeViewController).disablePrefsBtn()
		//	pop MovieDetailViewController push TrailerController
		(parent as! ContainerController).trailerSegueWind()
	}

	@IBAction func viewIniTunesBtnPressed(_ sender: UIButton)
	{
		(parent?.parent as! BoxOfficeViewController).performSegue(withIdentifier: S2_ITUNES, sender: self)
	}
	
	func updateView()
	{
		let index = gState[KEY_CO_INDEX] as! Int
		let movie = gMovie[index]

		if movie[KEY_POSTER] is NSNull { poster.image = createGenericPoster(title: movie[KEY_TITLE] as! String) }
		else
		{
			if let data = DataAccess.get_DATA(movie[KEY_POSTER] as! String)
			{
				poster.image = UIImage(data: data)!
			}
			else { poster.image = createGenericPoster(title: movie[KEY_TITLE] as! String) }
		}

		filmtitle.text = movie[KEY_TITLE] as? String
		
		if (movie[KEY_RATING] is NSNull) == false { rating.text = movie[KEY_RATING] as? String }
		else { rating.text = "NR" }
		
		runtime.text = movie[KEY_RUN_TIME] as? String
		releasedate.text = movie[KEY_RELEASE_DATE] as? String

		let info = gIndex.filter({ $0[KEY_ID] as? String == movie[KEY_FILM_ID] as? String }).first

		//	handle Rotten Tomato stuff
		#if HAS_WEB_SERVICE
			let tomatoRating = Int(movie[KEY_TOMATO_RATING] as! String)

			if tomatoRating != nil
			{
				if tomatoRating! < 1
				{
					tomatorating.isHidden = true
					tomato.isHidden = true
				}
				else
				{
					tomatorating.text = movie[KEY_TOMATO_RATING] as? String
					
					if tomatoRating! > 59 { tomato.image = UIImage(named: "tomato.png") }
					else { tomato.image = UIImage(named: "splat.png") }

					tomatorating.isHidden = false
					tomato.isHidden = false
				}
			}
			else
			{
				tomatorating.isHidden = true
				tomato.isHidden = true
			}
		#endif

		if info == nil
		{
			viewTrailerBtn?.isEnabled = false
			
			directors.text = ""
			summary.text = ""
			cast.text = (movie[KEY_ACTORS] as! [String]).joined(separator: ", ")
			genre.text = (movie[KEY_GENRES] as! [String]).joined(separator: ", ")
		}
		else
		{
			let thisInfo = info?[KEY_INFO]

			let c = thisInfo?[KEY_CAST] as! [String : AnyObject]
			cast.text = c[KEY_TEXT] as? String
			cast.flashScrollIndicators()

			let g = thisInfo?[KEY_GENRES] as! [String : AnyObject]
			genre.text = g[KEY_TEXT] as? String

			let d = thisInfo?[KEY_DIRECTORS] as! [String : AnyObject]
			directors.text = d[KEY_TEXT] as? String
			
			let s = thisInfo?[KEY_SUMMARY] as! [String : AnyObject]
			summary.text = s[KEY_TEXT] as? String
			summary.scrollRangeToVisible(NSMakeRange(0, 0))
			summary.flashScrollIndicators()

			let previews = info?[KEY_PREVIEWS] as! [String : AnyObject]
			let preview = previews[KEY_PREVIEW] as! [String : AnyObject]
			let  m = preview[KEY_TEXT] as! String
			
			if (m.utf8.count) > 0 { viewTrailerBtn?.isEnabled = true }
			else { viewTrailerBtn?.isEnabled = false }
		}

		if movie[KEY_ITUNES_URL] == nil
		{ viewIniTunesBtn?.isEnabled = false }
		else
		{
			let length = (movie[KEY_ITUNES_URL] as? String)?.utf8.count

			if length! > 0 { viewIniTunesBtn?.isEnabled = true }
			else { viewIniTunesBtn?.isEnabled = false }
		}
	}
	//	func getTicketPurchasePageUrl(movieId, theaterId, time) -> String
	func segue_to_marquee()
	{ (parent?.parent as! BoxOfficeViewController).performSegue(withIdentifier: S2_MARQUEE, sender: self) }

	//	MARK: UIViewController overrides
	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("MovieDetailViewController viewWillDisappear ") }

	override func viewDidLoad()
	{ super.viewDidLoad(); print("MovieDetailViewController viewDidLoad ")

		poster.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(segue_to_marquee)))
	}
}
