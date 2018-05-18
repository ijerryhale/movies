## movies
Display a list of Theaters and Movies for given Location and Day.

* movies contains an example of an embedded UIView which hosts a ContainerController which in turn manages multiple UIViewControllers and Segues.

* movies demonstrates how to set an initial UITableCell image and then replace that image with a lazily loaded image. movies will also lazy load the computed distance from the Current Location to a given Theater.

* This version of movies returns a static set of data for the Cupertino Postal Code.

#### May 12, 2018

Moved all of the embedded data to cormya and got rid of embedded target and embedded data in the XCode project. While cormya is slow right now this makes a lot of stuff a lot simpler than it was.

## Requirements

- XCode 9+
- iOS 10+
- Swift 4+


![marquee](https://user-images.githubusercontent.com/4106530/38840548-15881b40-4195-11e8-80cc-316c271e2bce.png "Marquee") | ![theaters_for_movie](https://user-images.githubusercontent.com/4106530/38840558-2215f2f6-4195-11e8-9b26-9455f008a901.png "Theaters for Movie") |
:-------------------------:|:-------------------------:
*Marquee* | *Theaters for Movie* |
![movies_for_theater](https://user-images.githubusercontent.com/4106530/38840567-2d42cbfe-4195-11e8-82e9-2c83602d6871.png "Movies for Theater") | ![trailers](https://user-images.githubusercontent.com/4106530/38840571-3b175eac-4195-11e8-8dfa-fdd67e3d224d.png "View Trailers") |
*Movies for Theater* | *View Trailer* |
![itunes](https://user-images.githubusercontent.com/4106530/38840582-4992d95c-4195-11e8-8e31-024383229cb8.png "iTunes Preview") | ![driving_directions](https://user-images.githubusercontent.com/4106530/38840596-5af3f208-4195-11e8-85a3-2f5de4b2534d.png "Driving Directions") |
*iTunes Preview* | *Driving Directions*

