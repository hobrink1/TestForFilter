//
//  MapViewController.swift
//  Toduba
//
//  Created by alessandro izzo on 24/06/18.
//  Copyright © 2018 alessandro izzo. All rights reserved.
//

import UIKit
import SDWebImage
import Mapbox
import GoogleMaps

class MapViewController: UIViewController {
    
    let RESTAURANT_CELL_HEIGHT: CGFloat = 200
    
    @IBOutlet weak var headerView2: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gpsButton: UIButton!
    
    @IBOutlet weak var viewSettingsEnabled: UIView?
    fileprivate let reuId_restaurant_cell = "RestaurantCell"
    
    var viewForRestaurantsTableView: UIView?
    var restaurantsTableView: UITableView?
    var numberLabel: UILabel?
    
    var restaurants: [Restaurant]?
    var filteredRestaurants: [Restaurant]?
    var vcRestaurant : TPRestaurantPopoverViewController?
    
    var popbckView : TPPopoverBackgroundView?
    var locationManager : CLLocationManager?
    var myLocation : CLLocation?
    var centerdOnMyPosition : Bool
    var selectedLayer : MGLSymbolStyleLayer?
    var selectedSourceItems : MGLShapeSource?
    let markerTapSemaphore = DispatchSemaphore(value: 1)
    var visibleMapArea: MGLCoordinateBounds!
    
    var gdoOption: Bool?
    var restaurantOption: Bool?
    var distanceOption: Int?
    var rId: String?
    
    @IBOutlet weak var mapView: MGLMapView!
    
