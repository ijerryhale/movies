//
//  ViewControllerMap.swift
//  movies
//
//  Created by Jerry Hale on 3/30/17
//  Copyright © 2018-2020 jhale. All rights reserved
//

import UIKit
import MapKit

//	MARK: ViewControllerMap
class ViewControllerMap: UIViewController
{
    var placemark: MKPlacemark?

    @IBOutlet weak var mapView: MKMapView!

	@objc func getDirections()
	{
        guard let placemark = placemark else { return }
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }

	override func viewWillAppear(_ animated: Bool)
	{ super.viewWillAppear(animated); print("ViewControllerMap viewWillAppear ")

		let theater = gTheater[gCurrTheater].theater

		//	let nameString = "West Wind El Rancho Drive-In"
		let nameString = theater[KEY_NAME] as? String
		
		//	let addressString = "555 El Rancho Drive, Sparks NV 89431"
		let aa = theater[KEY_ADDRESS]
		var addressString = aa?[KEY_STREET] as! String

		addressString += " "
		addressString += aa?[KEY_CITY] as! String
		addressString += ", "
		addressString += aa?[KEY_STATE] as! String

		//	print(addressString)
		let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = addressString
        request.region = mapView.region

        let search = MKLocalSearch(request: request)
		
        search.start { response, _ in
            guard let response = response else { return }
            let matchingItems: [MKMapItem] = response.mapItems
			
			let placemark = matchingItems[0].placemark
			//	print(placemark)

			let annotation = MKPointAnnotation()
			annotation.coordinate = placemark.coordinate
			annotation.title = nameString

			if let number = placemark.subThoroughfare,
				let street = placemark.thoroughfare,
				 let city = placemark.locality,
				  let state = placemark.administrativeArea,
					let zip = placemark.postalCode
				{
					annotation.subtitle = "\(number) \(street) \(city), \(state) \(zip)"
				}
			
			self.mapView.addAnnotation(annotation)
			self.placemark = placemark
			
			self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
	}

	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("ViewControllerMap viewWillDisappear ") }

    override func viewDidLoad()
	{ super.viewDidLoad(); print("ViewControllerMap viewDidLoad ")
		
		definesPresentationContext = true
		
 		mapView.delegate = self
		mapView.showsUserLocation = true
	}
}

//	MARK: MKMapViewDelegate Methods
extension ViewControllerMap : MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
	{
        guard !(annotation is MKUserLocation) else { return nil }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        pinView?.pinTintColor = UIColor.blue
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 48, height: 48)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "theater"), for: UIControl.State())
        button.addTarget(self, action: #selector(ViewControllerMap.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        return pinView
    }
}
