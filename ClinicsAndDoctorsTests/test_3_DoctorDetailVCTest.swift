//
//  DoctorDetailVCTest.swift
//  ClinicsAndDoctorsTests
//
//  Created by Hernan Paez on 28/12/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import XCTest
@testable import ClinicsAndDoctors

class test_3_DoctorDetailVCTest: XCTestCase {
  var vc:DoctorDetailVC!
  
  var doctor:DoctorModel {
    
    let d = DoctorModel()
    
    d.full_name = "Cosme Fulanito"
    d.phone_number = "+5491155633535"
    d.profile_picture = "https://lh3.googleusercontent.com/-iOsj4w-mBxU/AAAAAAAAAAI/AAAAAAAABRg/7aBgj4Dx09M/s120-p-no/photo.jpg"
    d.email = "cosme@doctor.com"
    d.nationality = "Argentina"
    d.idSpecialty = "1"
    d.idClinic = "2"
    d.id = "214"
    d.rating = 4.3
    d.is_favorite = false
    d.dtype = "Vet"
    d.is_rated = false

    return d
  }
  
  override func setUp() {
    
    super.setUp()
    let sb = UIStoryboard(name: "Main", bundle: Bundle(for: DoctorDetailVC.self))
    vc = sb.instantiateViewController(withIdentifier: "DoctorDetailVC") as! DoctorDetailVC
    _ = vc.view
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testLoad() {
    XCTAssert(vc.view != nil, "Load Failed")
  }
  
  func testUpdateWithUser() {
    vc.updateWith(doctor: self.doctor)
    XCTAssert(vc.nameLb.text == self.doctor.full_name, "Names are not equal")
    XCTAssert(vc.especialityLb.text == "Vet - Ginecology", "Types are not equal")
    XCTAssert(vc.phoneBt.isHidden == false)
    XCTAssert(vc.addFavoriteBt.isSelected == false)
  }
  
  
}
