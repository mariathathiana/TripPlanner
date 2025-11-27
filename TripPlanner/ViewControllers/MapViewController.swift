//
//  MapViewController.swift
//  TripPlanner
//
//  Created by Mananas on 27/11/25.
//

import UIKit
import MapKit

class MapViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    var savedSites: [CLLocationCoordinate2D] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()

        tableView.dataSource = self
        tableView.delegate = self
    }

    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tap)
    }

    @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

        print("Coordenada seleccionada:", coordinate)

        // Guardar coordenada
        savedSites.append(coordinate)
        tableView.reloadData()

        // Mostrar un pin
        placePin(at: coordinate)
    }

    func placePin(at coordinate: CLLocationCoordinate2D) {
        mapView.removeAnnotations(mapView.annotations) // opcional

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Ubicación seleccionada"
        mapView.addAnnotation(annotation)
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedSites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SiteCell", for: indexPath)
        let site = savedSites[indexPath.row]
        cell.textLabel?.text = "Lat: \(site.latitude), Lon: \(site.longitude)"
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let site = savedSites[indexPath.row]
        print("Seleccionaste el sitio: \(site)")

        // Centrar mapa en la coordenada seleccionada
        let region = MKCoordinateRegion(center: site, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
}
