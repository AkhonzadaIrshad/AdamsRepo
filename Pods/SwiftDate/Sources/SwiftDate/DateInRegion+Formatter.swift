// SwiftDate
// Manage Date/Time & Timezone in Swift
//
// Created by: Daniele Margutti
// Email: <hello@danielemargutti.com>
// Web: <http://www.danielemargutti.com>
//
// Licensed under MIT License.

import Foundation

// MARK: - DateInRegion Formatter Support

public extension DateInRegion {
	
	/// Convert a `DateInRegion` to a string according to passed format expressed in region's timezone, locale and calendar.
	/// Se Apple's "Date Formatting Guide" to see details about the table of symbols you can use to format each date component.
	/// Since iOS7 and macOS 10.9 it's based upon tr35-31 specs (http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns)
	///
	/// - parameter formatString: format string
	///
	/// - returns: a string representing given date in format string you have specified
	func string(custom formatString: String) -> String {
		return self.string(format: .custom(formatString))
	}
	
	/// Convert a `DateInRegion` to a string using ISO8601 format expressed in region's timezone, locale and calendar.
	///
	/// - parameter opts: optional options for ISO8601 formatter specs (see `ISO8601Parser.Options`). If nil `.withInternetDateTime` will be used instead)
	///
	/// - returns: a string representing the date in ISO8601 format according to passed options
	func iso8601(opts: ISO8601DateTimeFormatter.Options? = nil) -> String {
		return self.string(format: .iso8601(options: opts ?? [.withInternetDateTime]))
	}
	
	
	/// Convert a `DateInRegion` to a string using region's timezone, locale and calendar
	///
	/// - parameter format: format of the string as defined by `DateFormat`
	///
	/// - returns: a new string or nil if DateInRegion does not contains any valid date
	func string(format: DateFormat) -> String {
		switch format {
		case .custom(let format):
			return self.formatters.dateFormatter(format: format).string(from: self.absoluteDate)
		case .strict(let format):
			return self.formatters.dateFormatter(format: format).string(from: self.absoluteDate)
		case .iso8601(let options):
			let formatter = self.formatters.isoFormatter()
			return formatter.string(from: self.absoluteDate, tz: self.region.timeZone, options: options)
		case .iso8601Auto:
			let formatter = self.formatters.isoFormatter()
			return formatter.string(from: self.absoluteDate, tz: self.region.timeZone, options: [.withInternetDateTime])
		case .rss(let isAltRSS):
			let format = (isAltRSS ? "d MMM yyyy HH:mm:ss ZZZ" : "EEE, d MMM yyyy HH:mm:ss ZZZ")
			return self.formatters.dateFormatter(format: format).string(from: self.absoluteDate)
		case .extended:
			let format = "eee dd-MMM-yyyy GG HH:mm:ss.SSS zzz"
			return self.formatters.dateFormatter(format: format).string(from: self.absoluteDate)
		case .dotNET:
			return DOTNETDateTimeFormatter.string(self)
		}
	}
	
	
	/// Get the representation of the absolute time interval between `self` date and a given date
	///
	/// - parameter date:      date to compare
	/// - parameter dateStyle: style to format the date
	/// - parameter timeStyle: style to format the time
	///
	/// - returns: a new string which represent the interval from given dates
	func intervalString(toDate date: DateInRegion, dateStyle: DateIntervalFormatter.Style = .medium, timeStyle: DateIntervalFormatter.Style = .medium) -> String {
		let formatter = self.formatters.intervalFormatter()
		formatter.dateStyle = dateStyle
		formatter.timeStyle = timeStyle
		return formatter.string(from: self.absoluteDate, to: date.absoluteDate)
	}
	
	
	/// Convert a `DateInRegion` date into a string with date & time style specific format style
	///
	/// - parameter dateStyle: style of the date (if not specified `.medium`)
	/// - parameter timeStyle: style of the time (if not specified `.medium`)
	///
	/// - returns: a new string which represent the date expressed into the current region
	func string(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .medium) -> String {
		let formatter = self.formatters.dateFormatter()
		formatter.dateStyle = dateStyle
		formatter.timeStyle = timeStyle
		return formatter.string(from: self.absoluteDate)
	}
	
