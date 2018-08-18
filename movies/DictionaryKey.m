//
//  DictionaryKey.m
//  movies
//
//  Created by Jerry Hale on 4/11/17.
//  Copyright © 2018 jhale. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DictionaryKey.h"

NSString * const KEY_DAY_OFFSET = @"offset";

NSString	*gShowDate = @"";
NSString	*gPostalCode = @"95014";

NSString * const KEY_ID = @"id";
NSString * const KEY_NAME = @"name";

NSString * const KEY_LAT = @"lat";
NSString * const KEY_LONG = @"long";

NSString * const KEY_TICKET_URL = @"ticket_url";

NSString * const KEY_URL = @"url";
NSString * const KEY_TEL = @"tel";
NSString * const KEY_SCREENS = @"screens";
NSString * const KEY_SHOW_DATE = @"show_date";
NSString * const KEY_NOW_SHOWING = @"now_showing";

NSString * const KEY_SHOWTIME_DATES = @"showtime_dates";
NSString * const KEY_ALL_TIMES = @"alltimes";
NSString * const KEY_TIME = @"time";

NSString * const KEY_ADDRESS = @"address";
NSString * const KEY_STREET = @"street";
NSString * const KEY_CITY = @"city";
NSString * const KEY_STATE = @"state";
NSString * const KEY_POSTAL_CODE = @"postal_code";
NSString * const KEY_COUNTRY = @"country";

//	Movie
NSString * const KEY_INDEX = @"index";

NSString * const KEY_TMS_ID = @"tms_id";

//	index uses different key
NSString * const KEY_FILM_ID = @"film_id";

NSString * const KEY_TITLE = @"title";
NSString * const KEY_RATING = @"rating";
NSString * const KEY_RELEASE_DATE = @"release_date";
NSString * const KEY_RUN_TIME = @"run_time";
NSString * const KEY_TOMATO_RATING = @"tomatoRating";

NSString * const KEY_POSTERS = @"posters";

NSString * const KEY_POSTER = @"poster";
NSString * const KEY_ACTORS = @"actors";

//	index uses cast instead of 'actors'
NSString * const KEY_HAS_INFO = @"has_info";
NSString * const KEY_INFO = @"info";


NSString * const KEY_CAST = @"cast";

NSString * const KEY_DIRECTORS = @"directors";
NSString * const KEY_GENRES = @"genres";
NSString * const KEY_SUMMARY = @"summary";

NSString * const KEY_PREVIEWS = @"previews";
NSString * const KEY_PREVIEW = @"preview";
NSString * const KEY_TEXT = @"text";
NSString * const KEY_TRAILER_URL = @"text";

NSString * const KEY_ITUNES_URL = @"iTunesURL";

//	UITableView cell names
NSString * const VALUE_SHOWDATE_CELL = @"ShowDate_Cell";

NSString * const VALUE_MARQUEE_CELL = @"Marquee_Cell";

NSString * const VALUE_L0_CELL = @"L0_Cell";
NSString * const VALUE_L0_CELL_MOVIE = @"L0_Cell_movie";
NSString * const VALUE_L0_CELL_THEATER = @"L0_Cell_theater";

NSString * const VALUE_L1_CELL = @"L1_Cell";
NSString * const VALUE_L1_CELL_MOVIE = @"L1_Cell_movie";
NSString * const VALUE_L1_CELL_THEATER = @"L1_Cell_theater";

NSString * const VALUE_L2_CELL = @"L2_Cell";

//	required keys to track UITableViewCell
NSString * const KEY_CAN_EXPAND = @"canExpand";
NSString * const KEY_IS_EXPANDED = @"isExpanded";
NSString * const KEY_IS_VISIBLE = @"isVisible";
NSString * const KEY_CELL_IDENTIFIER = @"cellIdentifier";
NSString * const KEY_ADDITIONAL_ROWS = @"additionalRows";

//	Segue values
NSString * const S2_MOVIE_TRAILER = @"s2_movie_trailer";
NSString * const S2_THEATER_DETAIL = @"s2_theater_detail";
NSString * const S2_MOVIE_DETAIL = @"s2_movie_detail";
NSString * const S2_CONTAINER = @"s2_container";
NSString * const S2_BOX_OFFICE = @"s2_box_office";
NSString * const S2_MARQUEE = @"s2_marquee";
NSString * const S2_MAP = @"s2_map";
NSString * const S2_ITUNES = @"s2_itunes";
NSString * const S2_CONTAINER_UNWIND = @"s2_container_unwind";

NSString * const NOTIF_LAST_UPDATE_CHANGED = @"Notif Last Update Changed";
NSString * const NOTIF_POSTAL_CODE_CHANGED = @"Notif Postal Code Changed";
NSString * const NOTIF_DAY_OFFSET_CHANGED = @"Notif Day Offset Changed";

NSString * const ENAME_MIDATA = @"MIData";
NSString * const ENAME_MTDATA = @"MTData";
NSString * const ENAME_MPDATA = @"MPData";

//	theme colors
//	blue theme color
#define	THEME_COLOR_BLUE		0x76D6FF
#define	THEME_ALPHA_BLUE		0.4

//	sky theme color
#define	THEME_COLOR_SKY			0x73FDFF
#define	THEME_ALPHA_SKY			0.6

//	aluminum theme color
#define	THEME_COLOR_ALUMINUM	0xA9A9A9
#define	THEME_ALPHA_ALUMINUM	0.4
//
//	cherry theme color
#define	THEME_COLOR_CHERRY		0xFF2600
#define	THEME_ALPHA_CHERRY		0.3

NSUInteger THEME_COLOR = THEME_COLOR_BLUE;
float ALPHA_VALUE = THEME_ALPHA_BLUE;

