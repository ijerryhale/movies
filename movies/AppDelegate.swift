//
//  AppDelegate.swift
//  movies
//
//  Created by Jerry Hale on 10/7/17.
//  Copyright © 2019 jhale. All rights reserved.
//

//	95014
//	10021
//	60601
//	90024

import Foundation
import UIKit

enum COType { case marquee, theater, movie }
enum OpState { case new, done, failed }

var gState = COType.marquee

var gCurrTheater : Int = 0
var gTheater = [(theater: [String : AnyObject], distance: LazyDistance)]()

var gCurrMovie : Int = 0
var gMovie = [(movie: [String : AnyObject], poster: LazyPoster)]()

var gXMLIndex = [[String : AnyObject]]()

@UIApplicationMain
class AppDelegate: UIResponder
{
	var window: UIWindow?
	
	func handleNetworkError(error: Error?) { print("handleNetworkError: ", error as Any) }
	func handleNoDataAvailable(error: Error?) { print("handleNoDataAvailable: ", error as Any) }

	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
	{
		if let topViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController)
		{
			if (topViewController.responds(to: Selector(("canRotate"))))
			{
				//	unlock landscape view orientations for this view controller
				return (.allButUpsideDown)
			}
		}
		
		//	only allow portrait (standard behaviour)
		return (.portrait)
	}
		
	private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController?
	{
		if (rootViewController == nil) { return nil }
		if (rootViewController.isKind(of: UITabBarController.self))
		{
		  return (topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController))
		}
		else if (rootViewController.isKind(of: UINavigationController.self))
		{
		  return (topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController))
		}
		else if (rootViewController.presentedViewController != nil)
		{
		  return (topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController))
		}

		return (rootViewController)
	}

	private func process_theaters(_ theaters: [[String : AnyObject]])
	{ print("process_theaters start")

		gTheater.removeAll()
		gMovie.removeAll()

		//	sort the Theaters by Theater name
		let theaters = theaters.sorted { ($0[KEY_NAME]! as! String) < ($1[KEY_NAME]! as! String) }

		//	create a set to hold Movie tms_id's
		let tms_id: NSMutableSet = NSMutableSet()

		//	loop thru the Theaters and create a unique set of Movies
		for i in 0...theaters.count - 1
		{
			var t = theaters[i] as [String : AnyObject]
			//	thisMov is one Movie in this Theaters 'now_showing' array
			for var thisMov in t[KEY_NOW_SHOWING] as! [[String:AnyObject]]
			{
				let tmsid = (thisMov as [String : AnyObject])[KEY_TMS_ID] as! String

				if tms_id.contains(tmsid) { continue }

				tms_id.add(tmsid)

				let lazyPoster = LazyPoster(title: thisMov[KEY_TITLE] as! String, urlString: thisMov[KEY_POSTER]!)

				//	dumpData(urlString, filmID: thisMov[KEY_FILM_ID] as? String)
				gMovie.append((thisMov, lazyPoster))
			}

			let aa = t[KEY_ADDRESS]

			let street = aa?[KEY_STREET] as! String
			let city = aa?[KEY_CITY] as! String
			let state = aa?[KEY_STATE] as! String
			let zip = aa?[KEY_POSTAL_CODE] as! String

			let lazyDistance = LazyDistance(theaterAddress: street + ", " + city + " " + state + " " + zip)

			gTheater.append((t, lazyDistance))
		}

		//	sort Movies by Rating, Title
		gMovie.sort
		{
			let lhsrating = $0.movie[KEY_RATING]! as! String
			let rhsrating = $1.movie[KEY_RATING]! as! String

			if lhsrating != rhsrating { return lhsrating > rhsrating }
			else { return ($0.movie[KEY_TITLE]! as! String) < ($1.movie[KEY_TITLE]! as! String) }
		}
		
		print("process_theaters end")
	}
	
	func rebuild_theaters(completion: @escaping (_ result: Bool)->())
	{ print("rebuild_theaters")

		print("Show Date:", get_show_date_from_day_offset(UserDefault.getDayOffset()))
		print("Postal Code:", UserDefault.getPostalCode())
		
		DataAccess().getTheaters(get_show_date_from_day_offset(UserDefault.getDayOffset()),
									postalcode: UserDefault.getPostalCode())
		{
			(theaterArray, error) in

			if (error != nil) { self.handleNetworkError(error: error); completion(false); return }

			let theaters = theaterArray as! [[String : AnyObject]]

			if theaters.count == 0 { self.handleNoDataAvailable(error: error); completion(false); return }

			self.process_theaters(theaters)

			completion(true)
		}
	}

	private func rebuild_all(completion: @escaping (_ result: Bool)->())
	{ print("rebuild_all")

		print("Show Date:", get_show_date_from_day_offset(UserDefault.getDayOffset()))
		print("Postal Code:", UserDefault.getPostalCode())

		let da = DataAccess()

		da.getIndex()
		{
			(index, error) in

			if (error != nil) { self.handleNetworkError(error: error); completion(false); return }

			gXMLIndex = index as! [[String : AnyObject]]
			
			da.getTheaters(get_show_date_from_day_offset(UserDefault.getDayOffset()), postalcode: UserDefault.getPostalCode())
			{
				(theaterArray, error) in

				if (error != nil) { self.handleNetworkError(error: error); completion(false); return }
	
				let theaters = theaterArray as! [[String : AnyObject]]

				if theaters.count == 0 { self.handleNoDataAvailable(error: error); completion(false); return }
	
				self.process_theaters(theaters)

				completion(true)
			}
		}
	}
}

