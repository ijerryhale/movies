//
//  UserLocation.swift
//  movies
//
//  Created by Jerry Hale on 10/15/17.
//  Copyright © 2017 jhale. All rights reserved.
//

import CoreLocation

class UserLocation : NSObject
{
	static let shared = UserLocation()
	
	var waypoint = CLLocation(latitude: 0, longitude: 0)
	var locationManager = CLLocationManager()

	override init()
	{ super.init()
		
		locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
		locationManager.startUpdatingLocation()
    }

	deinit { locationManager.stopUpdatingLocation() }
}

extension UserLocation : CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
	{
        if status == .authorizedWhenInUse { locationManager.requestLocation() }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
	{	/* print("locationManager didUpdateLocations") */

//		if UserDefault.usingCurrentLocation()
//		{
//			//	let longitude :CLLocationDegrees = -122.0312186
//			//	let latitude :CLLocationDegrees = 37.33233141
//			//	let destination = CLLocation(latitude: latitude, longitude: longitude)
//
//			let distanceInMeters = waypoint.distance(from: self.locationManager.location!)
//			let distanceInMiles = distanceInMeters * 0.000621371
//			//	print(String(format: "%.2f miles", distanceInMiles))
//
//			if distanceInMeters * 0.000621371 > 2
//			{
//				waypoint = self.locationManager.location!
//
//				print(waypoint)
//				print(String(format: "waypoint %.2f miles", distanceInMiles))
//
//				CLGeocoder().reverseGeocodeLocation(waypoint, completionHandler:
//				{
//					(placemarks, error) -> Void in
//
//					if error != nil
//					{
//						print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
//						return
//					}
//
//					if placemarks!.count > 0
//					{
//						guard let postalcode = placemarks![0].postalCode else
//						{
//							print("no postalCode!!!")
//							return
//						}
//
//						let oldPostalCode = UserDefault.postalCode()
//
//						if oldPostalCode != postalcode
//						{
//							UserDefault.setPostalCode(postalcode)
//							print("UserDefault.setPostalCode, postalcode: %s oldPostalCode: %s", postalcode, oldPostalCode)
//
//							NotificationCenter.default.post(name:Notification.Name(rawValue:NOTIF_NEW_CURR_POSTAL_CODE),
//		                                object: nil,
//		                                userInfo: nil)
//						}
//					}
//					else { print("Problem with the data received from geocoder") }
//				})
//
//			}
//		}
	}
	
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
	{
        print("error:: \(error)")
    }
}
