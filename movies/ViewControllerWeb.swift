//
//  ViewControllerWeb.swift
//  movies
//
//  Created by Jerry Hale on 3/30/17
//  Copyright © 2018-2020 jhale. All rights reserved
//

import UIKit

class ViewControllerWeb: UIViewController
{
    @IBOutlet weak var webView: UIWebView!

	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("ViewControllerWeb viewWillDisappear ") }

    override func viewDidLoad()
	{ super.viewDidLoad(); print("ViewControllerWeb viewDidLoad ")

		//	open iTunes page for this Movie
        let url = URL(string: gMovie[gCurrMovie].movie[KEY_ITUNES_URL] as! String)
        if let unwrappedURL = url {
            
            let request = URLRequest(url: unwrappedURL)
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { (data, response, error) in

                if error == nil
                {
					DispatchQueue.main.async(execute:
					{
						self.webView.loadRequest(request)
					})
				}
				else { print("ERROR: \(String(describing: error))") }
            }

            task.resume()
		}
    }

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
