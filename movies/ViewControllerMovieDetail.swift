//
//  ViewControllerMovieDetail.swift
//  movies
//
//  Created by Jerry Hale on 4/2/17.
//  Copyright © 2018 jhale. All rights reserved.
//

//	194 X 134

import UIKit

//	MARK: ViewControllerMovieDetail
class ViewControllerMovieDetail : UIViewController
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
		(parent?.parent as! ViewControllerBoxOffice).disableSettingsBtn()
		//	pop ViewControllerMovieDetail push ViewControllerTrailer
		(parent as! ViewControllerContainer).trailerSegueWind()
	}

	@IBAction func viewIniTunesBtnPressed(_ sender: UIButton)
	{
		(parent?.parent as! ViewControllerBoxOffice).performSegue(withIdentifier: S2_ITUNES, sender: self)
	}
	
	func updateView()
	{
		let movie = gMovie[gCurrMovie]

		if movie.movie[KEY_POSTER] is NSNull { poster.image = createGenericPoster(movie.movie[KEY_TITLE] as! String) }
		else
		{
			if let data = DataAccess.get_DATA(movie.movie[KEY_POSTER] as! String)
			{
				poster.image = UIImage(data: data)!
			}
			else { poster.image = createGenericPoster(movie.movie[KEY_TITLE] as! String) }
		}

		filmtitle.text = movie.movie[KEY_TITLE] as? String
		
		if (movie.movie[KEY_RATING] is NSNull) == false { rating.text = movie.movie[KEY_RATING] as? String }
		else { rating.text = "NR" }
		
		runtime.text = movie.movie[KEY_RUN_TIME] as? String
		releasedate.text = movie.movie[KEY_RELEASE_DATE] as? String

		let info = gXMLIndex.filter({ $0[KEY_ID] as? String == movie.movie[KEY_FILM_ID] as? String }).first

		//	handle Rotten Tomato stuff
		#if HAS_WEB_SERVICE
			let tomatoRating = Int(movie.movie[KEY_TOMATO_RATING] as! String)

			if tomatoRating != nil
			{
				if tomatoRating! < 1
				{
					tomatorating.isHidden = true
					tomato.isHidden = true
				}
				else
				{
					tomatorating.text = movie.movie[KEY_TOMATO_RATING] as? String
					
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
			cast.text = (movie.movie[KEY_ACTORS] as! [String]).joined(separator: ", ")
			genre.text = (movie.movie[KEY_GENRES] as! [String]).joined(separator: ", ")
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

		if movie.movie[KEY_ITUNES_URL] == nil
		{ viewIniTunesBtn?.isEnabled = false }
		else
		{
			let length = (movie.movie[KEY_ITUNES_URL] as? String)?.utf8.count

			if length! > 0 { viewIniTunesBtn?.isEnabled = true }
			else { viewIniTunesBtn?.isEnabled = false }
		}
	}
	//	func getTicketPurchasePageUrl(movieId, theaterId, time) -> String
	@objc func segue_to_marquee()
	{
		gState = .marquee
		(parent?.parent as! ViewControllerBoxOffice).performSegue(withIdentifier: S2_MARQUEE, sender: self)
	}

	//	MARK: UIViewController overrides
	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("ViewControllerMovieDetail viewWillDisappear ") }

	override func viewDidLoad()
	{ super.viewDidLoad(); print("ViewControllerMovieDetail viewDidLoad ")

		poster.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(segue_to_marquee)))
	}
}
