//
//  PreferenceViewController.swift
//  Movies
//
//  Created by Jerry Hale on 9/8/16.
//  Copyright © 2017 jhale. All rights reserved.
//

//	8/15/17	-	this is just a scratch pad of some
//	stuff right now, and some of this is implemented
//	in another version of this app

import UIKit

let DAY_OFFSET = 0;

//open class CodeInputView: UIView, UIKeyInput {
//    open var delegate: CodeInputViewDelegate?
//    fileprivate var nextTag = 1
//
//    // MARK: - UIResponder
//
//    open override var canBecomeFirstResponder : Bool {
//        return true
//    }
//
//    // MARK: - UIView
//
//    public override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        // Add four digitLabels
//        var frame = CGRect(x: 0, y: 0, width: 10, height: 11)
//        for index in 1...4 {
//            let digitLabel = UILabel(frame: frame)
//			digitLabel.textColor = UIColor.black
//            digitLabel.font = UIFont.systemFont(ofSize: 10)
//            digitLabel.tag = index
//            digitLabel.text = "*"
//            digitLabel.textAlignment = .center
//            addSubview(digitLabel)
//            frame.origin.x += 10 + 5
//        }
//    }
//    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") } // NSCoding
//
//    // MARK: - UIKeyInput
//
//    public var hasText : Bool {
//        return nextTag > 1 ? true : false
//    }
//
//    open func insertText(_ text: String) {
//        if nextTag < 5 {
//            (viewWithTag(nextTag)! as! UILabel).text = text
//            nextTag += 1
//
//            if nextTag == 5 {
//                var code = ""
//                for index in 1..<nextTag {
//                    code += (viewWithTag(index)! as! UILabel).text!
//                }
//                delegate?.codeInputView(self, didFinishWithCode: code)
//            }
//        }
//    }
//
//    open func deleteBackward() {
//        if nextTag > 1 {
//            nextTag -= 1
//            (viewWithTag(nextTag)! as! UILabel).text = "–"
//        }
//    }
//
//    open func clear() {
//        while nextTag > 1 {
//            deleteBackward()
//        }
//    }
//
//    // MARK: - UITextInputTraits
//
//    //	open var keyboardType: UIKeyboardType { get { return .numberPad } set { } }
//}
//
//public protocol CodeInputViewDelegate {
//    func codeInputView(_ codeInputView: CodeInputView, didFinishWithCode code: String)
//}

//	CodeInputViewDelegate

class PreferenceViewController: UIViewController {

    @IBOutlet weak var locationLabel: UILabel!

    //	@IBOutlet weak var geocodeButton: UIButton!
	@IBOutlet weak var showdateBtn: UIButton!
	
	//	var codeinputview: CodeInputView!

	var callingViewControler:UIViewController!

//   func codeInputView(_ codeInputView: CodeInputView, didFinishWithCode code: String) {
//        let title = code == "1234" ? "Correct!" : "Wrong!"
//        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
//            (self.view.viewWithTag(17)! as! CodeInputView).clear()
//        })
//        present(alert, animated: true, completion: nil)
//    }
	
	func notif_showdate(notification: Notification) -> Void
	{
		print("notif_showdate")
		
		guard let userInfo = notification.userInfo,
			  let offset  = userInfo[KEY_DAY_OFFSET] as? Int else
		{
		  print("No userInfo found in notification")
		  return
		}
		//	print(showtimeIndex)
		let today = Date()
		let day = Calendar.current.date(byAdding: .day, value: offset + DAY_OFFSET, to: today)

		switch offset
		{
			case 0:
				showdateBtn.setTitle("Today", for: .normal)
			case 1:
				showdateBtn.setTitle("Tommorrow", for: .normal)
			default:
				let _df = DateFormatter()
				_df.dateFormat = "EEE, MMM dd"
				_df.locale = Locale(identifier: "en_US")

				self.showdateBtn.setTitle(_df.string(from: day!), for: .normal)
		}
		gDayOffset = offset
	}
	
	@IBAction func tapDoneBtn(sender: UIButton)
	{
		if callingViewControler is BoxOfficeViewController
		{
			//gState[KEY_CO_INDEX] = 0

			let boc = callingViewControler as! BoxOfficeViewController
			switch gDayOffset
			{
				case 0:
					boc.showdate.text = "Today"
				case 1:
					boc.showdate.text = "Tommorrow"
				default:
					let day = Calendar.current.date(byAdding: .day, value: gDayOffset + DAY_OFFSET, to: Date())
					let _df = DateFormatter()
					_df.dateFormat = "EEE, MMM dd"
					_df.locale = Locale(identifier: "en_US")

					boc.showdate.text = _df.string(from: day!)
			}

			self.performSegue(withIdentifier: S2_BOX_OFFICE, sender: self)
		}
		else
		{
			self.performSegue(withIdentifier: S2_MARQUEE, sender: self)
		}
	}
	//	let location = CLLocation(latitude: 34.243896, longitude: -116.911422)
	@IBAction func geocode(_ sender: UIButton)
	{
		let geocode = Geocode(withDelegate: UIApplication.shared.delegate as! AppDelegate)
	
		geocode.geocodePostalCode(postalcode: "92315")
		//	let postalcode = geocode.reverseGeocodePostalCode(latitude: 34.243896, longitude: -116.91142)


		//	guard let latAsString = latitudeTextField.text, let lat = Double(latAsString) else { return }
		//	guard let lngAsString = longitudeTextField.text, let lng = Double(lngAsString) else { return }

		//	34.243896
		
		// Create Location
//		let location = CLLocation(latitude: 34.243896, longitude: -116.911422)

		// Geocode Location
//		geocoder.reverseGeocodeLocation(location)
//		{
//			(placemarks, error) in
				//	process response
			
				// Update View
				//  geocodeButton.isHidden = false
				//  activityIndicatorView.stopAnimating()

//				if let error = error
//				{
//					print("Unable to Reverse Geocode Location (\(error))")
//					self.locationLabel.text = "Unable to Find Address for Location"
//				}
//				else
//				{
//					if let placemarks = placemarks, let placemark = placemarks.first
//					{
//						//	print(placemark)
//						self.locationLabel.text = placemark.postalCode
//					}
//					else
//					{
//						self.locationLabel.text = "No Matching Addresses Found"
//					}
//				}
//		}

		//	Update View
		//	geocodeButton.isHidden = true
		//	activityIndica¥torView.startAnimating()
	}

	//	MARK: UIViewController overrides
	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("PreferenceViewController viewWillDisappear ") }

    override func viewDidLoad()
	{ super.viewDidLoad(); print("PreferenceViewController viewDidLoad ")
		
		let day = Calendar.current.date(byAdding: .day, value: gDayOffset + DAY_OFFSET, to: Date())

		switch gDayOffset
		{
			case 0:
				showdateBtn.setTitle("Today", for: .normal)
			case 1:
				showdateBtn.setTitle("Tommorrow", for: .normal)
			default:
				let _df = DateFormatter()
				_df.dateFormat = "EEE, MMM dd"
				_df.locale = Locale(identifier: "en_US")

				showdateBtn.setTitle(_df.string(from: day!), for: .normal)
		}

//		codeinputview = CodeInputView(frame: CGRect(x: 0, y: 200, width: 200, height: 80))
//		codeinputview.delegate = self
//		codeinputview.tag = 17
//		//	codeinputview.becomeFirstResponder()
//		
//		self.view.addSubview(codeinputview)
		
		NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:NOTIF_SHOWDATE),
               object:nil, queue:nil,
               using:notif_showdate)
    }
}
