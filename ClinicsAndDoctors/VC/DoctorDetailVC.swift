//
//  DoctorDetailVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 06/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import MapKit
import Cosmos
import NVActivityIndicatorView

class DoctorDetailVC: UIViewController {
  @IBOutlet weak var loadingIm:UIImageView!
  @IBOutlet weak var doctorAvatarIm:RoundedImageView!
  @IBOutlet weak var nameLb:UILabel!
  @IBOutlet weak var especialityLb:UILabel!
  @IBOutlet weak var phoneBt:UIButton!
  @IBOutlet weak var addFavoriteBt:UIButton!
  @IBOutlet weak var rateView: CosmosView!
  @IBOutlet weak var ubicBtn: RoundedButton!
  @IBOutlet weak var clinicBtn: RoundedButton!
  @IBOutlet weak var seeReviewsBtn: UIButton!
  
  var rMenuBtnVisible = true
  var docId = ""
  
  func translateStaticInterface(){
    seeReviewsBtn.setTitle("Reviews".localized, for: .normal)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    translateStaticInterface()
    CreateGradienBackGround(view: self.view)
    
    seeReviewsBtn.underlined()
    
    self.addFavoriteBt.setImage(UIImage(named:"ic_fav_off"), for: .normal)
    self.addFavoriteBt.setImage(UIImage(named:"ic_favorite_profile"), for: .selected)
  }
  
  internal func updateWith(doctor: DoctorModel){
    
    if let url = URL(string: doctor.profile_picture){
      self.doctorAvatarIm.url = url
    }
    
    self.nameLb.text = doctor.full_name
    self.rateView.rating = doctor.rating
    
    let type = doctor.dtype.isEmpty ? "" : "\(doctor.dtype!) - "
    
    self.especialityLb.text = ""
    if let esp = SpecialityModel.by(id: doctor.idSpecialty){
      self.especialityLb.text = type + esp.name
    }
    else {
      self.especialityLb.text = doctor.dtype
    }
    
    if let clinic = ClinicModel.by(id: doctor.idClinic) {
      clinicBtn.isHidden = false
      clinicBtn.setTitle(clinic.full_name , for: .normal)
    }else{
      clinicBtn.isHidden = true
    }
    
    self.phoneBt.isHidden = doctor.phone_number.isEmpty
    self.addFavoriteBt.isSelected = UserModel.currentUser != nil && doctor.is_favorite
    self.clinicBtn.isHidden = !rMenuBtnVisible
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.isHidden = false
    
    if let doctor = DoctorModel.by(id: self.docId){
      self.updateWith(doctor: doctor)
    }
    
  }
  
  
  @IBAction private func BackView(_ sender: AnyObject){
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction private func phoneBtnAction(_ sender: Any) {
    guard let doctor = DoctorModel.by(id: self.docId) else { return }
    var strPhoneNumber = doctor.phone_number!
    strPhoneNumber = strPhoneNumber.replacingOccurrences(of: " ", with: "")
    strPhoneNumber = strPhoneNumber.replacingOccurrences(of: "-", with: "")
    
    if let phoneCallURL:URL = URL(string: "tel:\(strPhoneNumber)") {
      let application:UIApplication = UIApplication.shared
      if (application.canOpenURL(phoneCallURL)) {
        let alertController = UIAlertController(title: "Click Doc", message: "Are you sure you want to call".localized + " \n\(doctor.phone_number!)?", preferredStyle: .alert)
        let yesPressed = UIAlertAction(title: "Yes".localized, style: .default, handler: { (action) in
          UIApplication.shared.openURL(phoneCallURL)
        })
        let noPressed = UIAlertAction(title: "No".localized, style: .default, handler: { (action) in
          
        })
        alertController.addAction(yesPressed)
        alertController.addAction(noPressed)
        present(alertController, animated: true, completion: nil)
      }
    }
    
  }
  
  @IBAction private func gotoClinicAction(_ sender: Any) {
    self.performSegue(withIdentifier: "toClinicDetails", sender: nil)
  }
}



// ==========================================
// MARK: - Navigation
// ==========================================

extension DoctorDetailVC {
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == "toClinicDetails" {
      let vc:ClinincDetailVC = segue.destination as! ClinincDetailVC
      if let doctor = DoctorModel.by(id: self.docId){
        vc.clinicId = doctor.idClinic
      }
      
    }else if segue.identifier == "toReviews" {
      let vc:ReviewsVC = segue.destination as! ReviewsVC
      vc.docId = self.docId
      
    }else if segue.identifier == "toRating" {
      let vc:RatingVC = segue.destination as! RatingVC
      vc.doctorId = self.docId
    }
    
  }
  
  
  
  
}



// ==========================================
// MARK: - RMenu
// ==========================================

