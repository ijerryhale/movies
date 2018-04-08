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

![marquee](https://user-images.githubusercontent.com/4106530/37880006-a4c080a6-3036-11e8-8692-86eba4b35286.png "Marquee") | ![theaters_for_movie](https://user-images.githubusercontent.com/4106530/37880008-b1ddb042-3036-11e8-9c9a-0dc0f987d60e.png "Theaters for Movie") |
:-------------------------:|:-------------------------:
*Marquee* | *Theaters for Movie* |
![movies_for_theater](https://user-images.githubusercontent.com/4106530/37880014-c06d644a-3036-11e8-8490-efdafa8c71af.png "Movies for Theater") | ![trailers](https://user-images.githubusercontent.com/4106530/37880023-d229479e-3036-11e8-80cc-8b8fe4b611c3.png "View Trailers") |
*Movies for Theater* | *View Trailer* |
![itunes](https://user-images.githubusercontent.com/4106530/37880030-e414e12a-3036-11e8-8926-f8421313b207.png "iTunes Preview") | ![driving_directions](https://user-images.githubusercontent.com/4106530/37880037-f2337866-3036-11e8-9945-16327237f8a9.png "Driving Directions") |
*iTunes Preview* | *Driving Directions*
