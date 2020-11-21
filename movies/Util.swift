//
//  Util.swift
//  movies
//
//  Created by Jerry Hale on 4/11/17
//  Copyright © 2018-2020 jhale. All rights reserved
//

import CoreLocation
import UIKit

//	MARK: EmptySegue
class EmptySegue: UIStoryboardSegue
{
    override func perform()
	{

	}
}

//	MARK: CustomSegue
class CustomSegue: UIStoryboardSegue
{
    override func perform()
	{
		UIView.animate(withDuration:0.6, animations:
		{
			self.source.view.alpha = 0.3
            self.destination.view.alpha = 1.0

            }, completion: { finished in
				self.source.present(self.destination, animated: false, completion: nil)
        })
    }
}

//	MARK: CustomUnwindSegue
class CustomUnwindSegue: UIStoryboardSegue
{
    override func perform()
	{
        UIView.animate(withDuration: 0.6, animations:
		{
			self.source.view.alpha = 0.3
			self.destination.view.alpha = 1.0

            }, completion: { finished in
                self.source.dismiss(animated: false, completion: nil)
        })
    }
}


//	typedef void (^Callback)(true isSuccess, String object)
protocol GeocodeDelegate {
    func geocodeDidSucceed(placemark: CLPlacemark?, error: Error?)
    func geocodeDidFail(placemark: CLPlacemark?, error: Error?)
}
class Geocode {

	let geocoder = CLGeocoder()
	var delegate: GeocodeDelegate
	
	init(withDelegate delegate: GeocodeDelegate) { self.delegate = delegate }
	
	func geocodePostalCode(postalcode: String)
	{
        //	create address string
        //	let address = "\(country), \(city), \(street), \(state), \(postalcode)"
		let address = "\(postalcode)"

        //	geocode address string
        geocoder.geocodeAddressString(address)
		{ (placemarks, error) in
            // process response
			if let error = error
			{
				self.delegate.geocodeDidSucceed(placemark: nil, error: error)
				print("Unable to Forward Geocode Address (\(error))")
			}
			else
			{
				var location: CLLocation?
				
				if let placemarks = placemarks, placemarks.count > 0
				{
					location = placemarks.first?.location
					
					if let location = location
					{
						let coordinate = location.coordinate
						print("\(coordinate.latitude), \(coordinate.longitude)")
						self.delegate.geocodeDidSucceed(placemark: placemarks.first, error: error)
					}
					else
					{
						self.delegate.geocodeDidSucceed(placemark: nil, error: error)
					}
				}
			}
        }
    }

	//	let location = CLLocation(latitude: 34.243896, longitude: -116.911422)
	func reverseGeocodePostalCode(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
	{
		//	34.243896
		//	create Location
		let location = CLLocation(latitude: latitude, longitude: longitude)

		//	geocode location
		geocoder.reverseGeocodeLocation(location)
		{
			//	process response
			(placemarks, error) in
			//  geocodeButton.isHidden = false
			//  activityIndicatorView.stopAnimating()

			if let error = error { print("Unable to Reverse Geocode Location (\(error))") }
			else
			{
				if let placemarks = placemarks, let placemark = placemarks.first
				{
					//	postalcode = placemark.postalCode!
					self.delegate.geocodeDidSucceed(placemark: placemark, error: error)
				}
				else
				{
					self.delegate.geocodeDidFail(placemark: nil, error: error!)
					print("No Matching Addresses Found")
				}
			}
		}
	}
}

func createGenericPoster(_ title: String) -> UIImage
{
	var image = UIImage(named: "filmclip.png")

	UIGraphicsBeginImageContext((image?.size)!)
	
	image?.draw(in: CGRect(x: 0, y: 0, width: (image?.size.width)!, height: (image?.size.height)!))

	let titleString =
				NSMutableAttributedString(string: title,
			attributes: [.font:UIFont(name: "Helvetica Neue", size: 12)!])

	let red = CGFloat((0x333333 & 0xFF0000) >> 16) / 255.0
	let green = CGFloat((0x333333 & 0x00FF00) >> 8) / 255.0
	let blue = CGFloat(0x333333 & 0x00FF) / 255.0

	titleString.addAttribute(
			.foregroundColor,
				value: UIColor(red: red,
								green: green,
								blue: blue,
								alpha: 1.0),
				range: NSRange(location:0, length:titleString.length))

	let paraStyle = NSMutableParagraphStyle()
	paraStyle.alignment = .center

	titleString.addAttribute(.paragraphStyle, value:paraStyle, range:NSRange(location:0, length:titleString.length))

	titleString.draw(in: CGRect(x: 24, y: 50, width: (image?.size.width)! - 48, height: (image?.size.height)!))

	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext()

	return (image!)
}

func get_show_date() -> String
{
	let dayoffset = UserDefault.getDayOffset()

	switch dayoffset
	{
		case 0:
		return ("Today ")
		case 1:
		return ("Tommorrow ")
		default:
			let today = Date()
			let day = Calendar.current.date(byAdding: .day, value: dayoffset, to: today)

			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "EEE, MMM dd"
			dateFormatter.locale = Locale(identifier: "en_US")
		return (dateFormatter.string(from: day!) + " ")
	}
}

func get_show_date_from_day_offset(_ dayoffset: Int) -> String
{
	let day = Calendar.current.date(byAdding: .day, value: dayoffset, to: Date())
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "yyyy-MM-dd"
	dateFormatter.locale = Locale(identifier: "en_US")
	//print(df.string(from: day!))

	return (dateFormatter.string(from: day!))
}
