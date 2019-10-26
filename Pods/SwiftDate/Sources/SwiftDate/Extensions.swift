// SwiftDate
// Manage Date/Time & Timezone in Swift
//
// Created by: Daniele Margutti
// Email: <hello@danielemargutti.com>
// Web: <http://www.danielemargutti.com>
//
// Licensed under MIT License.

import Foundation

//MARK: - String Extension

public extension String {
	
	/// Allows you to transform a string to a DateInRegion object
	///
	/// - parameter format: format of the date string
	/// - parameter region: region in which you want to describe the date
	///
	/// - returns: a new DateInRegion representing passed string in given region
	 func date(format: DateFormat, fromRegion region: Region? = nil) -> DateInRegion? {
		return DateInRegion(string: self, format: format, fromRegion: region)
	}
	
	
	/// Attempt to parse a string with multiple date formats. Parsing operation is executed in order
	/// and when the first format ends successfully it stops the parsing chain and return the instance
	/// of `DateInRegion`.
	///
	/// - Parameters:
	///   - formats: formats to use
	/// - parameter region: region in which you want to describe the date
	/// - returns: a new DateInRegion representing passed string in given region
	 func date(formats: [DateFormat], fromRegion region: Region? = nil) -> DateInRegion? {
		return DateInRegion.date(string: self, formats: formats, fromRegion: region)
	}
	
}

//MARK: - String Extension PRIVATE

internal extension String {
	
	/// Substring with NSRange
	///
	/// - parameter nsRange: range
	///
	/// - returns: substring with given range
	 func range(from nsRange: NSRange) -> Range<String.Index>? {
		guard
			let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
			let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
			let from = String.Index(from16, within: self),
			let to = String.Index(to16, within: self)
			else { return nil }
		return from ..< to
	}
}

//MARK: Int Extension

/// This allows us to transform a literal number in a `DateComponents` and use it in math operations
/// For example `5.days` will create a new `DateComponents` where `.day = 5`.

public extension Int {
	
	/// Internal transformation function
	///
	/// - parameter type: component to use
	///
	/// - returns: return self value in form of `DateComponents` where given `Calendar.Component` has `self` as value
	internal func toDateComponents(type: Calendar.Component) -> DateComponents {
		var dateComponents = DateComponents()
		dateComponents.setValue(self, for: type)
		return dateComponents
	}

	/// Create a `DateComponents` with `self` value set as nanoseconds
	var nanoseconds: DateComponents {
		return self.toDateComponents(type: .nanosecond)
	}
	
	/// Create a `DateComponents` with `self` value set as seconds
	var seconds: DateComponents {
		return self.toDateComponents(type: .second)
	}
	
	/// Create a `DateComponents` with `self` value set as minutes
	var minutes: DateComponents {
		return self.toDateComponents(type: .minute)
	}
	
	/// Create a `DateComponents` with `self` value set as hours
	var hours: DateComponents {
		return self.toDateComponents(type: .hour)
	}
	
	/// Create a `DateComponents` with `self` value set as days
	var days: DateComponents {
		return self.toDateComponents(type: .day)
	}
	
	/// Create a `DateComponents` with `self` value set as weeks
	var weeks: DateComponents {
		return self.toDateComponents(type: .weekOfYear)
	}
	
	/// Create a `DateComponents` with `self` value set as months
	var months: DateComponents {
		return self.toDateComponents(type: .month)
	}
	
	/// Create a `DateComponents` with `self` value set as years
	var years: DateComponents {
		return self.toDateComponents(type: .year)
	}
}


/// Singular variations of Int extension for DateComponents for readability
/// - note these properties behave exactly as their plural-named equivalents

public extension Int {
    var nanosecond: DateComponents { return nanoseconds }
    var second: DateComponents { return seconds }
    var minute: DateComponents { return minutes }
    var hour: DateComponents { return hours }
    var day: DateComponents { return days }
    var week: DateComponents { return weeks }
    var month: DateComponents { return months }
    var year: DateComponents { return years }
}

