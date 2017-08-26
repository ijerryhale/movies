//
//  TrailerController.swift
//  Movies
//
//  Created by Jerry Hale on 3/30/17.
//  Copyright © 2017 jhale. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

//	simple `UIView` subclass that is backed by an `AVPlayerLayer` layer.
class PlayerView: UIView
{
    var player: AVPlayer?
	{
        get { return playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    var playerLayer: AVPlayerLayer { return layer as! AVPlayerLayer }
    override class var layerClass: AnyClass { return AVPlayerLayer.self }
}
/*
	KVO context used to differentiate KVO callbacks for this class versus other
	classes in its class hierarchy.
*/
private var playerViewControllerKVOContext = 0

class TrailerController: UIViewController
{
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var playerView: PlayerView!
	@IBOutlet weak var slider: UISlider!
	
    static let assetKeysRequiredToPlay = [ "playable", "hasProtectedContent" ]

	let player = AVPlayer()
	var timeObserverToken: Any?
	
	var currentTime: Double
	{
        get { return CMTimeGetSeconds(player.currentTime()) }
        
        set {
            let newTime = CMTimeMakeWithSeconds(newValue, 1)
            player.seek(to: newTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        }
    }

	var duration: Double
	{
        guard let currentItem = player.currentItem else { return 0.0 }

        return CMTimeGetSeconds(currentItem.duration)
	}

	var rate: Float
	{
		get { return player.rate }
		set { player.rate = newValue }
	}

    var asset: AVURLAsset?
	{
        didSet {
            guard let newAsset = asset else { return }

            asynchronouslyLoadURLAsset(newAsset)
        }
    }
	
    @IBAction func sliderDidChange(_ sender: UISlider) {
        currentTime = Double(sender.value)
    }

	private var playerLayer: AVPlayerLayer? { return playerView.playerLayer }
	
	/*
	A formatter for individual date components used to provide an appropriate
	value for the `startTimeLabel` and `durationLabel`.
	*/
//	let timeRemainingFormatter: DateComponentsFormatter = {
//		let formatter = DateComponentsFormatter()
//		formatter.zeroFormattingBehavior = .pad
//		formatter.allowedUnits = [.minute, .second]
//		
//		return formatter
//	}()

    /*
        A token obtained from calling `player`'s `addPeriodicTimeObserverForInterval(_:queue:usingBlock:)`
        method.
    */
	//	private var timeObserverToken: Any?

	private var playerItem: AVPlayerItem? = nil {
        didSet {
            /*
                If needed, configure player item here before associating it with a player.
                (example: adding outputs, setting text style rules, selecting media options)
            */
            player.replaceCurrentItem(with: self.playerItem)
        }
	}
    
    // MARK: - Asset Loading

    func asynchronouslyLoadURLAsset(_ newAsset: AVURLAsset)
	{
        /*
            Using AVAsset now runs the risk of blocking the current thread (the 
            main UI thread) whilst I/O happens to populate the properties. It's
            prudent to defer our work until the properties we need have been loaded.
        */
        newAsset.loadValuesAsynchronously(forKeys: TrailerController.assetKeysRequiredToPlay)
		{
            /*
                The asset invokes its completion handler on an arbitrary queue. 
                To avoid multiple threads using our internal state at the same time 
                we'll elect to use the main thread at all times, let's dispatch
                our handler to the main queue.
            */
            DispatchQueue.main.async
			{
                /*
                    `self.asset` has already changed! No point continuing because
                    another `newAsset` will come along in a moment.
                */
                guard newAsset == self.asset else { return }

                /*
                    Test whether the values of each of the keys we need have been
                    successfully loaded.
                */
                for key in TrailerController.assetKeysRequiredToPlay
				{
                    var error: NSError?
                    
                    if newAsset.statusOfValue(forKey: key, error: &error) == .failed
					{
                        let stringFormat = NSLocalizedString("error.asset_key_%@_failed.description", comment: "Can't use this AVAsset because one of it's keys failed to load")

                        let message = String.localizedStringWithFormat(stringFormat, key)
                        
                        self.handleErrorWithMessage(message, error: error)
                        
                        return
                    }
                }
                // We can't play this asset.
                if !newAsset.isPlayable || newAsset.hasProtectedContent
				{
                    let message = NSLocalizedString("error.asset_not_playable.description", comment: "Can't use this AVAsset because it isn't playable or has protected content")
                    
                    self.handleErrorWithMessage(message)
                    
                    return
                }
                /*
                    We can play this asset. Create a new `AVPlayerItem` and make
                    it our player's current item.
                */
                self.playerItem = AVPlayerItem(asset: newAsset)
            }
        }
    }

	@IBAction func playPauseBtnPressed(_ sender: UIButton)
	{
		if player.rate != 1.0
		{
            // Not playing forward, so play.
 			if currentTime == duration
			{
                // At end, so got back to begining.
				currentTime = 0.0
			}

			player.play()
		}
        else { player.pause() }
	}

	@IBAction func returnBtnPressed(_ sender: UIButton)
	{
		player.pause()

		//	disable Prefs Button
		(parent?.parent as! BoxOfficeController).enablePrefsBtn()
		//	pop TrailerController push MovieDetailController
		(parent as! ContainerController).trailerSegueUnwind()
	}

    // MARK: - KVO Observation

    // Update our UI when player or `player.currentItem` changes.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?)
	{
        // Make sure the this KVO callback was intended for this view controller.
        guard context == &playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

		if keyPath == #keyPath(TrailerController.player.currentItem.duration)
		{
            // Update `timeSlider` and enable / disable controls when `duration` > 0.0.

            /*
                Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when 
                `player.currentItem` is nil.
            */
            let newDuration: CMTime
            if let newDurationAsValue = change?[NSKeyValueChangeKey.newKey] as? NSValue {
                newDuration = newDurationAsValue.timeValue
            }
            else {
                newDuration = kCMTimeZero
            }

            let hasValidDuration = newDuration.isNumeric && newDuration.value != 0
            let newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0
            let currentTime = hasValidDuration ? Float(CMTimeGetSeconds(player.currentTime())) : 0.0
            
            slider.maximumValue = Float(newDurationSeconds)

            slider.value = currentTime
            
            playPauseBtn.isEnabled = hasValidDuration
            
			slider.isEnabled = hasValidDuration
		}
        else if keyPath == #keyPath(TrailerController.player.rate)
		{
            let newRate = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).doubleValue
            let buttonImageName = newRate == 1.0 ? "pause" : "play"
            let buttonImage = UIImage(named: buttonImageName)

            playPauseBtn.setImage(buttonImage, for: UIControlState())
        }
        else if keyPath == #keyPath(TrailerController.player.currentItem.status)
		{
            // Display an error if status becomes `.Failed`.

            /*
                Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
                `player.currentItem` is nil.
            */
            let newStatus: AVPlayerItemStatus

            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber
			{
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
            }
            else
			{
                newStatus = .unknown
            }
            
            if newStatus == .failed
			{
                handleErrorWithMessage(player.currentItem?.error?.localizedDescription, error:player.currentItem?.error)
            }
        }
    }

    // Trigger KVO for anyone observing our properties affected by player and player.currentItem
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String>
	{
        let affectedKeyPathsMappingByKey: [String: Set<String>] = [
            "duration":     [#keyPath(TrailerController.player.currentItem.duration)],
            "rate":         [#keyPath(TrailerController.player.rate)]
        ]
        
        return affectedKeyPathsMappingByKey[key] ?? super.keyPathsForValuesAffectingValue(forKey: key)
	}

	func handleErrorWithMessage(_ message: String?, error: Error? = nil)
	{
        NSLog("Error occured with message: \(message), error: \(error).")
    
        let alertTitle = NSLocalizedString("alert.error.title", comment: "Alert title for errors")
        let defaultAlertMessage = NSLocalizedString("error.default.description", comment: "Default error message when no NSError provided")

        let alert = UIAlertController(title: alertTitle, message: message == nil ? defaultAlertMessage : message, preferredStyle: UIAlertControllerStyle.alert)

        let alertActionTitle = NSLocalizedString("alert.error.actions.OK", comment: "OK on error alert")

        let alertAction = UIAlertAction(title: alertActionTitle, style: .default, handler: nil)
        
        alert.addAction(alertAction)

        present(alert, animated: true, completion: nil)
	}

	//	MARK: UIViewController overrides
    override func viewWillDisappear(_ animated: Bool)
	{
		super.viewWillDisappear(animated); print("TrailerController viewWillDisappear ")
		
		removeObserver(self, forKeyPath: #keyPath(TrailerController.player.currentItem.duration), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(TrailerController.player.rate), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(TrailerController.player.currentItem.status), context: &playerViewControllerKVOContext)
		removeObserver(self, forKeyPath: #keyPath(TrailerController.player.currentItem), context: &playerViewControllerKVOContext)

		if let timeObserverToken = timeObserverToken
		{
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
	}

    override func viewWillAppear(_ animated: Bool)
	{
        super.viewWillAppear(animated)
        
		addObserver(self, forKeyPath: #keyPath(TrailerController.player.currentItem.duration), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(TrailerController.player.rate), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(TrailerController.player.currentItem.status), options: [.new, .initial], context: &playerViewControllerKVOContext)
		addObserver(self, forKeyPath: #keyPath(TrailerController.player.currentItem), options: [.new, .initial], context: &playerViewControllerKVOContext)
		
        playerView.playerLayer.player = player

		//	make sure we don't have a strong reference cycle by only capturing self as weak.
        let interval = CMTimeMake(1, 1)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main)
		{ [unowned self] time in
            let timeElapsed = Float(CMTimeGetSeconds(time))
            
            self.slider.value = Float(timeElapsed)
        }

		let movie = gMovie[gState[KEY_CO_INDEX] as! Int]
		//	don't have to check info here as we never
		//	get here if there isn't a good info
		let info = gIndex.filter({ $0[KEY_ID] as? String == movie[KEY_FILM_ID] as? String }).first

		let previews = info?[KEY_PREVIEWS] as! [String : AnyObject]
		let preview = previews[KEY_PREVIEW] as! [String : AnyObject]
		
		var trailerURL = preview[KEY_TEXT] as! String
		
		//	have to remove BASE_URL from path
		#if HAS_WEB_SERVICE
				//	have to remove BASE_URL from path
			var baseURL = DataAccess.url_BASE()
			let range = baseURL?.range(of:"s")
			if let startLocation = range?.lowerBound,
			let endLocation = range?.upperBound
			{
				baseURL?.replaceSubrange(startLocation ..< endLocation, with: "")
				baseURL = baseURL! + "/"
			}

			let trailerstring = trailerURL.replacingOccurrences(of: baseURL!, with: "")
			trailerURL = trailerstring as String
		#endif

		let url = DataAccess.get_URL(trailerURL)
		asset = AVURLAsset(url: url!, options: nil)

		player.play()
    }

	override func viewDidLoad()
	{
		super.viewDidLoad(); print("TrailerController viewDidLoad ")
		
		slider.setThumbImage(UIImage(named: "scrubthumb.png"), for: .normal)
	}
}
