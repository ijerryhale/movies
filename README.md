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

#### April 16, 2018
Commit 2c4e409 should be stable. Update Marquee on Show Date or Postal Code change.

![marquee](https://user-images.githubusercontent.com/4106530/38840548-15881b40-4195-11e8-80cc-316c271e2bce.png "Marquee") | ![theaters_for_movie](https://user-images.githubusercontent.com/4106530/38840558-2215f2f6-4195-11e8-9b26-9455f008a901.png "Theaters for Movie") |
:-------------------------:|:-------------------------:
*Marquee* | *Theaters for Movie* |
![movies_for_theater](https://user-images.githubusercontent.com/4106530/38840567-2d42cbfe-4195-11e8-82e9-2c83602d6871.png "Movies for Theater") | ![trailers](https://user-images.githubusercontent.com/4106530/38840571-3b175eac-4195-11e8-8dfa-fdd67e3d224d.png "View Trailers") |
*Movies for Theater* | *View Trailer* |
![itunes](https://user-images.githubusercontent.com/4106530/38840582-4992d95c-4195-11e8-8e31-024383229cb8.png "iTunes Preview") | ![driving_directions](https://user-images.githubusercontent.com/4106530/38840596-5af3f208-4195-11e8-85a3-2f5de4b2534d.png "Driving Directions") |
*iTunes Preview* | *Driving Directions*
