//
//  ShowDateViewController.swift
//  Movies
//
//  Created by Jerry Hale on 4/11/17.
//  Copyright © 2017 jhale. All rights reserved.
//

import UIKit

enum AdaptiveMode
{
    case isDefault
    case isLandscapePopover
    case isAlwaysPopover
}

class ShowDateViewController: UITableViewController, UIPopoverPresentationControllerDelegate
{
	//    @IBInspectable var popoverOniPhone:Bool = true
	//    @IBInspectable var popoverOniPhoneLandscape:Bool = false

	@objc func tapCancel(_ : UIBarButtonItem) { dismiss(animated: true, completion:nil); }

    //	popover settings, adaptive for horizontal compact trait
	
	//	MARK: UIPopoverPresentationControllerDelegate Functions
    func adaptivePresentationStyle(for controller:UIPresentationController) -> UIModalPresentationStyle
	{
        //this methods is only called by System when the screen has compact width
        
        //return .None means we still want popover when adaptive on iPhone
        //return .FullScreen means we'll get modal presetaion on iPhone
        
//        switch(popoverOniPhone, popoverOniPhoneLandscape)
//		{
//        case (true, _): // always popover on iPhone
            return .none
            
//        case (_, true): // popover only on landscape on iPhone
//            let size = controller.presentingViewController.view.frame.size
//            if(size.width>320.0){ //landscape
//                return .none
//            }else{
//                return .fullScreen
//            }
//            
//        default: // no popover on iPhone
//            return .fullScreen
//        }
	}

    func presentationController(_: UIPresentationController, viewControllerForAdaptivePresentationStyle _: UIModalPresentationStyle)
         -> UIViewController?
	{
            return UINavigationController(rootViewController: self)
    }

    //	MARK: UITableViewDelegate Functions
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 7  }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEE, MMM dd"
		dateFormatter.locale = Locale(identifier: "en_US")

		let today = Date()
		let day = Calendar.current.date(byAdding: .day, value: indexPath.row + DAY_OFFSET, to: today)

		let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		cell.textLabel?.font = UIFont.systemFont(ofSize: 11)

		switch indexPath.row
		{
			case 0:
				cell.textLabel?.text = "Today"
			case 1:
				cell.textLabel?.text = "Tommorrow"
			default:
				cell.textLabel?.text = dateFormatter.string(from: day!)
		}

		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		//	select a showdate
        let showdate = tableView.cellForRow(at: indexPath as IndexPath)!.textLabel!.text
        print("did select showdate: \(showdate ?? "unknown")")
		
		NotificationCenter.default.post(name:Notification.Name(rawValue:NOTIF_SHOWDATE),
        object: nil,
        userInfo: [KEY_DAY_OFFSET:indexPath.row])

        dismiss(animated: true, completion:nil)
    }

	//	MARK: UITableViewController overrides
	required init(coder aDecoder: NSCoder)
	{
        super.init(coder: aDecoder)!
        
        //	cancel button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(ShowDateViewController.tapCancel(_:)))
        
        //	popover settings
        modalPresentationStyle = .popover
        popoverPresentationController!.delegate = self

		self.preferredContentSize = CGSize(width:110, height:126)
	}
	//	MARK: UIViewController overrides
	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("ShowDateViewController viewWillDisappear ") }

	override func viewDidLoad()
	{ super.viewDidLoad(); print("ShowDateViewController viewDidLoad ")
	
		//	print(tableView.numberOfRows(inSection: 0) as Any)

		self.tableView.separatorStyle = .none
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
	}
}
