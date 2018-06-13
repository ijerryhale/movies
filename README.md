## movies
Display a list of Theaters and Movies for given Location and Day.

* movies contains an example of an embedded UIView which hosts a ContainerController which in turn manages multiple UIViewControllers and Segues.

* movies demonstrates how to set an initial UITableCell image and then replace that image with a lazily loaded image. movies will also lazy load the computed distance from the Current Location to a given Theater.

* This version of movies returns a static set of data for the Cupertino Postal Code.

#### May 12, 2018

Move all of the embedded data to cormya.com. Get rid of embedded target and embedded data in the XCode project. cormya.com is very slow right now but this makes a lot of stuff a lot simpler than it was.

#### June 12, 2018

Add CoreData code to cache all of the Movie Posters and retrieve Posters from that cache. Still needs a bit of work but most of it is done. movies will only run on iOS 11+ now as the CoreData table MPData contains a URI (NSURL) field which requires XCode 9+ Tools and iOS 11+.

## Requirements

- XCode 9+
- iOS 11+
- Swift 4+


![marquee](https://cormya.com/image/_marquee.png "Marquee") | ![theaters_for_movie](https://cormya.com/image/_theaters_for_movie.png "Theaters for Movie") |
:-------------------------:|:-------------------------:
**Marquee** | **Theaters for Movie** |
![movies_for_theater](https://cormya.com/image/_movies_for_theater.png "Movies for Theater") | ![trailers](https://cormya.com/image/_view_trailer.png "View Trailers") |
**Movies for Theater** | **View Trailer** |
![itunes](https://cormya.com/image/_itunes_preview.png "iTunes Preview") | ![driving_directions](https://cormya.com/image/_driving_directions.png "Driving Directions") |
**iTunes Preview** | **Driving Directions**