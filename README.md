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

#### March 25, 2018
Update embedded data.

#### April 8, 2018
Commit 281c8d0 should be fairly stable. Seque unwinds back to ViewControllerMarquee will now always do the right thing. Redesign to use Sections in ViewControllerBoxOffice is essentially done but overall color now looks too dark. But there is more compelling stuff to work on right now.

![marquee](https://user-images.githubusercontent.com/4106530/38840080-a9654200-4192-11e8-9dfb-e36da92d8c30.png "Marquee") | ![theaters_for_movie](https://user-images.githubusercontent.com/4106530/38840087-bbf6731c-4192-11e8-9838-5ffcc53475cd.png "Theaters for Movie") |
:-------------------------:|:-------------------------:
*Marquee* | *Theaters for Movie* |
![movies_for_theater](https://user-images.githubusercontent.com/4106530/38840096-c68a6248-4192-11e8-96dc-11ad3edf7820.png "Movies for Theater") | ![trailers](https://user-images.githubusercontent.com/4106530/38840106-d3503be2-4192-11e8-82bf-89d2556140ae.png "View Trailers") |
*Movies for Theater* | *View Trailer* |
![itunes](https://user-images.githubusercontent.com/4106530/38840114-de6d465a-4192-11e8-9974-b5caa9d1568b.png "iTunes Preview") | ![driving_directions](https://user-images.githubusercontent.com/4106530/38840125-e8c85018-4192-11e8-8620-c3a5eec2e60a.png "Driving Directions") |
*iTunes Preview* | *Driving Directions*
