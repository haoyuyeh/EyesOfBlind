//
//  HomeModeViewController.swift
//  EyesOfBlind
//
//  Created by Hao Yu Yeh on 2017/9/18.
//  Copyright © 2017年 Hao Yu Yeh. All rights reserved.
//

import UIKit
import Speech
import MapKit
import AVFoundation


class NavigationModeViewController: UIViewController, SpeechToTextDelegate,CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Properties
    var locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D!
    var steps = [MKRouteStep]()
    var stepCounter = 0
    var heading = 0.0
    let speechSynthesizer = AVSpeechSynthesizer()
    
    
    
    
    
    
    
    
    
    
    
    
    /****************************
     \\\\\\\\\\\\\\\\\\\\\\\\\\
     ***************************/
    /****************************
     variables for voice control
     ***************************/
    //var delegate: NaviDelegate?
    var ToDoTable = ToDoTableViewController()
    private var txtToSpeech = TextToSpeech()
    private var voiceToText = SpeechToText()
    private var findAddressState = false
    //use to store the command which is converted from voice
    private var voiceCommand = ""
    
    /*****************************
     variables for viewController
     ****************************/
    @IBOutlet var singleTap: UITapGestureRecognizer!
    var canSingleTap = true
    
    /*************************
     viewController functions
     ************************/
    
    override func viewWillAppear(_ animated: Bool) {
        txtToSpeech.say(txtIn: "in navigation mode")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        // assign delegate to this class
        voiceToText.delegate = self
        
        /*
         ask authentication for speech recognition
         */
        voiceToText.authentication()
        
        // voice instruction for how to give voice command
        txtToSpeech.say(txtIn: "touch the screen and then start to say command, touch again when finishing speaking")
        
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        
        
    }
    /**
     touch screen one time to call run function in SpeechToText class:
     first touch to activate the recording and then start to say command,
     second touch when finishing speaking
     */
    @IBAction func handleSingleTap(_ sender: UITapGestureRecognizer) {
        // diable single tap before command processing completed
        if canSingleTap {
            canSingleTap = voiceToText.run()
        }
    }
    
    /***********************
     SpeechToText functions
     ***********************/
    
    /**
     delegate function: get transcript from SpeechToText and process it
     */
    func returnTranscript(_ transcript: String) {
        voiceCommand = ""
        voiceCommand = transcript
        print(voiceCommand)
        processCommand(command: self.voiceCommand)
        // enable single tap
        canSingleTap = true
    }
    
    /**
     decide what to do based on the receiving voice command
     */
    private func processCommand(command:String) {
        let commands = command.lowercased()
        //serachOPP("Coles")
        let addressResult = ToDoTable.searchItem(commands)
        let state = (addressResult == "")
        print("nnnn: \(state)")
        if ((commands == Commands.outsideMode) && (findAddressState == false)) {
            self.tabBarController?.selectedIndex = 0
            
        }else if((commands == Commands.NaviMode) && (findAddressState == false)){
            txtToSpeech.say(txtIn: "already in navigation mode")
        }else if((commands == Commands.start) && (findAddressState == false)){
            findAddressState = true
            txtToSpeech.say(txtIn: "Start to navigate, please voice in address")
            //serachOPP("Q")
            print("111: \(state)")
        }else if(state == false && (findAddressState == true)){
            txtToSpeech.say(txtIn: "Ready for navigation")
            txtToSpeech.say(txtIn: "\(addressResult)")
            serachOPP(addressResult)
            print("Ready to go: \(addressResult)")
            findAddressState = false
            print("222: \(findAddressState)")
            
            //let nnn = delegate?.searchItem("home")
            // let nnn = ToDoTable.searchItem("home")
            // print("findout: \(nnn)")
            //txtToSpeech.say(txtIn: nnn!)
        }
        else {
            txtToSpeech.say(txtIn: "no match command, say again")
        }
    }
    
    
    /****************************
     \\\\\\\\\\\\\\\\\\\\\\\\\\
     ***************************/
    
    
    func getDirections(destination: MKMapItem){
        let startPlacemark = MKPlacemark(coordinate: currentCoordinate)
        let startMapItem = MKMapItem(placemark: startPlacemark)
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = startMapItem
        directionsRequest.destination = destination
        //designed for blind when walking in the pedestrian, so choose 'walking' as transport type
        directionsRequest.transportType = .walking
        let directions = MKDirections(request: directionsRequest)
        directions.calculate { (response, _) in
            guard let response = response else {return}
            //the best route
            guard let primaryRoute = response.routes.first else {return}
            self.mapView.add(primaryRoute.polyline)
            
            //self.locationManager.stopUpdatingLocation()
            self.locationManager.monitoredRegions.forEach({self.locationManager.stopMonitoring(for: $0)})
            
            self.steps = primaryRoute.steps
            for i in 0 ..< primaryRoute.steps.count{
                print(primaryRoute.steps[i].instructions)
                print(primaryRoute.steps[i].distance)
                let region = CLCircularRegion(center: primaryRoute.steps[i].polyline.coordinate, radius: 20, identifier: "\(i)")
                self.locationManager.startMonitoring(for: region)
                //add circle for steps[i] in primary route
                let circle = MKCircle(center: region.center, radius: region.radius)
                self.mapView.add(circle)
            }
            
            let firstInstruction = "Now, in \(self.steps[0].distance) meters, please \(self.steps[0].instructions)."
            let speechUtterance = AVSpeechUtterance(string: firstInstruction)
            self.speechSynthesizer.speak(speechUtterance)
            
        }
    }
    //MARK: Delegates
    //MARK: MKMapView Delegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline{
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5.0
            return polylineRenderer
        }
        if overlay is MKCircle{
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.strokeColor = UIColor.green
            circleRenderer.alpha = 0.5
            return circleRenderer
        }
        return MKOverlayRenderer()
    }
    
    //MARK: Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else {return}
        currentCoordinate = currentLocation.coordinate
        mapView.setUserTrackingMode(.follow, animated: true)
        if CLLocationManager.headingAvailable(){
            locationManager.startUpdatingHeading()
        } else {
            print("heading not available")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.magneticHeading
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        stepCounter += 1
        if stepCounter < steps.count{
            let currentStep = steps[stepCounter]
            let instruction = "Now, in \(currentStep.distance) meters, \(currentStep.instructions)."
            let speechUtterance = AVSpeechUtterance(string: instruction)
            speechSynthesizer.speak(speechUtterance)
        }else{
            let instruction = "You have arrived at the destination."
            let speechUtterance = AVSpeechUtterance(string: instruction)
            speechSynthesizer.speak(speechUtterance)
            
            stepCounter = 0
            //locationManager.stopUpdatingLocation()
            locationManager.monitoredRegions.forEach({self.locationManager.stopMonitoring(for: $0)})
        }
    }
    
    //MARK: UISearchBar Delegate
    func serachOPP(_ text: String) {
        //searchBar.endEditing(true)
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = text
        
        let region = MKCoordinateRegion(center: currentCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        searchRequest.region = region
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, _) in
            guard let response = response else {return}
            guard let firstMapItem = response.mapItems.first else {return}
            self.getDirections(destination: firstMapItem)
        }
    }
    
    
    
    
    
    
    
}

