//
//  NSTimeInterval+TimeComponents.swift
//  player1
//
//  Created by choonlog on 2014. 11. 25..
//  Copyright (c) 2014년 choonlog. All rights reserved.
//

import Foundation
extension NSTimeInterval {
    
    //
    // MARK: - Properties
    
    /// Get the total amount of hours that this Time Interval instance holds
    var hours: Int {
        return Int(floor(((self / 60.0) / 60.0)))
    }
    /// Get the hour component, up to 23 hours
    var hourComponent: Int {
        return self.hours % 24
    }
    /// Get the total amount of minutes that this Time Interval instance holds
    var minutes: Int {
        return Int(floor(self / 60.0))
    }
    /// Get the minutes component, up to 59 minutes
    var minuteComponent: Int {
        return minutes - (hours * 60)
    }
    /// Get the total amount of seconds that this Time Interval instance holds
    var seconds: Int {
        return Int(floor(self))
    }
    /// Get the seconds component, up to 59 seconds
    public var secondComponent: Int {
        return seconds - (minutes * 60)
    }
    /// Get the total amount of miliseconds that this Time Interval instance holds
    var miliseconds: Int64 {
        return Int64((seconds * 1000) + milisecondComponent)
    }
    /// Get the miliseconds component
    public var milisecondComponent: Int {
        var (intPart, fracPart) = modf(self)
        return Int(fracPart * 100)
    }
    
    //
    // MARK: - Public Methods
    
    ///
    /// Get this NSTimeInterval instance as a formatted string
    /// :param: useFraction Optionally appends the miliseconds to the string
    ///
    public func getFormattedInterval(miliseconds useFraction: Bool) -> String {
        let hoursStr = hourComponent < 10 ? "0" + String(hourComponent) : String(hourComponent)
        let minutesStr = minuteComponent < 10 ? "0" + String(minuteComponent) : String(minuteComponent)
        let secondsStr = secondComponent < 10 ? "0" + String(secondComponent) : String(secondComponent)
        var counter = "\(hoursStr):\(minutesStr):\(secondsStr)"
        
        if useFraction {
            let milisecondsStr = milisecondComponent < 10 ? "0" + String(milisecondComponent) : String(milisecondComponent)
            counter += ".\(milisecondsStr)"
        }
        
        return counter
    }
}