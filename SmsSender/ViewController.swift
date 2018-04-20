//
//  ViewController.swift
//  SmsSender
//
//  Created by Atkuri,Ashok on 4/19/18.
//  Copyright © 2018 Myorganisation. All rights reserved.
//

import UIKit
import EventKit
import MessageUI

class ViewController: UIViewController,MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var phoneNumberTF: UITextField!
    var savedEventId : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Creates an event in the EKEventStore. The method assumes the eventStore is created and
    // accessible
    func createEvent(eventStore: EKEventStore, title: String, startDate: NSDate, endDate: NSDate) {
        let event = EKEvent(eventStore: eventStore)
        
        event.title = title
        event.startDate = startDate as Date!
        event.endDate = endDate as Date!
        event.calendar = eventStore.defaultCalendarForNewEvents
        do {
            try eventStore.save(event, span: .thisEvent)
            savedEventId = event.eventIdentifier
        } catch {
            print("Bad things happened")
        }
    }
    
    // Removes an event from the EKEventStore. The method assumes the eventStore is created and
    // accessible
    func deleteEvent(eventStore: EKEventStore, eventIdentifier: String) {
        let eventToRemove = eventStore.event(withIdentifier: eventIdentifier)
        if (eventToRemove != nil) {
            do {
                try eventStore.remove(eventToRemove!, span: .thisEvent)
            } catch {
                print("Bad things happened")
            }
        }
    }

    @IBAction func addEvent_Onclick(_ sender: Any) {
        let eventStore = EKEventStore()
        
        let startDate = NSDate()
        let endDate = startDate.addingTimeInterval(60 * 60) // One hour
        
        if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event, completion: {
                granted, error in
                self.createEvent(eventStore: eventStore, title: "DJ's Test Event", startDate: startDate, endDate: endDate)
            })
        } else {
            createEvent(eventStore: eventStore, title: "DJ's Test Event", startDate: startDate, endDate: endDate)
        }
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Message Body"
            controller.recipients = [phoneNumberTF.text!]
            controller.messageComposeDelegate = self as! MFMessageComposeViewControllerDelegate
            self.present(controller, animated: true, completion: nil)
        }
        else{
            print("cant send messages")
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController!, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
}