extension AppDelegate : UIApplicationDelegate
{
	func applicationWillResignActive(_ application: UIApplication)
	{ print("applicationWillResignActive")
		//	Sent when the application is about to move from active to inactive state.
		//	This can occur for certain types of temporary interruptions (such as an
		//	incoming phone call or SMS message) or when the user quits the application
		//	and it begins the transition to the background state.
		//	Use this method to pause ongoing tasks, disable timers, and invalidate
		//	graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidBecomeActive(_ application: UIApplication)
	{ print("applicationDidBecomeActive")
		//	Restart any tasks that were paused (or not yet started) while the
		//	application was inactive. If the application was previously in
		//	the background, optionally refresh the user interface
		
		//	clear any old cached Posters
		DataAccess().trimPosterCache()
	}

	func applicationDidEnterBackground(_ application: UIApplication)
	{ print("applicationDidEnterBackground")
		//	Use this method to release shared resources, save user data, invalidate
		//	timers, and store enough application state information to restore your
		//	application to its current state in case it is terminated later.
		//	If your application supports background execution, this method is called
		//	instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication)
	{ print("applicationWillEnterForeground")
		//	Called as part of the transition from the background to the active state;
		//	here you can undo many of the changes made on entering the background.
	}

	func applicationWillTerminate(_ application: UIApplication)
	{ print("applicationWillTerminate")
		//	called when the application is about to terminate
		//	save data if appropriate. See also applicationDidEnterBackground:.
	}

	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
	{ print("willFinishLaunchingWithOptions")
		
		//	init locationManager
		_ = UserLocation.shared

		//	if UserDefaults don't exist, create them
		if UserDefaults.standard.object(forKey: UserDefault.key.LastUpdate) == nil
		{ UserDefault.setLastUpdate(Date()) }
		
		if UserDefaults.standard.object(forKey: UserDefault.key.DayOffset) == nil
		{ UserDefault.setDayOffset(0) }
		
		if UserDefaults.standard.object(forKey: UserDefault.key.PostalCode) == nil
		{ UserDefault.setPostalCode("95014") }

		//	print(Array(UserDefaults.standard.dictionaryRepresentation()))
		
		return (true)
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
	{ print("didFinishLaunchingWithOptions")
	
		rebuild_all()
		{
			(result) -> () in

			self.window = UIWindow(frame: UIScreen.main.bounds)
			let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

			let mvc: ViewControllerMarquee = mainStoryboard.instantiateViewController(withIdentifier: "MarqueeStoryboard") as! ViewControllerMarquee
			self.window?.rootViewController = mvc
			self.window?.makeKeyAndVisible()

			//	print(result)
		}

		return (true)
	}
}
