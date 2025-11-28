//
//  MapViewController.swift
//  TripPlanner
//
//  Created by Mananas on 27/11/25.
//

import UIKit
import MapKit
import FirebaseFirestore

class MapViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore() // referencia a Firebase
    
    var savedSites: [Site] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        loadSavedSites()
    }
    
    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tap)
    }
    
    @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        // 1️⃣ Mostrar alerta para ingresar nombre
        let alert = UIAlertController(title: "Nombre del sitio",message: "Ingresa un nombre para este sitio",preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Nombre"
        }
        
        let saveAction = UIAlertAction(title: "Guardar", style: .default) { _ in
            let name = alert.textFields?.first?.text ?? "Sin nombre"
            
            print("Coordenada seleccionada:", coordinate)
            
            // Guardar coordenada
            let site = Site(name: name, coordinate: coordinate)
            self.savedSites.append(site)
            self.tableView.reloadData()
            
            // Mostrar un pin
            self.placePin(at: coordinate, title:name)
            
            // Guardar en Firebase
            self.db.collection("sitios").addDocument(data: [
                "name": name,
                "latitude": coordinate.latitude,
                "longitude": coordinate.longitude,
                "createdAt": Timestamp()
            ])
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
        
        
    }
    
    func placePin(at coordinate: CLLocationCoordinate2D, title: String) {
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
        cell.textLabel?.text = "\(site.name)-Lat: \(site.coordinate.latitude), Lon: \(site.coordinate.longitude)"
        return cell
    }
    
    func loadSavedSites() {
        db.collection("sitios").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }
            self.savedSites = docs.compactMap { doc in
                guard let lat = doc["latitude"] as? CLLocationDegrees,
                      let lon = doc["longitude"] as? CLLocationDegrees,
                      let name = doc["name"] as? String
                        
                else { return nil }
                return Site(name: name, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
            self.tableView.reloadData()
            
            self.savedSites.forEach { site in
                self.placePin(at: site.coordinate, title: site.name)
            }
        }
        
        // MARK: - UITableViewDelegate
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let site = savedSites[indexPath.row]
            print("Seleccionaste el sitio: \(site)")
            
            // Centrar mapa en la coordenada seleccionada
            let region = MKCoordinateRegion(center: site.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: true)
        }
    }
    
}
