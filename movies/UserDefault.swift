//
//  UserDefault.swift
//  movies
//
//  Created by Jerry Hale on 10/15/17
//  Copyright © 2018-2020 jhale. All rights reserved
//

//	if there is no existing entry in UserDefaults for a given
//	key, create one, else if the new value is different from
//	the old value store the new value and post a changed notif

class UserDefault
{
    enum key
    {
		static let LastUpdate = "key_last_update"
		static let DayOffset = "key_day_offset"
		static let PostalCode = "key_postal_code"
    }

	class func getLastUpdate() -> Date { return (UserDefaults.standard.object(forKey: key.LastUpdate) as! Date) }
	class func getDayOffset() -> Int { return (UserDefaults.standard.integer(forKey: key.DayOffset)) }
	class func getPostalCode() -> String { return (UserDefaults.standard.string(forKey: key.PostalCode))! }

	class func setLastUpdate(_ date: Date)
	{
		if UserDefaults.standard.object(forKey: UserDefault.key.LastUpdate) == nil
		{ UserDefaults.standard.set(date, forKey: key.LastUpdate) }
		else if Calendar.current.compare(getLastUpdate(), to: date, toGranularity: .day) != .orderedSame
		{
			UserDefaults.standard.set(date, forKey: key.LastUpdate)
			NotificationCenter.default.post(name:Notification.Name(rawValue:NOTIF_LAST_UPDATE_CHANGED), object: nil, userInfo: nil)
		}
	}

	class func setDayOffset(_ dayoffset: Int)
	{
		if UserDefaults.standard.object(forKey: UserDefault.key.DayOffset) == nil
		{ UserDefaults.standard.set(dayoffset, forKey: key.DayOffset) }
		else if getDayOffset() != dayoffset
		{
			UserDefaults.standard.set(dayoffset, forKey: key.DayOffset)
			NotificationCenter.default.post(name:Notification.Name(rawValue:NOTIF_DAY_OFFSET_CHANGED), object: nil, userInfo: nil)
		}
	}

	class func setPostalCode(_ postalcode: String)
	{
		if UserDefaults.standard.object(forKey: UserDefault.key.PostalCode) == nil
		{ UserDefaults.standard.set(postalcode, forKey: key.PostalCode) }
		else if getPostalCode() != postalcode
		{
			UserDefaults.standard.set(postalcode, forKey: key.PostalCode)
			NotificationCenter.default.post(name:Notification.Name(rawValue:NOTIF_POSTAL_CODE_CHANGED), object: nil, userInfo: nil)
		}
	}
}
