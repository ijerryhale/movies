## movies
Display a list of Theaters and Movies for given Location and Day.

* movies contains an example of an embedded UIView which hosts a ContainerController which in turn manages multiple UIViewControllers and Segues.

* movies demonstrates how to set an initial UITableCell image and then replace that image with a lazily loaded image. movies will also lazy load the computed distance from the Current Location to a given Theater.

* This version of movies will return real time data for Postal Codes 95014, 10021, 60601, and 90024. movies will default to returning data for Postal Code 95014.

* movies uses the essentially the same AFNetworking HTTP data access layer that the Stocks sample does. movies adds a CoreData layer that will store JSON data locally so that a given call to the server is made only once. Movie Poster images are also stored locally.

* movies is making calls against my server which is pretty slow. Additionally, for a given Location and Postal Code the system will cache the data once on the server and once locally so that the first call for a unique Location, Day, and device is slow. Any subsequent calls are much faster.

## August 18, 2018

Move Postal Code and Show Date onto Marquee. Fix Bugs

## October 15, 2018

Update to XCode 10, Swift 4.2

## June 2, 2019

Update to Swift 5. I am currently working on this version as I have time so that there be bugs here.

## Requirements

- XCode 10+
- iOS 11+
- Swift 5+


![marquee](https://cormya.com/image/_marquee.png "Marquee") | ![theaters_for_movie](https://cormya.com/image/_theaters_for_movie.png "Theaters for Movie") |
:-------------------------:|:-------------------------:
**Marquee** | **Theaters for Movie** |
![movies_for_theater](https://cormya.com/image/_movies_for_theater.png "Movies for Theater") | ![trailers](https://cormya.com/image/_view_trailer.png "View Trailers") |
**Movies for Theater** | **View Trailer** |
![itunes](https://cormya.com/image/_itunes_preview.png "iTunes Preview") | ![driving_directions](https://cormya.com/image/_driving_directions.png "Driving Directions") |
**iTunes Preview** | **Driving Directions**