    required init?(coder aDecoder: NSCoder) {
        centerdOnMyPosition = false
        ini=0
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetOptions()
        //        if TPContentManager.sharedInstance.mapsKey == nil {
        //            TPContentManager.sharedInstance.getMapsKey({(data: Int?, error: NetworkError?) in
        //                if error != nil {
        //                    print("getMapsKey error \(error!)")
        //                    return
        //                }
        //                if let key = TPContentManager.sharedInstance.getMapsKey(){
        //                    GMSServices.provideAPIKey(key)
        //                }
        //            })
        //        }
        //        guard let _ = TPContentManager.sharedInstance.mapsKey else {
        //            //TODO ERROR
        //            let alert = UIAlertController(title: ERRT_general, message: ERRM_general, preferredStyle: .alert)
        //            alert.addAction(UIAlertAction(title:L_NO, style: .default, handler: nil))
        //            present(alert, animated: false)
        //            return
        //        }
        if TPContentManager.sharedInstance.getMapsKey() == nil {
            TPContentManager.sharedInstance.getMapsKey({(data: Int?, error: NetworkError?) in
                if error != nil {
                    print("getMapsKey error \(error!)")
                    return
                }
                if let key = TPContentManager.sharedInstance.getMapsKey(){
                    GMSServices.provideAPIKey(key)
                }
            })
        }
        searchBar.layer.borderColor = UIColor.clear.cgColor
        searchBar.backgroundImage = UIImage()
        rId = (tabBarController as? TPCustomTabBarViewController)?.getRId()
        if let styleURL = URL(string: "mapbox://styles/clikapp/cju17upsb083s1fp1d6cato91?optimize=true") {
            //mapView = MGLMapView(frame: view.bounds, styleURL: styleURL)
            mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            mapView.styleURL = styleURL
        }
        //mapView.locationManager.delegate = self
        mapView.minimumZoomLevel = 6
        mapView.maximumZoomLevel = 20
        mapView.isRotateEnabled = false
        visibleMapArea = MGLCoordinateBounds(sw: CLLocationCoordinate2D(latitude: 46.956910,longitude: 4.438501),ne: CLLocationCoordinate2D(latitude: 35.861990,longitude: 19.305898))
        mapView.setVisibleCoordinateBounds(visibleMapArea, animated: false)
        let mapTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
            mapTapGestureRecognizer.require(toFail: recognizer)
        }
        mapView.addGestureRecognizer(mapTapGestureRecognizer)
        mapView.delegate = self
        //mapView.userTrackingMode = .followWithHeading
        mapView.showsUserHeadingIndicator = true
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        popbckView = TPPopoverBackgroundView(frame: UIScreen.main.bounds)
        popbckView?.view = /*UIApplication.shared.keyWindow*/ self.view
        searchBar.delegate = self
        if #available(iOS 13.0, *) {
            searchBar.layer.cornerRadius = searchBar.frame.height / 2
            searchBar.backgroundColor = .white
            //let svs = searchBar.subviews.flatMap { $0.subviews }
//            for subView in searchBar.subviews[0].subviews {//where subView is UITextField {
//                if subView is UITextField {
//
//                }
//                else{
//                    //subView.alpha = 0
//                }
//            }
            //            if let textField = searchBar.value(forKey: "searchField") as? UITextField  {
            //                textField.textColor = .black
            //            }
            searchBar.tintColor = .gray
            searchBar.searchTextField.textColor = .black
            searchBar.searchTextField.backgroundColor = .white
        }
        else{
            searchBar.isTranslucent = false
            searchBar.layer.masksToBounds = false
            searchBar.layer.borderWidth = 0
            searchBar.layer.shadowColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 0.5).cgColor
            searchBar.layer.shadowRadius = 2
            searchBar.layer.shadowOpacity = 0.6
            searchBar.layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
            for subView in searchBar.subviews[0].subviews {//where subView is UITextField {
                if subView is UITextField {
                    subView.tintColor = UIColor.black
                    subView.backgroundColor = UIColor.whitePearl
                }
                else{
                    subView.alpha = 0
                }
            }
        }
        viewSettingsEnabled?.layer.cornerRadius = viewSettingsEnabled?.frame.size.width ?? 0 / 2
        viewSettingsEnabled?.clipsToBounds = true
        gpsButton.imageView?.clipsToBounds = true
        gpsButton.cornerRadius = gpsButton.frame.height / 2
        gpsButton.layer.masksToBounds = false
        gpsButton.layer.borderWidth = 0
        gpsButton.layer.shadowColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 0.5).cgColor
        gpsButton.layer.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0).cgColor
        gpsButton.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
        gpsButton.tintColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
        gpsButton.layer.shadowRadius = 2
        gpsButton.layer.shadowOpacity = 0.6
        gpsButton.layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
        
        getRestaurants(true)
        
        //flipButton.layer.shadowPath = UIBezierPath(rect: flipButton.bounds).cgPath
        //searchBar.layer.shadowPath = UIBezierPath(rect: searchBar.bounds).cgPath
        //searchBar.subviews[0].subviews.flatMap(){ $0 as? UITextField }.first?.tintColor = UIColor.blue
        // Loop into it's subviews and find TextField, change tint color to something else.
        
        //self.definesPresentationContext = true
        
    }
    
    @objc func handleMapTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: mapView)
        let touchableSquare = squareFrom(location: location)
        //print("handleMapTap")
        for feature in mapView.visibleFeatures(in: touchableSquare, styleLayerIdentifiers: ["restaurant-unclustered"]) {
            print(feature)
            guard let i = feature.attributes["identifier"] else {
                continue
            }
            print(feature.attributes)
            if let _ = feature.attributes["selected"] {
                back()
            }
            else{
                
                showRestaurantPopover(i as! String, false)
            }
        }
        for feature in mapView.visibleFeatures(in: touchableSquare, styleLayerIdentifiers: ["gdo-unclustered"]) {
            print(feature)
            guard let i = feature.attributes["identifier"] else {
                continue
            }
            print(feature.attributes)
            if let _ = feature.attributes["selected"] {
                back()
            }
            else{
                
                showRestaurantPopover(i as! String, false)
            }
        }
    }
    
    private func squareFrom(location: CGPoint) -> CGRect {
        let length = 40.0
        return CGRect(x: Double(location.x - CGFloat(length / 2)), y: Double(location.y - CGFloat(length / 2)), width: length, height: length)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (navigationController as? TPCustomNavigationViewController)?.backButtonIsHidden(false)
        if CLLocationManager.locationServicesEnabled() {
            if locationManager == nil {
                locationManager = CLLocationManager()
            }
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager?.startUpdatingLocation()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        centerdOnMyPosition = false
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.stopUpdatingLocation()
            locationManager?.delegate = nil
            locationManager = nil
        }
    }
    
    var ini : CGFloat
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //ini = mapView.compassView.frame.height
        //mapView.compassView.frame.origin = CGPoint(x: 12, y: mapView.frame.height-ini-12)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func flipButtonClicked(_ sender: Any) {
        showOrHideRestaurantList()
    }
    
    @IBAction func gpsButtonClicked(_ sender: Any) {
        guard CLLocationManager.locationServicesEnabled() else { return }
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            let alert = UIAlertController(title: T_general, message: ERRM_allow_location_permission, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:L_NO, style: .default, handler: nil))
            alert.addAction(UIAlertAction(title:L_YES, style: .default, handler: { (action :UIAlertAction) in
                if let url = NSURL(string: UIApplicationOpenSettingsURLString) as URL? {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        case .authorizedAlways, .authorizedWhenInUse:
            centerToMyLocation(true)
        }
    }
    
    @IBAction func filterButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard.init(name:"Main",bundle: nil)
        let alert = storyboard.instantiateViewController(withIdentifier: "MapFilterModalViewController") as! MapFilterModalViewController
        alert.providesPresentationContextTransitionStyle = true
        alert.definesPresentationContext = true
        alert.delegate = self
        alert.gdo = gdoOption
        alert.restaurant = restaurantOption
        alert.distance = distanceOption
        alert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(alert, animated: true)
    }
    
    func showRestaurantPopover(_ identifier: String, _ fromList: Bool) {
        markerTapSemaphore.wait()
        guard let restaurant = getRestaurantByIdentifier(identifier), selectedSourceItems == nil, mapView.style?.source(withIdentifier: "selectedSourceItems") == nil else {
            markerTapSemaphore.signal()
            return
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        vcRestaurant = storyboard.instantiateViewController(withIdentifier: "TPRestaurantPopoverViewController") as! TPRestaurantPopoverViewController
        //vcMakeTransaction?.modalPresentationStyle = .popover
        vcRestaurant?.delegate = self
        vcRestaurant?.restaurant = restaurant
        //let h = self.tabBarController?.accessibilityFrame.height
        //let hh = self.tabBarController?.tabBar.frame.height
        vcRestaurant?.myLocation = myLocation
        definesPresentationContext = true
        vcRestaurant?.modalPresentationStyle = .overCurrentContext
        //mapView.compassView.isHidden = true
        popbckView?.showAlfaBackground(nil)
        //self.hidesBottomBarWhenPushed = true
        present(vcRestaurant!, animated: true, completion: nil)
        var ffeatures = [MGLPointFeature]()
        let feature = MGLPointFeature()
        let coordinate = CLLocationCoordinate2D(latitude: Double(restaurant.coordinates!.value(forKey: "lat") as! String)!, longitude: Double(restaurant.coordinates!.value(forKey: "long") as! String)!)
        feature.coordinate = coordinate
        feature.attributes["identifier"] = restaurant.identifier
        if restaurant.getPinType() == .OTHER {
            feature.attributes["icon"] = "map_pin_other_selected"
        }
        else {
            feature.attributes["icon"] = restaurant.getType() == .GDO ? "map_pin_gdo_selected" : "map_pin_selected"
        }
        feature.attributes["clickablePin"] = true
        feature.attributes["selected"] = true
        ffeatures.append(feature)
        selectedSourceItems = MGLShapeSource(identifier: "selectedSourceItems", features: ffeatures, options:[
            MGLShapeSourceOption.clustered: false,
            MGLShapeSourceOption.minimumZoomLevel: 9,
            MGLShapeSourceOption.maximumZoomLevel: 21])
        mapView.style?.addSource(selectedSourceItems!)
        
        selectedLayer = MGLSymbolStyleLayer(identifier: "selected", source: selectedSourceItems!)
        selectedLayer?.sourceLayerIdentifier = "sourceItems2"
        selectedLayer?.iconImageName = NSExpression(format: "icon")
        selectedLayer?.minimumZoomLevel = 9
        selectedLayer?.maximumZoomLevel = 21
        //unclusteredLayer.iconScale = NSExpression(forConstantValue: 0.5)
        selectedLayer!.iconAllowsOverlap = NSExpression(forConstantValue: true)
        mapView.style?.addLayer(selectedLayer!)
        //se da problemi presentarlo overCurrentContex e dalla tabbar
        //self.tabBarController?.present(vcMakeTransaction!, animated: true, completion: nil)
        markerTapSemaphore.signal()
        if fromList {
            let camera = MGLMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: Double(restaurant.coordinates!.value(forKey: "lat") as! String)!, longitude: Double(restaurant.coordinates!.value(forKey: "long") as! String)!), altitude: 1800, pitch: 15, heading: 0)
            mapView.setCamera(camera, withDuration: 0.2, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
        }
        else {
            let c = self.mapView.camera
            let maxAlt = CLLocationDistance(exactly:1800)!
            let altitude = c.altitude > maxAlt ? maxAlt : c.altitude
            let camera = MGLMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: Double(restaurant.coordinates!.value(forKey: "lat") as! String)!, longitude: Double(restaurant.coordinates!.value(forKey: "long") as! String)!), altitude: altitude, pitch: 15, heading: 0)
            mapView.fly(to: camera, withDuration: 0.6, completionHandler: nil)
        }
    }
    
    func showOrHideRestaurantList(){
        if viewForRestaurantsTableView != nil, viewForRestaurantsTableView!.isDescendant(of: self.view) {
            hideRestaurantList(true)
            //self.headerView.backgroundColor = .clear
        }
        else {
            self.showRestaurantList()
        }
    }
    
    func showRestaurantListIfHidden()-> Bool{
        if viewForRestaurantsTableView != nil, viewForRestaurantsTableView!.isDescendant(of: self.view) {
            return true
        }
        else {
            showRestaurantList()
            return true
        }
    }
    
    func getRestaurants(_ forceUpdate: Bool){
        TPContentManager.sharedInstance.visibleRestaurants({ (response: Int?, error: NetworkError?) in
            if let eerror = error {
                print("error getRestaurants \(eerror)")
                let alert = UIAlertController(title: ERRT_general, message: eerror.message ?? ERRM_general, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:L_Ok, style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.restaurants = TPContentManager.sharedInstance.getVisibleRestaurants()
                self.initFilteredRestaurants()
                self.mapView.style?.setImage(UIImage(named: "map_pin")!, forName: "map_pin")
                self.mapView.style?.setImage(#imageLiteral(resourceName: "map_pin_selected"), forName: "map_pin_selected")
                self.mapView.style?.setImage(#imageLiteral(resourceName: "map_pin_gdo"), forName: "map_pin_gdo")
                self.mapView.style?.setImage(#imageLiteral(resourceName: "map_pin_gdo_selected"), forName: "map_pin_gdo_selected")
                self.mapView.style?.setImage(#imageLiteral(resourceName: "map_pin_other"), forName: "map_pin_other")
                self.mapView.style?.setImage(#imageLiteral(resourceName: "map_pin_other_selected"), forName: "map_pin_other_selected")
                self.loadMap2(false)
            }
        }, forceUpdate)
    }
    
    internal func initFilteredRestaurants(){
        guard myLocation != nil else {
            filteredRestaurants = TPContentManager.sharedInstance.getVisibleRestaurants()
            if !gdoOption! || !restaurantOption! {
                filteredRestaurants = filteredRestaurants?.filter {
                    ($0.getType() == ESERCENTE_TYPE.GDO && gdoOption!) ||
                        ($0.getType() == ESERCENTE_TYPE.RISTORANTE && restaurantOption!)
                }
            }
            numberLabel?.text = "\(filteredRestaurants?.count ?? 0) esercizi disponibili"
            restaurantsTableView?.reloadData(with: .none)
            return
        }
        filteredRestaurants = TPContentManager.sharedInstance.getVisibleRestaurants()?.sorted(by: {
            guard let d1 = self.myLocation?.distance(from: CLLocation(latitude: Double($0.coordinates!.value(forKey: "lat") as! String)!, longitude: Double($0.coordinates!.value(forKey: "long") as! String)!)),
                let d2 = self.myLocation?.distance(from: CLLocation(latitude: Double($1.coordinates!.value(forKey: "lat") as! String)!, longitude: Double($1.coordinates!.value(forKey: "long") as! String)!)) else {return false}
            return d1 <= d2
        })
        if !gdoOption! || !restaurantOption! {
            filteredRestaurants = filteredRestaurants?.filter {
                ($0.getType() == ESERCENTE_TYPE.GDO && gdoOption!) ||
                    ($0.getType() == ESERCENTE_TYPE.RISTORANTE && restaurantOption!)
            }
        }
        restaurantsTableView?.reloadData(with: .none)
        numberLabel?.text = "\(filteredRestaurants?.count ?? 0) esercizi disponibili"
    }
    
    func loadMap2(_ fromFilter: Bool){
        guard mapView.style != nil, restaurants != nil else {
            return
        }
        if mapView.style!.source(withIdentifier: "gdoSourceItems") != nil || mapView.style!.source(withIdentifier: "restaurantSourceItems") != nil {
            guard fromFilter else { return }
            
            if restaurantOption!, !mapView.style!.layer(withIdentifier: "restaurant-unclustered")!.isVisible {
                mapView.style?.layer(withIdentifier: "restaurant-unclustered")?.isVisible = true
            }
            if gdoOption!, !mapView.style!.layer(withIdentifier: "gdo-unclustered")!.isVisible {
                mapView.style?.layer(withIdentifier: "gdo-unclustered")?.isVisible = true
            }
            /*for l in mapView.style!.layers {
             print("layer identifier \(l.identifier)")
             }*/
            if restaurantOption!, gdoOption! {
                mapView.style?.layer(withIdentifier: "gdo-cluster")?.isVisible = false
                mapView.style?.layer(withIdentifier: "restaurant-cluster")?.isVisible = false
                mapView.style?.layer(withIdentifier: "gdo-count")?.isVisible = false
                mapView.style?.layer(withIdentifier: "restaurant-count")?.isVisible = false
                mapView.style?.layer(withIdentifier: "gdo-cluster1")?.isVisible = false
                mapView.style?.layer(withIdentifier: "restaurant-cluster1")?.isVisible = false
                mapView.style?.layer(withIdentifier: "gdo-count1")?.isVisible = false
                mapView.style?.layer(withIdentifier: "restaurant-count1")?.isVisible = false
                mapView.style?.layer(withIdentifier: "cluster")?.isVisible = true
                mapView.style?.layer(withIdentifier: "count")?.isVisible = true
                mapView.style?.layer(withIdentifier: "cluster1")?.isVisible = true
                mapView.style?.layer(withIdentifier: "count1")?.isVisible = true
            }
            else if !restaurantOption!, gdoOption! {
                mapView.style?.layer(withIdentifier: "gdo-cluster")?.isVisible = true
                mapView.style?.layer(withIdentifier: "restaurant-cluster")?.isVisible = false
                mapView.style?.layer(withIdentifier: "gdo-count")?.isVisible = true
                mapView.style?.layer(withIdentifier: "restaurant-count")?.isVisible = false
                mapView.style?.layer(withIdentifier: "gdo-cluster1")?.isVisible = true
                mapView.style?.layer(withIdentifier: "restaurant-cluster1")?.isVisible = false
                mapView.style?.layer(withIdentifier: "gdo-count1")?.isVisible = true
                mapView.style?.layer(withIdentifier: "restaurant-count1")?.isVisible = false
                mapView.style?.layer(withIdentifier: "cluster")?.isVisible = false
                mapView.style?.layer(withIdentifier: "count")?.isVisible = false
                mapView.style?.layer(withIdentifier: "cluster1")?.isVisible = false
                mapView.style?.layer(withIdentifier: "count1")?.isVisible = false
            }
            else if restaurantOption!, !gdoOption! {
                mapView.style?.layer(withIdentifier: "gdo-cluster")?.isVisible = false
                mapView.style?.layer(withIdentifier: "restaurant-cluster")?.isVisible = true
                mapView.style?.layer(withIdentifier: "gdo-count")?.isVisible = false
                mapView.style?.layer(withIdentifier: "restaurant-count")?.isVisible = true
                mapView.style?.layer(withIdentifier: "gdo-cluster1")?.isVisible = false
                mapView.style?.layer(withIdentifier: "restaurant-cluster1")?.isVisible = true
                mapView.style?.layer(withIdentifier: "gdo-count1")?.isVisible = false
                mapView.style?.layer(withIdentifier: "restaurant-count1")?.isVisible = true
                mapView.style?.layer(withIdentifier: "cluster")?.isVisible = false
                mapView.style?.layer(withIdentifier: "count")?.isVisible = false
                mapView.style?.layer(withIdentifier: "cluster1")?.isVisible = false
                mapView.style?.layer(withIdentifier: "count1")?.isVisible = false
            }
            else{
                mapView.style?.layer(withIdentifier: "gdo-cluster")?.isVisible = false
                mapView.style?.layer(withIdentifier: "restaurant-cluster")?.isVisible = false
                mapView.style?.layer(withIdentifier: "gdo-count")?.isVisible = false
                mapView.style?.layer(withIdentifier: "restaurant-count")?.isVisible = false
                mapView.style?.layer(withIdentifier: "gdo-cluster1")?.isVisible = false
                mapView.style?.layer(withIdentifier: "restaurant-cluster1")?.isVisible = false
                mapView.style?.layer(withIdentifier: "gdo-count1")?.isVisible = false
                mapView.style?.layer(withIdentifier: "restaurant-count1")?.isVisible = false
                mapView.style?.layer(withIdentifier: "cluster")?.isVisible = true
                mapView.style?.layer(withIdentifier: "count")?.isVisible = true
                mapView.style?.layer(withIdentifier: "cluster1")?.isVisible = true
                mapView.style?.layer(withIdentifier: "count1")?.isVisible = true
            }
            print("rId \(rId)")
            if rId != nil {
                showRestaurantPopover(rId!, false)
                gdoOption = true
                restaurantOption = true
            }
            else {
                if !restaurantOption!, mapView.style!.layer(withIdentifier: "restaurant-unclustered")!.isVisible {
                    mapView.style?.layer(withIdentifier: "restaurant-unclustered")?.isVisible = false
                }
                if !gdoOption!, mapView.style!.layer(withIdentifier: "gdo-unclustered")!.isVisible {
                    mapView.style?.layer(withIdentifier: "gdo-unclustered")?.isVisible = false
                }
            }
            
            
            //            mapView.style?.layer(withIdentifier: "restaurant-unclustered")?.isVisible = restaurantOption ?? true
            //            mapView.style?.layer(withIdentifier: "gdo-unclustered")?.isVisible = gdoOption ?? true
            return
        }
        var gdoFeatures = [MGLPointFeature]()
        var restaurantsFeatures = [MGLPointFeature]()
        for restaurant in restaurants! {
            let feature = MGLPointFeature()
            let coordinate = CLLocationCoordinate2D(latitude: Double(restaurant.coordinates!.value(forKey: "lat") as! String)!, longitude: Double(restaurant.coordinates!.value(forKey: "long") as! String)!)
            feature.coordinate = coordinate
            feature.attributes["clickablePin"] = true
            feature.attributes["identifier"] = restaurant.identifier
            //feature.attributes["lat"] = restaurant.coordinates?.value(forKey:"lat")
            //feature.attributes["long"] = restaurant.coordinates?.value(forKey:"long")
            //feature.attributes["icon"] = restaurant.getType() == .GDO ? "map_pin_gdo" : "map_pin"
            feature.attributes["coordinates_range"] = 1//"0"
            feature.attributes["aaaaaname"] = 11
            if restaurant.getType() == .RISTORANTE {
                feature.attributes["icon"] = restaurant.getPinType() == .OTHER ? "map_pin_other" : "map_pin"
                feature.attributes["restaurant"] = true
                restaurantsFeatures.append(feature)
            }
            else {
                feature.attributes["icon"] = restaurant.getPinType() == .OTHER ? "map_pin_other" : "map_pin_gdo"
                feature.attributes["gdo"] = true
                //feature.attributes["clustering"] = gdoOption
                gdoFeatures.append(feature)
            }
            //ffeatures.append(feature)
        }
        guard restaurantsFeatures.count > 0 || gdoFeatures.count > 0 else { return }
        
        if gdoFeatures.count > 0, gdoOption ?? false {
            let gdoSourceItems = MGLShapeSource(identifier: "gdoSourceItems", features: gdoFeatures, options:[
                MGLShapeSourceOption.clustered: false,
                MGLShapeSourceOption.minimumZoomLevel: 9,
                MGLShapeSourceOption.maximumZoomLevel: 21])
            mapView.style?.addSource(gdoSourceItems)
            let gdoUnclusteredLayer = MGLSymbolStyleLayer(identifier: "gdo-unclustered", source: gdoSourceItems)
            gdoUnclusteredLayer.sourceLayerIdentifier = "gdoSourceItems"
            gdoUnclusteredLayer.iconImageName = NSExpression(format: "icon")
            gdoUnclusteredLayer.minimumZoomLevel = 10
            gdoUnclusteredLayer.maximumZoomLevel = 21
            //unclusteredLayer.iconScale = NSExpression(forConstantValue: 0.5)
            gdoUnclusteredLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
            gdoUnclusteredLayer.iconScale = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                                         [10.5: 0.82,
                                                          11.5: 0.88,
                                                          12.5: 0.94,
                                                          13.5: 1,
                                                          14.5: 1,
                                                          15.5: 1
            ])
            mapView.style?.addLayer(gdoUnclusteredLayer)
            
        }
        if restaurantsFeatures.count > 0, restaurantOption ?? false {
            let restaurantSourceItems = MGLShapeSource(identifier: "restaurantSourceItems", features: restaurantsFeatures, options:[
                MGLShapeSourceOption.clustered: false,
                MGLShapeSourceOption.minimumZoomLevel: 9,
                MGLShapeSourceOption.maximumZoomLevel: 21])
            mapView.style?.addSource(restaurantSourceItems)
            let restaurantUnclusteredLayer = MGLSymbolStyleLayer(identifier: "restaurant-unclustered", source: restaurantSourceItems)
            restaurantUnclusteredLayer.sourceLayerIdentifier = "restaurantSourceItems"
            restaurantUnclusteredLayer.iconImageName = NSExpression(format: "icon")
            //restaurantUnclusteredLayer.text = NSExpression(format: "CAST(aaaaaname, 'NSString')")//e
            restaurantUnclusteredLayer.minimumZoomLevel = 10
            restaurantUnclusteredLayer.maximumZoomLevel = 21
            //unclusteredLayer.iconScale = NSExpression(forConstantValue: 0.5)
            restaurantUnclusteredLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
            restaurantUnclusteredLayer.iconScale = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                                                [10.5: 0.82,
                                                                 11.5: 0.88,
                                                                 12.5: 0.94,
                                                                 13.5: 1,
                                                                 14.5: 1,
                                                                 15.5: 1
            ])
            mapView.style?.addLayer(restaurantUnclusteredLayer)
        }
        var features = [MGLPointFeature]()
        features.append(contentsOf: restaurantsFeatures)
        features.append(contentsOf: gdoFeatures)
        let sourceItems2 = MGLShapeSource(identifier: "sourceItems2", features: features, options: [
            MGLShapeSourceOption.clustered: true,
            MGLShapeSourceOption.clusterRadius: 40,
            MGLShapeSourceOption.minimumZoomLevel: 1,
            MGLShapeSourceOption.maximumZoomLevel: 10])
        mapView.style?.addSource(sourceItems2)
        let sourceItems3 = MGLShapeSource(identifier: "sourceItems3", features: restaurantsFeatures, options: [
            MGLShapeSourceOption.clustered: true,
            MGLShapeSourceOption.clusterRadius: 40,
            MGLShapeSourceOption.minimumZoomLevel: 1,
            MGLShapeSourceOption.maximumZoomLevel: 10])
        mapView.style?.addSource(sourceItems3)
        let sourceItems4 = MGLShapeSource(identifier: "sourceItems4", features: gdoFeatures, options: [
            MGLShapeSourceOption.clustered: true,
            MGLShapeSourceOption.clusterRadius: 40,
            MGLShapeSourceOption.minimumZoomLevel: 1,
            MGLShapeSourceOption.maximumZoomLevel: 10])
        mapView.style?.addSource(sourceItems4)
        
        let layer = MGLCircleStyleLayer(identifier: "cluster", source: sourceItems2)
        layer.sourceLayerIdentifier = "sourceItems2"
        layer.circleColor = NSExpression(forConstantValue: #colorLiteral(red: 0.94, green: 0.69, blue: 0.15, alpha: 1))
        layer.circleRadius = NSExpression(forConstantValue: 20)
        //        var p = NSCompoundPredicate(andPredicateWithSubpredicates: [
        //        NSPredicate(format: "coordinates_range == 1"),
        //        NSPredicate(format: "cluster == YES")])
        //        print("\(p.mgl_jsonExpressionObject)")
        layer.predicate = NSPredicate(format: "cluster == YES")
        layer.minimumZoomLevel = 1
        layer.maximumZoomLevel = 10
        mapView.style?.addLayer(layer)
        let gdoLayer = MGLCircleStyleLayer(identifier: "gdo-cluster", source: sourceItems4)
        gdoLayer.sourceLayerIdentifier = "sourceItems4"
        gdoLayer.circleColor = NSExpression(forConstantValue: #colorLiteral(red: 0.07, green: 0.40, blue: 0.18, alpha:1.0))
        gdoLayer.circleRadius = NSExpression(forConstantValue: 20)
        gdoLayer.predicate = NSPredicate(format: "cluster == YES")
        mapView.style?.addLayer(gdoLayer)
        gdoLayer.minimumZoomLevel = 1
        gdoLayer.maximumZoomLevel = 10
        gdoLayer.isVisible = false
        let restaurantLayer = MGLCircleStyleLayer(identifier: "restaurant-cluster", source: sourceItems3)
        restaurantLayer.sourceLayerIdentifier = "sourceItems3"
        restaurantLayer.circleColor = NSExpression(forConstantValue: #colorLiteral(red: 0.94, green: 0.69, blue: 0.15, alpha: 1))
        restaurantLayer.circleRadius = NSExpression(forConstantValue: 20)
        restaurantLayer.predicate = NSPredicate(format: "cluster == YES")
        mapView.style?.addLayer(restaurantLayer)
        restaurantLayer.minimumZoomLevel = 1
        restaurantLayer.maximumZoomLevel = 10
        restaurantLayer.isVisible = false
        //}
        
        let countLayer = MGLSymbolStyleLayer(identifier: "count", source: sourceItems2)
        countLayer.sourceLayerIdentifier = "sourceItems2"
        countLayer.textColor = NSExpression(forConstantValue: UIColor.white)
        //NSExpression(forFunction: "subtract:", arguments: [NSExpression(format: "CAST(point_count, 'NSString')")])
        let e = NSExpression(format: "aaaaaname")
        print("\(e.mgl_jsonExpressionObject)")
        countLayer.text = NSExpression(format: "CAST(point_count, 'NSString')")//e
        countLayer.textFontSize = NSExpression(forConstantValue: 15)
        countLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
        mapView.style?.addLayer(countLayer)
        countLayer.minimumZoomLevel = 1
        countLayer.maximumZoomLevel = 10
        
        let restaurantCountLayer = MGLSymbolStyleLayer(identifier: "restaurant-count", source: sourceItems3)
        restaurantCountLayer.sourceLayerIdentifier = "sourceItems3"
        restaurantCountLayer.textColor = NSExpression(forConstantValue: UIColor.white)
        restaurantCountLayer.text = NSExpression(format: "CAST(point_count, 'NSString')")
        restaurantCountLayer.textFontSize = NSExpression(forConstantValue: 15)
        restaurantCountLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
        mapView.style?.addLayer(restaurantCountLayer)
        restaurantCountLayer.isVisible = false
        restaurantCountLayer.minimumZoomLevel = 1
        restaurantCountLayer.maximumZoomLevel = 10
        
        let gdoCountLayer = MGLSymbolStyleLayer(identifier: "gdo-count", source: sourceItems4)
        gdoCountLayer.sourceLayerIdentifier = "sourceItems4"
        gdoCountLayer.textColor = NSExpression(forConstantValue: UIColor.white)
        gdoCountLayer.text = NSExpression(format: "CAST(point_count, 'NSString')")
        gdoCountLayer.textFontSize = NSExpression(forConstantValue: 15)
        gdoCountLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
        mapView.style?.addLayer(gdoCountLayer)
        gdoCountLayer.isVisible = false
        gdoCountLayer.minimumZoomLevel = 1
        gdoCountLayer.maximumZoomLevel = 10
        
        let countLayer1 = MGLSymbolStyleLayer(identifier: "count1", source: sourceItems2)
        countLayer1.sourceLayerIdentifier = "sourceItems2"
        countLayer1.textColor = NSExpression(forConstantValue: UIColor.white)
        countLayer1.text = NSExpression(forConstantValue: "1")
        countLayer1.textFontSize = NSExpression(forConstantValue: 15)
        countLayer1.predicate = NSPredicate(format: "cluster != YES")
        countLayer1.iconAllowsOverlap = NSExpression(forConstantValue: true)
        countLayer1.minimumZoomLevel = 1
        countLayer1.maximumZoomLevel = 10
        
        let gdoCountLayer1 = MGLSymbolStyleLayer(identifier: "gdo-count1", source: sourceItems4)
        gdoCountLayer1.sourceLayerIdentifier = "sourceItems4"
        gdoCountLayer1.isVisible = false
        gdoCountLayer1.textColor = NSExpression(forConstantValue: UIColor.white)
        gdoCountLayer1.text = NSExpression(forConstantValue: "1")
        gdoCountLayer1.textFontSize = NSExpression(forConstantValue: 15)
        gdoCountLayer1.predicate = NSPredicate(format: "cluster != YES")
        gdoCountLayer1.iconAllowsOverlap = NSExpression(forConstantValue: true)
        gdoCountLayer1.minimumZoomLevel = 1
        gdoCountLayer1.maximumZoomLevel = 10
        let gdoLayer1 = MGLCircleStyleLayer(identifier: "gdo-cluster1", source: sourceItems4)
        gdoLayer1.sourceLayerIdentifier = "sourceItems4"
        gdoLayer1.circleColor = NSExpression(forConstantValue: #colorLiteral(red: 0.07, green: 0.40, blue: 0.18, alpha:1.0))
        gdoLayer1.circleRadius = NSExpression(forConstantValue: 20)
        gdoLayer1.predicate = NSPredicate(format: "cluster != YES")
        gdoLayer1.isVisible = false
        gdoLayer1.minimumZoomLevel = 1
        gdoLayer1.maximumZoomLevel = 10
        mapView.style?.addLayer(gdoLayer1)
        mapView.style?.addLayer(gdoCountLayer1)
        
        let restaurantCountLayer1 = MGLSymbolStyleLayer(identifier: "restaurant-count1", source: sourceItems3)
        restaurantCountLayer1.sourceLayerIdentifier = "sourceItems3"
        restaurantCountLayer1.isVisible = false
        restaurantCountLayer1.textColor = NSExpression(forConstantValue: UIColor.white)
        restaurantCountLayer1.text = NSExpression(forConstantValue: "1")
        restaurantCountLayer1.textFontSize = NSExpression(forConstantValue: 15)
        restaurantCountLayer1.predicate = NSPredicate(format: "cluster != YES")
        restaurantCountLayer1.iconAllowsOverlap = NSExpression(forConstantValue: true)
        restaurantCountLayer1.minimumZoomLevel = 1
        restaurantCountLayer1.maximumZoomLevel = 10
        let restaurantLayer1 = MGLCircleStyleLayer(identifier: "restaurant-cluster1", source: sourceItems3)
        restaurantLayer1.sourceLayerIdentifier = "sourceItems3"
        restaurantLayer1.circleColor = NSExpression(forConstantValue: #colorLiteral(red: 0.94, green: 0.69, blue: 0.15, alpha: 1))
        restaurantLayer1.circleRadius = NSExpression(forConstantValue: 20)
        restaurantLayer1.predicate = NSPredicate(format: "cluster != YES")
        restaurantLayer1.isVisible = false
        restaurantLayer1.minimumZoomLevel = 1
        restaurantLayer1.maximumZoomLevel = 10
        mapView.style?.addLayer(restaurantLayer1)
        mapView.style?.addLayer(restaurantCountLayer1)
        
        let layer1 = MGLCircleStyleLayer(identifier: "cluster1", source: sourceItems2)
        layer1.sourceLayerIdentifier = "sourceItems2"
        //layer.sourceLayerIdentifier = "HPC_landmarks-b60kqn"
        layer1.circleColor = NSExpression(forConstantValue: #colorLiteral(red: 0.94, green: 0.69, blue: 0.15, alpha: 1))
        layer1.circleRadius = NSExpression(forConstantValue: 20)
        layer1.predicate = NSPredicate(format: "cluster != YES")
        layer1.minimumZoomLevel = 1
        layer1.maximumZoomLevel = 10
        mapView.style?.addLayer(layer1)
        mapView.style?.addLayer(countLayer1)
        print("rId \(rId)")
        if let r = rId {
            showRestaurantPopover(r, false)
            gdoOption = true
            restaurantOption = true
            rId = nil
        }
        else if myLocation != nil {
            centerToMyLocation(false)
        }
        else if CLLocationManager.locationServicesEnabled(), (CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined) {
            var coordinates = [CLLocationCoordinate2D]()
            for restaurant in restaurants! {
                coordinates.append(CLLocationCoordinate2D(latitude: Double(restaurant.coordinates!.value(forKey: "lat") as! String)!, longitude: Double(restaurant.coordinates!.value(forKey: "long") as! String)!))
            }
            let bounds = MGLPolygon(coordinates: coordinates, count: UInt(coordinates.count)).overlayBounds
            mapView.fly(to: mapView.cameraThatFitsCoordinateBounds(bounds, edgePadding: UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)), withDuration: 0.6, completionHandler: nil)
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.centerToMyLocation(false)
            })
        }
        //        countLayer.textFontSize = NSExpression(forConstantValue: NSNumber(value: Double(icon.size.width) / 2))
    }
    
    func hideRestaurantList(_ animation: Bool){
        if viewForRestaurantsTableView != nil, viewForRestaurantsTableView!.isDescendant(of: self.view) {
            self.searchBar.text = nil
            self.searchBar.resignFirstResponder()
            for subView in self.searchBar.subviews[0].subviews where subView is UITextField {
                subView.resignFirstResponder()
            }
            if animation {
                UIView.animate(withDuration: 0.6, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.viewForRestaurantsTableView!.frame.origin.x = self.view.frame.width
                }, completion:{(finished: Bool) in
                    //self.headerView.backgroundColor = .white
                    self.viewForRestaurantsTableView!.removeFromSuperview()
                })
            }
            else {
                self.viewForRestaurantsTableView!.removeFromSuperview()
            }
        }
        //resetCompassView()
    }
    
    func hideRestaurantListAndShowMarkerOnMapFromList(_ identifier: String){
        if viewForRestaurantsTableView != nil, viewForRestaurantsTableView!.isDescendant(of: self.view) {
            UIView.animate(withDuration: 0.6, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.viewForRestaurantsTableView!.frame.origin.x = self.view.frame.width
            }, completion:{(finished: Bool) in
                //self.headerView.backgroundColor = .white
                self.searchBar.text = nil
                self.searchBar.resignFirstResponder()
                for subView in self.searchBar.subviews[0].subviews where subView is UITextField {
                    subView.resignFirstResponder()
                }
                self.viewForRestaurantsTableView!.removeFromSuperview()
                self.showMarkerOnMapFromList(identifier)
            })
        }
        //resetCompassView()
    }
    
    func showMarkerOnMapFromList(_ identifier: String){
        viewForRestaurantsTableView!.removeFromSuperview()
        //let camera = MGLMapCamera(lookingAtCenter: m.coordinate, altitude: 1800, pitch: 15, heading: 0)
        //self.mapView.setCamera(camera, withDuration: 0.2, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
        showRestaurantPopover(identifier, true)
    }
    
    func showRestaurantList(){
        viewForRestaurantsTableView = UIView(frame: CGRect(x: view.frame.size.width, y: mapView.frame.origin.y, width: view.frame.size.width, height: mapView.frame.size.height))
        let yy = headerView2.frame.origin.y > searchBar.frame.origin.y + searchBar.frame.size.height ?
            headerView2.frame.origin.y : searchBar.frame.origin.y + searchBar.frame.size.height
        let diff =  yy - headerView2.frame.origin.y
        numberLabel = UILabel(frame: CGRect(x: 0, y: yy, width: view.frame.size.width-10, height: 24))
        restaurantsTableView = UITableView(frame: CGRect(x: 0, y: yy + numberLabel!.frame.size.height+8, width: view.frame.size.width, height: mapView.frame.size.height-mapView.frame.origin.y - diff - 8))
        numberLabel?.textColor = .lightGray
        numberLabel?.font = numberLabel?.font.withSize(17)
        numberLabel?.textAlignment = .right
        //numberLabel?.translatesAutoresizingMaskIntoConstraints = false
        viewForRestaurantsTableView?.backgroundColor = .white
        viewForRestaurantsTableView?.isOpaque = false
        viewForRestaurantsTableView?.layer.backgroundColor = UIColor.white.cgColor
        if viewForRestaurantsTableView!.isDescendant(of: view) {
            viewForRestaurantsTableView!.removeFromSuperview()
        }
        initFilteredRestaurants()
        if filteredRestaurants != nil, filteredRestaurants!.count>0 {
            numberLabel?.text = "\(filteredRestaurants!.count) esercizi disponibili"
        }
        restaurantsTableView?.dataSource = self
        restaurantsTableView?.delegate = self
        restaurantsTableView?.sectionHeaderHeight = 0
        restaurantsTableView?.estimatedSectionHeaderHeight = 0
        restaurantsTableView?.translatesAutoresizingMaskIntoConstraints = false
        restaurantsTableView?.backgroundColor = .clear
        restaurantsTableView?.isUserInteractionEnabled = true
        restaurantsTableView?.contentInsetAdjustmentBehavior = .never // workaround for opaque navigation bar behavior
        // Register table cell class from nib
        let cellNib = UINib(nibName: reuId_restaurant_cell, bundle: nil)
        restaurantsTableView?.register(cellNib, forCellReuseIdentifier: reuId_restaurant_cell)
        restaurantsTableView?.separatorStyle = .none
        restaurantsTableView?.rowHeight = UITableViewAutomaticDimension
        restaurantsTableView?.estimatedRowHeight = RESTAURANT_CELL_HEIGHT
        //headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView2.translatesAutoresizingMaskIntoConstraints = false
        for subView in headerView2.subviews { //where subView is UITextField {
            subView.translatesAutoresizingMaskIntoConstraints = false
        }
        viewForRestaurantsTableView!.addSubview(numberLabel!)
        viewForRestaurantsTableView!.addSubview(restaurantsTableView!)
        view.insertSubview(viewForRestaurantsTableView!, belowSubview: headerView2!)
        viewForRestaurantsTableView?.topAnchor.constraint(equalTo: headerView2.topAnchor).isActive = true
        let c = mapView.camera
        let camera = MGLMapCamera(lookingAtCenter: c.centerCoordinate, altitude: c.altitude, pitch: c.pitch, heading: 0)
        mapView.setCamera(camera, withDuration: 0.1, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
        
        //mapView.compassView.isHidden = true
        UIView.animate(withDuration: 0.6, animations: {
            self.viewForRestaurantsTableView!.frame.origin.x = 0
        }, completion:{(finished: Bool) in
            //self.headerView.backgroundColor = .white
        })
    }
    
    func centerToMyLocation(_ force: Bool){
        if force, myLocation != nil{
            centerdOnMyPosition = true
            let camera = MGLMapCamera(lookingAtCenter: myLocation!.coordinate, altitude: 2000, pitch: 15, heading: 0)
            mapView.fly(to: camera, withDuration: 0.6, completionHandler: nil)
            
            //self.mapView.setCamera(camera, withDuration: 0.4, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
            return
        }
        guard !centerdOnMyPosition, myLocation != nil else {
            return
        }
        centerdOnMyPosition = true
        let camera = MGLMapCamera(lookingAtCenter: myLocation!.coordinate, altitude: 2500, pitch: 15, heading: 0)
        mapView.fly(to: camera, withDuration: 1.4, completionHandler: nil)
        //self.mapView.setCamera(camera, withDuration: 0.4, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
        // self.mapView.animate(with: GMSCameraUpdate.setTarget(myLocation!.coordinate, zoom: 17))
    }
    
    
    func resetCompassView(){
        mapView.compassView.isHidden = false
        let radians = atan2(mapView.compassView.transform.b, mapView.compassView.transform.a)
        //let degrees = radians * 180 / .pi
        mapView.compassView.layer.transform = CATransform3DConcat(mapView.compassView.layer.transform, CATransform3DMakeRotation(radians,1.0,0.0,0.0))
        mapView.compassView.frame = CGRect(x: 12, y: mapView.frame.height-ini-1, width: 40, height: 40)
        mapView.compassView.setNeedsLayout()
    }
    
    func resetOptions(){
        gdoOption = true
        restaurantOption = true
        distanceOption = 4
    }
}


// MARK: - LocationManagerDelegate extension

extension MapViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let l  = manager.location else { return }
//        //guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        //print("locations = \(locValue.latitude) \(locValue.longitude)")
//        myLocation = l
//        if !centerdOnMyPosition {
//            centerToMyLocation(false)
//        }
//        vcRestaurant?.setMyLocation(l)
    }
}

// MARK: - UISearchBarDelegate extension

extension MapViewController : UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        showRestaurantListIfHidden()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            initFilteredRestaurants()
        }
        else {
            let asyncSearchText = searchText
            DispatchQueue.global(qos: .userInitiated).async(execute: {
                let searchTextArr = asyncSearchText.split(separator: " ")
                let asyncFilteredRestaurants = (self.restaurants?.filter { restaurant in
                    for token in searchTextArr {
                        if restaurant.name.localizedStandardContains(token) {
                            return true
                        }
                        if restaurant.shopName != nil {
                            if ((restaurant.shopName!.localizedStandardContains(token))) {
                                return true
                            }
                        }
                        if restaurant.address != nil {
                            if ((restaurant.address!.localizedStandardContains(token))) {
                                return true
                            }
                        }
                        if restaurant.city != nil {
                            if ((restaurant.city!.localizedStandardContains(token))) {
                                return true
                            }
                        }
                    }
                    return false
                })!
                DispatchQueue.main.async(execute: {
                    self.filteredRestaurants = asyncFilteredRestaurants
                    self.numberLabel?.text = "\(self.filteredRestaurants?.count) esercizi disponibili"
                    self.restaurantsTableView?.reloadData()
                    if self.filteredRestaurants!.count > 0 {
                        self.restaurantsTableView?.scrollToRow(at: IndexPath.init(row: 0, section: 0),
                                                               at: UITableView.ScrollPosition.top,
                                                               animated: true)
                    }
                })
            })
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

// MARK: - TPRestaurantPopoverDelegate extension

extension MapViewController : TPRestaurantPopoverDelegate {
    func present(_ vc: UIViewController, animated: Bool) {
        present(vc, animated: animated, completion: nil)
    }
    
    func back() {
        markerTapSemaphore.wait()
        //resetCompassView()
        if selectedLayer != nil {
            mapView.style?.removeLayer(selectedLayer!)
        }
        if selectedSourceItems != nil {
            mapView.style?.removeSource(selectedSourceItems!)
        }
        selectedLayer = nil
        selectedSourceItems = nil
        markerTapSemaphore.signal()
        vcRestaurant?.removeFromParentViewController()
        self.popbckView?.removeAlfaBackground()
    }
    
    func dismiss(){
        applicationWillResignActive()
    }
    
}


// MARK: - UITableViewDelegate UITableViewDataSource extension

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData: Restaurant = filteredRestaurants![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuId_restaurant_cell, for: indexPath) as! RestaurantCell
        cell.nameLabel.text = cellData.getNameOf(true)
        cell.addressLabel.text = cellData.address!
        cell.cityLabel.text = cellData.city
        //TODO wait openStatus
//        switch cellData.openStatus ?? 0 {
//            case 1: //opened
//                cell.openLabel.text = "Aperto"
//                cell.openLabel.textColor = .customGreenColor
//            case 2: //closed
//                cell.openLabel.text = "Chiuso"
//                cell.openLabel.textColor = .customRedColor
//            default:
//                cell.openLabel.text = "-"
//                cell.openLabel.textColor = .darkGray
//        }
        
        calculateWalkingDistance(cell.distanceLabel, cellData.coordinates)
        cell.iimageView.layer.cornerRadius = cell.iimageView.frame.size.width/2
        cell.iimageView.clipsToBounds = true
        if cellData.name.lowercased() == "bar clikapp" {
            cell.iimageView.image = #imageLiteral(resourceName: "bar_clikapp")
        }
        else {
            cell.iimageView.image = nil
            if cellData.imageUrl != nil {
                if cellData.imageUrl!.starts(with: "http"), let url = URL(string: cellData.imageUrl!) {
                    downloadPhoto(url, cell.iimageView)
                }
                else if let url = TPClientApi.sharedInstance.getUnitPictureUrl(cellData.identifier, cellData.imageUrl!) {
                    downloadPhoto(url, cell.iimageView)
                }
                else {
                    cell.iimageView.image = #imageLiteral(resourceName: "img_placeholder")
                }
            }
            else{
                cell.iimageView.image = #imageLiteral(resourceName: "img_placeholder")

//                loadPhotoUrl(nil, (cellData.shopName ?? cellData.name) + "," + cellData.address! + "," + cellData.city!, cell.iimageView)
            }
        }
        cell.selectionStyle = .default
        if cell.stackView.frame.height > (cell.iimageView.constraint(withIdentifier: "height")?.constant ?? 0) + 10 {
            print("fix constraint 1 for \(cellData.getNameOf(true)) \(cell.stackView.frame.height) \(cell.iimageView.frame.height) \(cell.iimageView.constraint(withIdentifier: "height")?.constant)")
            if cell.innerView.constraint(withIdentifier: "topToStackView")?.priority != UILayoutPriority(rawValue: 1000){
                print("fix constraint 11 for \(cellData.getNameOf(true)) \(cell.stackView.frame.height) \(cell.iimageView.frame.height) \(cell.iimageView.constraint(withIdentifier: "height")?.constant)")
                cell.innerView.constraint(withIdentifier: "topToStackView")?.priority = UILayoutPriority(rawValue: 1000)
                cell.innerView.constraint(withIdentifier: "topToImageView")?.priority = UILayoutPriority(rawValue: 250)
                cell.innerView.layoutSubviews()
            }
        }
        else{
            print("fix constraint 2 for \(cellData.getNameOf(true))")
            if cell.innerView.constraint(withIdentifier: "topToImageView")!.priority != UILayoutPriority(rawValue: 1000){
                print("fix constraint 22 for \(cellData.getNameOf(true)) \(cell.stackView.frame.height) \(cell.iimageView.frame.height) \(cell.iimageView.constraint(withIdentifier: "height")?.constant)")
                cell.innerView.constraint(withIdentifier: "topToStackView")?.priority = UILayoutPriority(rawValue: 250)
                cell.innerView.constraint(withIdentifier: "topToImageView")?.priority = UILayoutPriority(rawValue: 1000)
                cell.innerView.layoutSubviews()
            }
        }
        return cell
    }
    
    func calculateWalkingDistance(_ label: UILabel, _ coordinates: NSDictionary?){
        /*
         guard let loc = myLocation, coordinates != nil else {
            label.text = "-"
            return
        }
        let origin : [String: String] = [
            "lat" : String(loc.coordinate.latitude),
            "long" : String(loc.coordinate.longitude)
        ]
        let destination : [String: String] = [
            "lat": coordinates!["lat"] as! String,
            "long": coordinates!["long"] as! String
        ]
        MapsClientApi.sharedInstance.walkingDistanceMapbox(origin: origin, destination: destination, completion: { (response: [String: Any]?, error: NetworkError?) in
            print("completion returned")
            label.text = response?["distance"] as? String ?? "-"
            
        })
         */
        
        // switch of the main thread
        DispatchQueue.global(qos: .userInitiated).async(execute: {
            
            guard let loc = myLocation, coordinates != nil, let lat = CLLocationDegrees(coordinates!["lat"] as! String), let long = CLLocationDegrees(coordinates!["long"] as! String) else {
                
                // go back to main thread to uodate the UI
                DispatchQueue.main.async(execute: {
                    
                    label.text = "-"

                    // you might have to call "setNeedsLayout()" to get the cell updated
                    // if so, add a parameter "cell" to this function call and use it like
                    // cell.setNeedsLayout()

                })
                return
            }
            
            let distance = loc.distance(from: CLLocation(latitude: lat, longitude: long))
            
            let labelText = distance > 1000 ? String(format: "%.0f", locale: Locale.current, (distance/1000).rounded(.down)) + " km " + String(format: "%.0f", locale: Locale.current, (distance.truncatingRemainder(dividingBy: 1000)).rounded(.down)) + " m " : String(format: "%.1f", locale: Locale.current, distance) + " m"
            
            
            DispatchQueue.main.async(execute: {
                
                label.text = labelText
                
                // you might have to call "setNeedsLayout()" to get the cell updated
                // if so, add a parameter "cell" to this function call and use it like
                // cell.setNeedsLayout()

            })
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredRestaurants?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = self.filteredRestaurants![indexPath.row]
        self.hideRestaurantListAndShowMarkerOnMapFromList(cellData.identifier)
        //self.showMarkerOnMapFromList(cellData.email)
    }
    
    
//    func loadPhotoUrl(_ restaurant: Restaurant?, _ input : String, _ imageView : UIImageView){
//        MapsClientApi.sharedInstance.findPlaceFromText(input: input, completion: {(response : [String:Any]?, error: NetworkError?) in
//            guard response != nil && response!["photoUrl"] != nil, let url = URL(string: response!["photoUrl"] as! String) else{
//                imageView.image = #imageLiteral(resourceName: "img_placeholder")
//                //imageView.layer.cornerRadius = imageView.frame.size.width/2
//                return
//            }
//            restaurant?.imageUrl = url.absoluteString
//            self.downloadPhoto(url, imageView)
//        })
//    }
    
    func downloadPhoto(_ url : URL, _ imageView : UIImageView){
        
        // switch of the main thread
        DispatchQueue.global(qos: .userInitiated).async(execute: {
            
            TPSDWebImageManager.downloadImage(fromUrl: url, {(image, error, cache) in
                
                DispatchQueue.main.async {
                    imageView.image = image ?? #imageLiteral(resourceName: "img_placeholder")
                    //imageView.layer.cornerRadius = imageView.frame.size.width/2
                }
            })
        })
    }
    
    internal func getRestaurantByEmail(_ email: String?) -> Restaurant?{
        guard email != nil else {
            return nil
        }
        if restaurants == nil {
            restaurants = TPContentManager.sharedInstance.getVisibleRestaurants()
        }
        if restaurants == nil {
            return nil
        }
         return restaurants!.filter({( r: Restaurant) in
            return r.email == email
        }).first
    }
    
    internal func getRestaurantByIdentifier(_ identifier: String?) -> Restaurant?{
        guard identifier != nil else {
            return nil
        }
        if restaurants == nil {
            restaurants = TPContentManager.sharedInstance.getVisibleRestaurants()
        }
        guard restaurants != nil else {
            return nil
        }
        return restaurants!.filter({( r: Restaurant) in
            return r.identifier == identifier
        }).first
//        for r in restaurants! {
//            guard r.identifier == identifier else { continue }
//            return r
//        }
//        return nil
    }
}

extension MapViewController : UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        view.endEditing(true)
        if scrollView.isDragging {
            searchBar.endEditing(true)
        }
    }
}


extension MapViewController : MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        if annotation is MGLUserLocation && mapView.userLocation != nil {
            return CustomUserLocationAnnotationView()
        }
        //        guard let _ = annotation as? MyPointAnnotation else {
        //            return nil
        //        }
        
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always not allow callouts to popup when annotations are tapped.
        return false
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        
    }
    
    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        mapView.style?.setImage(UIImage(named: "map_pin")!, forName: "map_pin")
        mapView.style?.setImage(#imageLiteral(resourceName: "map_pin_selected"), forName: "map_pin_selected")
        mapView.style?.setImage(#imageLiteral(resourceName: "map_pin_gdo"), forName: "map_pin_gdo")
        mapView.style?.setImage(#imageLiteral(resourceName: "map_pin_gdo_selected"), forName: "map_pin_gdo_selected")
        self.loadMap2(false)
    }
}

extension MapViewController : LifeCycleVCProtocol{
    func applicationWillResignActive(){
        centerdOnMyPosition = false
        hideRestaurantList(false)
        vcRestaurant?.dismiss()
        centerToMyLocation(false)
    }
}

class CustomUserLocationAnnotationView: MGLUserLocationAnnotationView {
    let size: CGFloat = 30
    var dot: CALayer!
    var arrow: CAShapeLayer!
    
    // -update is a method inherited from MGLUserLocationAnnotationView. It updates the appearance of the user location annotation when needed. This can be called many times a second, so be careful to keep it lightweight.
    override func update() {
        if frame.isNull {
            frame = CGRect(x: 0, y: 0, width: size, height: size)
            isUserInteractionEnabled = false
            return setNeedsLayout()
        }
        
        // Check whether we have the user’s location yet.
        if CLLocationCoordinate2DIsValid(userLocation!.coordinate) {
            setupLayers()
            updateHeading()
        }
    }
    
    private func updateHeading() {
        // Show the heading arrow, if the heading of the user is available.
        if let heading = userLocation!.heading?.trueHeading {
            arrow.isHidden = false
            
            // Get the difference between the map’s current direction and the user’s heading, then convert it from degrees to radians.
            let rotation: CGFloat = -MGLRadiansFromDegrees(mapView!.direction - heading)
            
            // If the difference would be perceptible, rotate the arrow.
            if abs(rotation) > 0.01 {
                // Disable implicit animations of this rotation, which reduces lag between changes.
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                arrow.setAffineTransform(CGAffineTransform.identity.rotated(by: rotation))
                CATransaction.commit()
            }
        } else {
            arrow.isHidden = true
        }
    }
    
    private func setupLayers() {
        // This dot forms the base of the annotation.
        if dot == nil {
            dot = CALayer()
            dot.bounds = CGRect(x: 0, y: 0, width: size, height: size)
            
            // Use CALayer’s corner radius to turn this layer into a circle.
            dot.cornerRadius = size / 2
            dot.backgroundColor = UIColor(red:0.08, green:0.47, blue:0.75, alpha:0.5).cgColor
            dot.borderWidth = 2
            dot.zPosition = 0
            dot.borderColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.5).cgColor
            layer.addSublayer(dot)
        }
        
        // This arrow overlays the dot and is rotated with the user’s heading.
        if arrow == nil {
            arrow = CAShapeLayer()
            arrow.path = arrowPath()
            arrow.frame = CGRect(x: 0, y: 0, width: size / 2, height: size / 2)
            arrow.position = CGPoint(x: dot.frame.midX, y: dot.frame.midY)
            arrow.fillColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.8).cgColor
            layer.addSublayer(arrow)
        }
    }
    
    // Calculate the vector path for an arrow, for use in a shape layer.
    private func arrowPath() -> CGPath {
        let max: CGFloat = size / 2
        let pad: CGFloat = 3
        
        let top =    CGPoint(x: max * 0.5, y: 0)
        let left =   CGPoint(x: 0 + pad,   y: max - pad)
        let right =  CGPoint(x: max - pad, y: max - pad)
        let center = CGPoint(x: max * 0.5, y: max * 0.6)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: top)
        bezierPath.addLine(to: left)
        bezierPath.addLine(to: center)
        bezierPath.addLine(to: right)
        bezierPath.addLine(to: top)
        bezierPath.close()
        return bezierPath.cgPath
    }
}

extension MapViewController : MapFilterModalViewControllerDelegate{
    func values(_ gdo: Bool, _ restaurants: Bool, _ distance: Int) {
        self.gdoOption = gdo
        self.restaurantOption = restaurants
        //self.distanceOption = distance
        self.initFilteredRestaurants()
        if !gdoOption! || !restaurantOption! {
            self.viewSettingsEnabled?.isHidden = false
        }
        else {
            self.viewSettingsEnabled?.isHidden = true
        }
        if filteredRestaurants?.count == 0 {
            let alert = UIAlertController(title: T_general, message: "La ricerca non ha prodotto alcun risultato, ricontrolla i filtri", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: L_Ok, style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        self.loadMap2(true)
    }
    
    func reset(){
        self.resetOptions()
        self.initFilteredRestaurants()
        self.viewSettingsEnabled?.isHidden = true
        if filteredRestaurants?.count == 0 {
            let alert = UIAlertController(title: T_general, message: "La ricerca non ha prodotto alcun risultato, ricontrolla i filtri", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: L_Ok, style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        self.loadMap2(true)
    }
}
