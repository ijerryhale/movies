# movies
iOS - movies displays a list of Movies and Theaters for given Location and Day.

movies contains an example of an embedded UIView which hosts a ContainerController which in turn manages multiple UIViewControllers and Segues.

movies also demonstrates how to set an initial UITableCell image and then replace that image with a lazily loaded image..

## Requirements

- XCode 8.3+
- iOS 10+
- Swift 3.1+


#### Aug 21, 2017
Not stable. Still folding in stuff, basic embedded and webservice targets working.

#### Aug 25, 2017
Added Earl Grey Framework, XCTest Target and simple Earl Grey test for movies_embedded Target.

#### Sep 2, 2017
Added Map View and Web View. Rewrote Marquee View to use UITableView. Cleaned up some trash.

#### Sep 5, 2017
Added lasy loading of images in Marquee. Show current location pin and destination pin when initially displaying Map.


![marquee](https://user-images.githubusercontent.com/4106530/30089364-21c7bf20-9261-11e7-823b-794557a4c284.png "Marquee") | ![theaters_for_movie](https://user-images.githubusercontent.com/4106530/30242571-8e33527a-954d-11e7-8e3c-adbfb34ffa5c.png "Theaters for Movie") |
:-------------------------:|:-------------------------:
*Marquee* | *Theaters for Movie* |
![movies_for_theater](https://user-images.githubusercontent.com/4106530/30242574-9d3a0192-954d-11e7-9bb7-03c6f00a4cc5.png "Movies for Theater") | ![trailers](https://user-images.githubusercontent.com/4106530/30089375-2a1f555c-9261-11e7-923d-22cbc7bf42b7.png "Trailers") |
*Movies for Theater* | *View Trailer* |
![itunes](https://user-images.githubusercontent.com/4106530/30089385-36007a5e-9261-11e7-987c-97c8dcdcf388.png "iTunes Preview") | ![driving_directions](https://user-images.githubusercontent.com/4106530/30089388-3a0966b0-9261-11e7-8800-fb6752e8a7ab.png "Driving Directions") |
*iTunes Preview* | *Driving Directions*