extension DoctorDetailVC {
  
  
  //    @IBAction func rateBtnAction(_ sender: Any) {
  //
  //        if UserModel.currentUser != nil {
  //            self.performSegue(withIdentifier: "toRating", sender: nil)
  //        }
  //        else{
  //
  //            self.SwiftMessageAlert(layout: .cardView, theme: .info, title: "Click Doc", body: "Must be logged in first".localized)
  //
  //            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {[weak self] in
  //                let storyboard = UIStoryboard(name: "Main", bundle: nil)
  //                let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! ViewController
  //                vc.futureVC = "RatingVC"
  //                vc.futureDoctorId = self?.docId
  //
  //                self?.navigationController?.pushViewController(vc,
  //                                                               animated: true)
  //            })
  //
  //        }
  //    }
  
}



// ==========================================
// MARK: - Favorites
// ==========================================

extension DoctorDetailVC {


    func openInIosMaps(){

        guard let doctor = DoctorModel.by(id: self.docId) else { return }
        guard let clinic = ClinicModel.by(id: doctor.idClinic) else { return }

        let pos = CLLocationCoordinate2DMake(clinic.latitude, clinic.longitude)

        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(pos.latitude, pos.longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = doctor.full_name + "\n" + clinic.full_name
        mapItem.openInMaps(launchOptions: options)
    }

    func openGoogleMaps() {
        guard let doctor = DoctorModel.by(id: self.docId) else { return }
        guard let clinic = ClinicModel.by(id: doctor.idClinic) else { return }

        let pos = CLLocationCoordinate2DMake(clinic.latitude, clinic.longitude)
        UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(pos.latitude),\(pos.longitude)&zoom=14&views=traffic&q=\(pos.latitude),\(pos.longitude)")!, options: [:], completionHandler: nil)
    }

    func openMapAction() {
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            openGoogleMaps()
        }else{
            openInIosMaps()
        }
    }





  
  
  @IBAction func openMapAction(_ sender: Any) {

    openMapAction()

//    guard let doctor = DoctorModel.by(id: self.docId) else { return }
//
//    guard let clinic = ClinicModel.by(id: doctor.idClinic) else { return }
//
//
//    let regionDistance:CLLocationDistance = 10000
//    let coordinates = CLLocationCoordinate2DMake(clinic.latitude, clinic.longitude)
//    let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
//    let options = [
//      MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
//      MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
//    ]
//    let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
//    let mapItem = MKMapItem(placemark: placemark)
//    mapItem.name = doctor.full_name + "\n" + clinic.full_name
//    mapItem.openInMaps(launchOptions: options)
  }
  
  
  @IBAction private func shareAction(_ sender: Any) {
    
    guard let doctor = DoctorModel.by(id: self.docId) else { return }
    
    var speciality = ""
    if let spec = SpecialityModel.by(id: doctor.idSpecialty ) {
      speciality = spec.name
    }
    
    var text = doctor.full_name ?? ""
    text = text + " - https://itunes.apple.com/us/app/click-doc/id1327941233?ls=1&mt=8"
    
    let textToShare = [ text ]
    let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = self.view
    
    
    activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook, UIActivityType.postToTwitter ]
    
    self.present(activityViewController, animated: true, completion: nil)
    
  }
  
  
  @IBAction private func addToFavAction(_ sender: Any) {
    
    
    if UserModel.currentUser != nil {
      addOrRemoveFav()
    }else{
      
      self.SwiftMessageAlert(layout: .cardView, theme: .info, title: "Click Doc", body: "Must be logged in first".localized)
      
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {[weak self] in
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! ViewController
        self?.navigationController?.pushViewController(vc, animated: true)
      })
      
    }
  }
  
  
  func addOrRemoveFav() {
    
    guard let doctor = DoctorModel.by(id: self.docId) else { return }
    
    NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)
    
    if doctor.is_favorite {
      
      ISClient.sharedInstance.removeFavorite(clinicOrDoctorId: self.docId, objType: "doctor")
        .then { ok -> Void in
          
          if ok {
            self.SwiftMessageAlert(layout: .cardView, theme: .success, title: "Click Doc", body: "Removed from favorites".localized)
            
            DoctorModel.by(id: self.docId)?.is_favorite = false
            self.updateWith(doctor:DoctorModel.by(id: self.docId)!)
          }
          
        }.always {
          NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }.catch { error in
          if let e: LPError = error as? LPError { e.show() }
      }
      
      
    }else{
      
      ISClient.sharedInstance.addFavorite(clinicOrDoctorId: self.docId, objType: "doctor")
        .then { ok -> Void in
          
          if ok {
            self.SwiftMessageAlert(layout: .cardView, theme: .success, title: "Click Doc", body: "Added to favorites".localized)
            
            DoctorModel.by(id: self.docId)?.is_favorite = true
            self.updateWith(doctor:DoctorModel.by(id: self.docId)!)
          }
          
        }.always {
          NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }.catch { error in
          if let e: LPError = error as? LPError { e.show() }
      }
      
    }
    
  }
  
}

