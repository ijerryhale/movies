# movies
iOS - movies displays a list of Theaters and Movies for given Location and Day.

movies contains an example of an embedded UIView which hosts a ContainerController which in turn manages multiple UIViewControllers and Segues.

movies demonstrates how to set an initial UITableCell image and then replace that image with a lazily loaded image. movies will also lazy load the computed distance from the Current Location to a given Theater.

The movies XCode project contains a 'movies_embedded' target which will load an embedded set of Theater data.

## Requirements

- XCode 9+
- iOS 10+
- Swift 4+


#### Sep 24, 2017
Update to XCode 9/Swift 4. Bug fixes

#### Nov 3, 2017
Add Core Data layer to cache requests.

#### Nov 8, 2017
Start wiring in Settings stuff so we can start to code for dynamism in what is requested. Update embedded data -- data was getting old and this new set of embedded data looks a lot more like what would be returned on a request. New embedded data is from Cupertino Area Code too so the Map Stuff matches up better working in the Simulator.

#### March 23, 2018
Redesign UITableView to use Sections. Still a bit of work to do here but a lot of it is done.

![marquee](https://user-images.githubusercontent.com/4106530/30836916-2c8de1ea-a216-11e7-86b3-c3bf988b12f3.png "Marquee") | ![theaters_for_movie](https://user-images.githubusercontent.com/4106530/30836918-2fce430e-a216-11e7-9f65-689fcea14b51.png "Theaters for Movie") |
:-------------------------:|:-------------------------:
*Marquee* | *Theaters for Movie* |
![movies_for_theater](https://user-images.githubusercontent.com/4106530/30836920-3237d1aa-a216-11e7-9d54-762cf4a130b1.png "Movies for Theater") | ![trailers](https://user-images.githubusercontent.com/4106530/30836924-34acd7b4-a216-11e7-89ba-142837ad3cce.png "View Trailers") |
*Movies for Theater* | *View Trailer* |
![itunes](https://user-images.githubusercontent.com/4106530/31039370-0978f64e-a532-11e7-9f9e-8994d4b0b0af.png "iTunes Preview") | ![driving_directions](https://user-images.githubusercontent.com/4106530/30836931-3f476220-a216-11e7-99c9-661485056d6d.png "Driving Directions") |
*iTunes Preview* | *Driving Directions*
