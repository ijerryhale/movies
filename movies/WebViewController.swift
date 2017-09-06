
import UIKit

class WebViewController: UIViewController
{
    @IBOutlet weak var webView: UIWebView!

	override func viewWillDisappear(_ animated: Bool)
	{ super.viewWillDisappear(animated); print("WebViewController viewWillDisappear ") }

    override func viewDidLoad()
	{ super.viewDidLoad(); print("WebViewController viewDidLoad ")

		//	open iTunes page for this Movie
		let index = gState[KEY_CO_INDEX] as! Int
        let url = URL(string: gMovie[index].movie[KEY_ITUNES_URL] as! String)
        if let unwrappedURL = url {
            
            let request = URLRequest(url: unwrappedURL)
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if error == nil { self.webView.loadRequest(request)}
				else { print("ERROR: \(error)") }
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
