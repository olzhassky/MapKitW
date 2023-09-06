//
//  ViewController.swift
//  MapKitW
//
//  Created by Olzhas Zhakan on 04.09.2023.
//

import UIKit
import MapKit
import SnapKit
import CoreLocation
class ViewController: UIViewController {
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    var locationStory: [CLLocationCoordinate2D] = []
    var distanceStory: CLLocationDistance = 0
    let annotation = MKPointAnnotation()
    
    let startTracking: UIButton = {
       let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.addTarget(self, action: #selector(startTrackingButton), for: .touchUpInside)
        button.configuration = .bordered()
        return button
    }()
    let stopTracking: UIButton = {
        let button = UIButton()
        button.setTitle("Stop", for: .normal)
        button.addTarget(self, action: #selector(stopTrackingButton), for: .touchUpInside)
        button.configuration = .bordered()
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        view.addSubview(startTracking)
        view.addSubview(stopTracking)
        mapView.showsUserLocation = true
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        startTracking.snp.makeConstraints {
            $0.center.equalToSuperview().offset(50)
        }
        stopTracking.snp.makeConstraints {
            $0.center.equalToSuperview().offset(100)
        }
        mapView.addAnnotation(annotation)
        mapView.delegate = self
        locationManager.startUpdatingLocation()
       
    }
    @objc func startTrackingButton() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    @objc func stopTrackingButton() {
        locationStory.removeAll()
        distanceStory = 0
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotation(annotation)
    }
}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let locationC = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        locationStory.append(locationC)
        mapView.zoomTo(locationC)
        drowLocations()
        if locationStory.count >= 2 {
            let previousLocation = CLLocation(latitude: locationStory[locationStory.count - 2].latitude, longitude: locationStory[locationStory.count - 2].longitude)
            let currentLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let distance = previousLocation.distance(from: currentLocation)
            distanceStory += distance
            annotation.title = String(format: "%.2f", distanceStory)
            annotation.coordinate = locationC
        }
    }
    func drowLocations() {
        let line = MKPolygon(coordinates: locationStory, count: locationStory.count)
        mapView.addOverlay(line)
    }
}

extension MKMapView {
    func zoomTo(_ location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        self.setRegion(region, animated: true)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
                polyLineRenderer.strokeColor = .systemRed
                polyLineRenderer.lineWidth = 10
                return polyLineRenderer
    }
}


