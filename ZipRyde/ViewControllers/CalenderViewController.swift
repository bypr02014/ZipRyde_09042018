//
//  CalenderViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 9/25/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit
import Koyomi

class CalenderViewController: UIViewController {

    @IBOutlet var calenderView: UIView!
    @IBOutlet var todaysDateLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var currentMonthLabel: UILabel!
    
    var koyomi: Koyomi!
    var timePicker: UIDatePicker!
    var scheduledDateTime : String!
    var delegate: RydeScheduleTime!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = CGRect(x: 15, y: 150, width: self.calenderView.frame.size.width - 30, height: self.calenderView.frame.size.height - 60 - 150)
        koyomi = Koyomi(frame: frame, sectionSpace: 0.5, cellSpace: 0.5, inset: .zero, weekCellHeight: 25)
        koyomi.selectedDayTextState = .change(.white)
        koyomi.isHiddenOtherMonth = true
        koyomi.selectedStyleColor = UIColor(red: 69 / 255, green: 119 / 255, blue: 223 / 255, alpha: 1)
        koyomi.calendarDelegate = self
        koyomi
            .setDayFont(size: 11)
            .setWeekFont(size: 14)
        koyomi.style = .monotone
        koyomi.dayPosition = .center
        self.calenderView.addSubview(koyomi)

        self.todaysDateLabel.text = koyomi.currentDateString()
        self.currentMonthLabel.text = koyomi.currentDateString()
        self.yearLabel.text = koyomi.currentDateString()
        
    }
    
    override func viewDidLayoutSubviews() {

        let frame = CGRect(x: 15, y: 150, width: self.calenderView.frame.size.width - 30, height: self.calenderView.frame.size.height - 60 - 150)
        koyomi.frame = frame
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        koyomi.display(in: .next)
    }

    @IBAction func previousButtonClicked(_ sender: Any) {
        koyomi.display(in: .previous)
    }

    @IBAction func cancelButtonClicked(_ sender: Any) {
        scheduledDateTime = nil
        self.calenderView.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func okButtonClicked(_ sender: Any) {
        
        if(scheduledDateTime == nil){
            showAlertPopUp("Please select a valid date.")
        }else {
            self.calenderView.removeFromSuperview()
            showTimePicker()
        }
    }

    func showTimePicker() {

        self.timePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 200))
        self.timePicker.center = self.view.center
        self.timePicker.backgroundColor = UIColor.white
        self.timePicker.datePickerMode = UIDatePickerMode.time

        self.timePicker.setValue(UIColor(red: 95 / 255.0, green: 110 / 255.0, blue: 205 / 255.0, alpha: 1.0), forKey: "textColor")
        self.timePicker.setValue(false, forKey: "highlightsToday")
        self.view.addSubview(self.timePicker)

        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.timePicker.frame.origin.y - 40, width: self.view.frame.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        self.view.addSubview(toolBar)

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(CalenderViewController.doneClicked))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(CalenderViewController.cancelClicked))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
    }

    func doneClicked() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let selectedTime = formatter.string(from: self.timePicker.date)
        guard let scheduleRydeTime = scheduledDateTime  else { return }
        scheduledDateTime = "\(scheduleRydeTime) \(selectedTime)"
        self.delegate.scheduleRyde(time: scheduledDateTime)
        self.dismiss(animated: true, completion: nil)
    }

    func cancelClicked() {
        scheduledDateTime = nil
        self.dismiss(animated: true, completion: nil)
    }
}

extension CalenderViewController: KoyomiDelegate {
    func koyomi(_ koyomi: Koyomi, didSelect date: Date?, forItemAt indexPath: IndexPath) {

        let selectedDateInStringFormat = Formatter.string(date!)
        let selectedDateInDateFormat = Formatter.date(selectedDateInStringFormat)
        
        let todayDate = Date()
        let todayDateInStringFormat = Formatter.string(todayDate)
        let todayDateInDateFormat = Formatter.date(todayDateInStringFormat)
        
        // Compare them
        switch selectedDateInDateFormat!.compare(todayDateInDateFormat!) {
        case .orderedAscending :
            scheduledDateTime = nil
            showAlertPopUp("Selected date cannot be less than current date. Please select a valid date.")            
        default:
            scheduledDateTime = selectedDateInStringFormat
            break
        }
    }

    func koyomi(_ koyomi: Koyomi, currentDateString dateString: String) {
        currentMonthLabel.text = koyomi.currentDateString()
    }
    
    func showAlertPopUp(_ message : String){
        let alertController = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

class Formatter
{
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"

        // make sure the following are the same as that used in the API
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale.current
        return formatter
    }()

    class func string(_ date: Date) -> String {
        return formatter.string(from: date)
    }
    
    class func date(_ string: String) -> Date? {
        return formatter.date(from: string)
    }
}
