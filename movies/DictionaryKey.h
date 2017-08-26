//
//  DictionaryKey.h
//  Movies
//
//  Created by Jerry Hale on 4/11/17.
//  Copyright © 2017 jhale. All rights reserved.
//

//	we can work either with a
//	fixed set of embedded data,
//	or using AFNetworking with
//	a locally or remotely running
//	JSON server(s)

//	this version is set up to
//	run with embedded data,
//	there is no AFNetworking
//	with this version

extern NSString * const KEY_DAY_OFFSET;

//	Theater
extern NSString * const KEY_ID;
extern NSString * const KEY_NAME;
extern NSString * const KEY_TICKET_URL;

extern NSString * const KEY_URL;
extern NSString * const KEY_TEL;
extern NSString * const KEY_SCREENS;
extern NSString * const KEY_SHOW_DATE;
extern NSString * const KEY_NOW_SHOWING;

extern NSString * const KEY_SHOWTIME_DATES;
extern NSString * const KEY_ALL_TIMES;
extern NSString * const KEY_TIME;

extern NSString * const KEY_ADDRESS;
extern NSString * const KEY_STREET;
extern NSString * const KEY_CITY;
extern NSString * const KEY_STATE;
extern NSString * const KEY_POSTAL_CODE;
extern NSString * const KEY_COUNTRY;


//	Movie
extern NSString * const KEY_INDEX;

extern NSString * const KEY_TMS_ID;

extern NSString * const KEY_FILM_ID;

extern NSString * const KEY_FANDANGO_ID;
extern NSString * const KEY_FANDANGOID;

extern NSString * const KEY_TITLE;
extern NSString * const KEY_RATING;
extern NSString * const KEY_RELEASE_DATE;
extern NSString * const KEY_RUN_TIME;
extern NSString * const KEY_TOMATO_RATING;

extern NSString * const KEY_POSTERS;

extern NSString * const KEY_POSTER;
extern NSString * const KEY_ACTORS;

extern NSString * const KEY_HAS_INFO;
extern NSString * const KEY_INFO;

extern NSString * const KEY_CAST;
extern NSString * const KEY_DIRECTORS;
extern NSString * const KEY_GENRES;
extern NSString * const KEY_SUMMARY;

extern NSString * const KEY_PREVIEWS;
extern NSString * const KEY_PREVIEW;
extern NSString * const KEY_TEXT;
extern NSString * const KEY_TRAILER_URL;

extern NSString * const KEY_ITUNES_URL;

extern NSString * const VALUE_L0_CELL;
extern NSString * const VALUE_L0_CELL_MOVIE;
extern NSString * const VALUE_L0_CELL_THEATER;

extern NSString * const VALUE_L1_CELL;
extern NSString * const VALUE_L1_CELL_MOVIE;
extern NSString * const VALUE_L1_CELL_THEATER;

extern NSString * const VALUE_L2_CELL;

//	required keys to track UITableViewCell
extern NSString * const KEY_CAN_EXPAND;
extern NSString * const KEY_IS_EXPANDED;
extern NSString * const KEY_IS_VISIBLE;
extern NSString * const KEY_CELL_IDENTIFIER;
extern NSString * const KEY_ADDITIONAL_ROWS;


extern NSString * const S2_MOVIE_TRAILER;
extern NSString * const S2_THEATER_DETAIL;
extern NSString * const S2_MOVIE_DETAIL;

extern NSString * const S2_CONTAINER;
extern NSString * const S2_BOX_OFFICE;
extern NSString * const S2_MARQUEE;

extern NSString * const S2_SHOWDATE;
extern NSString * const S2_PREFERENCE;

extern NSString * const S2_CONTAINER_UNWIND;


extern NSString * const KEY_CO_STATE;
extern NSString * const KEY_CO_INDEX;

extern NSString * const NOTIF_SHOWDATE;

