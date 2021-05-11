//
//  Restaurant.swift
//  Toduba
//
//  Created by alessandro izzo on 03/07/18.
//  Copyright © 2018 alessandro izzo. All rights reserved.
//

import Foundation

open class Restaurant : Codable {
    public var identifier: String
    public var name: String
    public var email: String
    public var address: String?
    public var shopName: String?
    public var city: String?
    public var type: String?
    public var pin_type: Int?
    public var imageUrl: String?
    public var openStatus: Int?
    public var coordinates: NSDictionary?
    public var posVendor: Int
    
    private enum CodingKeys: String, CodingKey {
        //case id //Leave it blank because id matches with json Id
        case identifier     = "identifier"
        case name           = "name"
        case email          = "email"
        case address        = "address"
        case coordinates    = "coordinates"
        case city           = "city"
        case type           = "type"
        case pin_type       = "pin_type"
        case shopName       = "shopName"
        case imageUrl       = "imageUrl"
        case openStatus     = "openStatus"
        case posVendor      = "pos_vendor"
    }
    
    
    public convenience init() {
        self.init("","", "", nil, nil, nil, nil, nil, nil, 0, 0)
    }
    
    public init(_ restaurant: NSDictionary){
        self.identifier = restaurant["identifier"] as! String
        self.name = restaurant["name"] as! String
        self.email = restaurant["email"] as! String
        self.address = restaurant["address"] as? String
        self.shopName = restaurant["shopName"] as? String
        self.coordinates = restaurant["coordinates"] as? NSDictionary
        self.city = restaurant["city"] as? String
        self.type = restaurant["type"] as? String
        self.pin_type = restaurant["pin_type"] as? Int
        self.imageUrl = restaurant["imageUrl"] as? String
        self.openStatus = restaurant["openStatus"] as? Int
        self.posVendor = restaurant["pos_vendor"] as! Int
    }
    
    public init(_ identifier: String, _ name: String, _ email: String, _ address: String?, _ shopName: String?,_ city: String?,_ coordinates: NSDictionary?,_ type: String?,_ imageUrl: String?, _ openStatus: Int?, _ posVendor: Int) {
        self.identifier     = identifier
        self.name           = name
        self.email          = email
        self.address        = address
        self.shopName       = shopName
        self.city           = city
        self.type           = type
        self.imageUrl       = imageUrl
        self.coordinates    = coordinates
        self.openStatus     = openStatus
        self.posVendor      = posVendor
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(city, forKey: .city)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(address, forKey: .shopName)
        try container.encodeIfPresent(type, forKey: .type)
        //try container.encodeIfPresent(coordinates, forKey: .coordinates)
    }
    
    public required init(from decoder: Decoder) throws {
        let container       = try decoder.container(keyedBy: CodingKeys.self)
        identifier          = try container.decode(String.self, forKey: .identifier)
        name                = try container.decode(String.self, forKey: .name)
        email               = try container.decode(String.self, forKey: .email)
        city                = try container.decodeIfPresent(String.self, forKey: .city)
        address             = try container.decodeIfPresent(String.self, forKey: .address)
        shopName            = try container.decodeIfPresent(String.self, forKey: .shopName)
        type                = try container.decodeIfPresent(String.self, forKey: .type)
        imageUrl            = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        openStatus          = try container.decodeIfPresent(Int.self, forKey: .openStatus)
        posVendor           = try container.decode(Int.self, forKey: .posVendor)
        coordinates         = nil //try container.decodeIfPresent(NSDictionary.self, forKey: .coordinates)
    }
    
    public func getType() -> ESERCENTE_TYPE {
        guard type != nil else {
            return .RISTORANTE
        }
        return ESERCENTE_TYPE(rawValue: type!) ?? .RISTORANTE
    }
    
    public func getPosVendor() -> POS_VENDOR {
        switch posVendor {
            case 1:
                return .ARGENTEA
            case 2:
                return .WINCOR
            case 3:
                return .QSAVE
            case 4:
                return .NCR
            default:
                return .UNKNOWN
        }
    }
    
    public func getPinType() -> PIN_TYPE {
        switch pin_type {
            case 1:
                return .OTHER
            default:
                return .DEFAULT
        }
    }
    
    public func getCompleteAddress() -> String? {
        guard address != nil else {
            return nil
        }
        guard city != nil else {
            return address
        }
        return address! + " - " + city!
    }
    
    open func getNameOf(_ capitalizeFirst: Bool)-> String{
        if let s = shopName, s.count > 0 {
            if capitalizeFirst {
                let splits = s.split(separator: " ")
                var result = String()
                var i = 0
                for s in splits {
                    result.append(String(s.capitalizingFirstLetter()))
                    i=i+1
                    if i < splits.count {
                        result.append(" ")
                    }
                }
                return result
            }
            else {
                return s
            }
        }
        else {
            if capitalizeFirst {
                let splits = name.split(separator: " ")
                var result = String()
                var i = 0
                for s in splits {
                    result.append(String(s.capitalizingFirstLetter()))
                    i=i+1
                    if i < splits.count {
                        result.append(" ")
                    }
                }
                return result
            }
            else {
                return name
            }
        }
    }
}