	/// This method produces a colloquial representation of time elapsed between this `DateInRegion` (`self`) and
	/// the current date (`Date()`)
	///
	/// - parameter style: style of output. If not specified `.full` is used
	/// - returns: colloquial string representation
	/// - throws: throw an exception is colloquial string cannot be evaluated
	@available(*, deprecated: 4.5.0, message: "Deprecated. Use colloquialSinceNow(options:) instead")
	func colloquialSinceNow(style: DateComponentsFormatter.UnitsStyle? = nil) throws -> (colloquial: String, time: String?) {
		let now = DateInRegion(absoluteDate: Date(), in: self.region)
		return try self.colloquial(toDate: now, style: style)
	}
	
	/// This method produces a colloquial representation of time elapsed between this `DateInRegion` and
	/// the current date (`Date()`).
	///
	/// - Parameter options: formatting options, `nil` to use default options
	/// - Returns: String, `nil` if formatting fails
	func colloquialSinceNow(options: ColloquialDateFormatter.Options? = nil) -> String? {
		let now = DateInRegion(absoluteDate: Date(), in: self.region)
		return self.colloquial(toDate: now, options: options)
	}
	
	/// This method produces a colloquial representation of time elapsed between this `DateInRegion` (`self`) and
	/// another passed date.
	///
	/// - Parameters:
	/// - parameter date: date to compare
	/// - parameter style: style of output. If not specified `.full` is used
	/// - returns: colloquial string representation
	/// - throws: throw an exception is colloquial string cannot be evaluated
	@available(*, deprecated: 4.5.0, message: "Deprecated. Use colloquial(toDate:options:) instead")
	func colloquial(toDate date: DateInRegion, style: DateComponentsFormatter.UnitsStyle? = nil) throws -> (colloquial: String, time: String?) {
		let formatter = DateInRegionFormatter()
		formatter.localization = Localization(locale: self.region.locale)
		formatter.unitStyle = style ?? .full
		if style == nil || style == .full || style == .spellOut {
			return try formatter.colloquial(from: self, to: date)
		} else {
			return (try formatter.timeComponents(from: self, to: date),nil)
		}
	}
	
	/// This method produces a colloquial representation of time elapsed between `self` and another reference date.
	///
	/// - Parameters:
	///   - date: reference date
	///   - options: formatting options, `nil` to use default options
	/// - Returns: String, `nil` if formatting fails
	func colloquial(toDate date: DateInRegion, options: ColloquialDateFormatter.Options? = nil) -> String? {
		return ColloquialDateFormatter.colloquial(from: self, to: date, options: options)
	}
	
	/// This method produces a string by printing the interval between self and another date and output a string where each
	/// calendar component is printed.
	///
	/// - parameter toDate:	date to compare
	/// - parameter options: options to format the output. Keep in mind: `.locale` will be overwritten by self's `region.locale`.
	///
	/// - throws: throw an exception if time components cannot be evaluated
	///
	/// - returns: string with each time component
	func timeComponents(toDate date: DateInRegion, options: ComponentsFormatterOptions? = nil) throws -> String {
		let interval = self.absoluteDate.timeIntervalSince(date.absoluteDate)
		var optionsStruct = (options == nil ? ComponentsFormatterOptions() : options!)
		optionsStruct.locale = self.region.locale
		optionsStruct.allowedUnits = optionsStruct.allowedUnits ?? optionsStruct.bestAllowedUnits(forInterval: interval)
		return try interval.string(options: optionsStruct, shared: self.formatters.useSharedFormatters)
	}
	
	// This method produces a string by printing the interval between self and current Date and output a string where each
	/// calendar component is printed.
	///
	/// - parameter options: options to format the output. Keep in mind: `.locale` will be overwritten by self's `region.locale`.
	///
	/// - throws: throw an exception if time components cannot be evaluated
	///
	/// - returns: string with each time component
	func timeComponentsSinceNow(options: ComponentsFormatterOptions? = nil) throws -> String {
		let interval = abs(self.absoluteDate.timeIntervalSinceNow)
		var optionsStruct = (options == nil ? ComponentsFormatterOptions() : options!)
		optionsStruct.locale = self.region.locale
		return try interval.string(options: optionsStruct, shared: self.formatters.useSharedFormatters)
	}
}
