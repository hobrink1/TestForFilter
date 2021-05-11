//
//  myTableViewController.swift
//  TestForFilter
//
//  Created by Hartwig Hopfenzitz on 23.02.21.
//

import UIKit

// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - myTableViewController
// -------------------------------------------------------------------------------------------------

class myTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Class Properties
    // ---------------------------------------------------------------------------------------------
    
    // this is just a simple struct to get the naming right
    private struct restaurantsStruct : Comparable {
        
        // properties
        let name: String
        let shopName: String?
        let address: String?
        let city: String?
        
        // init
        init (_ name: String,
              _ shopName: String?,
              _ address: String?,
              _ city: String?) {
            self.name = name
            self.shopName = shopName
            self.address = address
            self.city = city
        }
        
        // make it comparable
        static func < (lhs: myTableViewController.restaurantsStruct, rhs: myTableViewController.restaurantsStruct) -> Bool {
            return (lhs.name < rhs.name)
        }

    }
    
    private var restaurants: [restaurantsStruct]?
    private var filteredRestaurants: [restaurantsStruct] = []
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Test Data
    // ---------------------------------------------------------------------------------------------
    
    // this are the test data
    private let restaurantsDates: [restaurantsStruct] = [
        restaurantsStruct("Bar Clikapp UEUE", nil, nil, nil),
        restaurantsStruct("Pizzeria La Margherita", nil, nil, nil),
        restaurantsStruct("La Vie", nil, nil, nil),
        restaurantsStruct("Boh", nil, nil, nil),
        restaurantsStruct("Aiajajai", nil, nil, nil),
        restaurantsStruct("Auaja", nil, nil, nil),
        restaurantsStruct("Uuuu", nil, nil, nil),
        restaurantsStruct("Ciao", nil, nil, nil),
        restaurantsStruct("Tre mozzarelle", nil, nil, nil),
        restaurantsStruct("Bar Clikapp PPP", nil, nil, nil),
        restaurantsStruct("Bar Sku", nil, nil, nil),
        restaurantsStruct("Bar wow", nil, nil, nil),
        restaurantsStruct("Bar delle Bocce","shop1", nil, nil),
        restaurantsStruct("Prova Esercente", "shop1", nil, nil),
        restaurantsStruct("Gdo", "shop1", nil, nil),
        restaurantsStruct("Obiiii", "shop1", nil, nil),
        restaurantsStruct("Ywuaja", "shop1", nil, nil),
        restaurantsStruct("Prova esercente sub", "shop1", nil, nil),
        restaurantsStruct("Rossi srl", "shop1", nil, nil),
        restaurantsStruct("Xjdjd", "shop1", nil, nil),
        restaurantsStruct("Gdo sub", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 2", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 6", "shop2", "Address1", nil),
        restaurantsStruct("Esercente SUb", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 2", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 7", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 6", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente sub 7", "shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Sub 8", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Capo","shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("CAntonoo","shop3", "Address2", "city1"),
        restaurantsStruct("Nuova unità", "shop3", "Address2", "city1"),
        restaurantsStruct("Ristorante Test Nuovo", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test 3", "shop4", "Address3", "city2"),
        restaurantsStruct("Ristobuono", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Risto test 1610", "shop4", "Address3", "city2"),
        restaurantsStruct("Bih", "shop4", "Address3", "city2"),
        restaurantsStruct("Tre", "shop4", "Address3", "city2"),
        restaurantsStruct("Gdo admin", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Usjsjs", "shop4", "Address3", "city2"),
        restaurantsStruct("Merchant 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Esercente Admin 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Test risto admin 2901", "shop5", "Address4", "city3"),
        restaurantsStruct("Test GDO sub", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sotto risto", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sede 1 0603", "shop5", "Address4", "city3"),
        restaurantsStruct("UUUUUUUU", "shop5", "Address4", "city3"),
        restaurantsStruct("TEST", "shop5", "Address4", "city3"),
        restaurantsStruct("Ciao", "shop5", "Address4", "city3"),
        restaurantsStruct("Kkkk", "shop5", "Address4", "city3"),
        restaurantsStruct("Bar Della Borsa", "shop5", "Address4", "city3"),
        restaurantsStruct("Iajaja", "shop6", "Address5", "city4"),
        restaurantsStruct("ristobuon", "shop6", "Address5", "city4"),
        restaurantsStruct("abcde", "shop6", "Address5", "city4"),
        restaurantsStruct("sidasdj", "shop6", "Address5", "city4"),
        restaurantsStruct("skdasd", "shop6", "Address5", "city4"),
        restaurantsStruct("GDO Test Multi", "shop6", "Address5", "city4"),
        restaurantsStruct("Rossi srl", "shop6", "Address5", "city4"),
        restaurantsStruct("III", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Arimondo Test", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Assiopay", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Tigros", "shop6", "Address5", "city4"),
        restaurantsStruct("testcall", "shop6", "Address5", "city4"),
        restaurantsStruct("GAB Tamagnini SRL - test market", "shop6", "Address5", "city4"),
        restaurantsStruct("Bar Clikapp UEUE", nil, nil, nil),
        restaurantsStruct("Pizzeria La Margherita", nil, nil, nil),
        restaurantsStruct("La Vie", nil, nil, nil),
        restaurantsStruct("Boh", nil, nil, nil),
        restaurantsStruct("Aiajajai", nil, nil, nil),
        restaurantsStruct("Auaja", nil, nil, nil),
        restaurantsStruct("Uuuu", nil, nil, nil),
        restaurantsStruct("Ciao", nil, nil, nil),
        restaurantsStruct("Tre mozzarelle", nil, nil, nil),
        restaurantsStruct("Bar Clikapp PPP", nil, nil, nil),
        restaurantsStruct("Bar Sku", nil, nil, nil),
        restaurantsStruct("Bar wow", nil, nil, nil),
        restaurantsStruct("Bar delle Bocce","shop1", nil, nil),
        restaurantsStruct("Prova Esercente", "shop1", nil, nil),
        restaurantsStruct("Gdo", "shop1", nil, nil),
        restaurantsStruct("Obiiii", "shop1", nil, nil),
        restaurantsStruct("Ywuaja", "shop1", nil, nil),
        restaurantsStruct("Prova esercente sub", "shop1", nil, nil),
        restaurantsStruct("Rossi srl", "shop1", nil, nil),
        restaurantsStruct("Xjdjd", "shop1", nil, nil),
        restaurantsStruct("Gdo sub", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 2", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 6", "shop2", "Address1", nil),
        restaurantsStruct("Esercente SUb", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 2", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 7", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 6", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente sub 7", "shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Sub 8", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Capo","shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("CAntonoo","shop3", "Address2", "city1"),
        restaurantsStruct("Nuova unità", "shop3", "Address2", "city1"),
        restaurantsStruct("Ristorante Test Nuovo", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test 3", "shop4", "Address3", "city2"),
        restaurantsStruct("Ristobuono", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Risto test 1610", "shop4", "Address3", "city2"),
        restaurantsStruct("Bih", "shop4", "Address3", "city2"),
        restaurantsStruct("Tre", "shop4", "Address3", "city2"),
        restaurantsStruct("Gdo admin", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Usjsjs", "shop4", "Address3", "city2"),
        restaurantsStruct("Merchant 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Esercente Admin 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Test risto admin 2901", "shop5", "Address4", "city3"),
        restaurantsStruct("Test GDO sub", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sotto risto", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sede 1 0603", "shop5", "Address4", "city3"),
        restaurantsStruct("UUUUUUUU", "shop5", "Address4", "city3"),
        restaurantsStruct("TEST", "shop5", "Address4", "city3"),
        restaurantsStruct("Ciao", "shop5", "Address4", "city3"),
        restaurantsStruct("Kkkk", "shop5", "Address4", "city3"),
        restaurantsStruct("Bar Della Borsa", "shop5", "Address4", "city3"),
        restaurantsStruct("Iajaja", "shop6", "Address5", "city4"),
        restaurantsStruct("ristobuon", "shop6", "Address5", "city4"),
        restaurantsStruct("abcde", "shop6", "Address5", "city4"),
        restaurantsStruct("sidasdj", "shop6", "Address5", "city4"),
        restaurantsStruct("skdasd", "shop6", "Address5", "city4"),
        restaurantsStruct("GDO Test Multi", "shop6", "Address5", "city4"),
        restaurantsStruct("Rossi srl", "shop6", "Address5", "city4"),
        restaurantsStruct("III", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Arimondo Test", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Assiopay", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Tigros", "shop6", "Address5", "city4"),
        restaurantsStruct("testcall", "shop6", "Address5", "city4"),
        restaurantsStruct("GAB Tamagnini SRL - test market", "shop6", "Address5", "city4"),
        restaurantsStruct("Bar Clikapp UEUE", nil, nil, nil),
        restaurantsStruct("Pizzeria La Margherita", nil, nil, nil),
        restaurantsStruct("La Vie", nil, nil, nil),
        restaurantsStruct("Boh", nil, nil, nil),
        restaurantsStruct("Aiajajai", nil, nil, nil),
        restaurantsStruct("Auaja", nil, nil, nil),
        restaurantsStruct("Uuuu", nil, nil, nil),
        restaurantsStruct("Ciao", nil, nil, nil),
        restaurantsStruct("Tre mozzarelle", nil, nil, nil),
        restaurantsStruct("Bar Clikapp PPP", nil, nil, nil),
        restaurantsStruct("Bar Sku", nil, nil, nil),
        restaurantsStruct("Bar wow", nil, nil, nil),
        restaurantsStruct("Bar delle Bocce","shop1", nil, nil),
        restaurantsStruct("Prova Esercente", "shop1", nil, nil),
        restaurantsStruct("Gdo", "shop1", nil, nil),
        restaurantsStruct("Obiiii", "shop1", nil, nil),
        restaurantsStruct("Ywuaja", "shop1", nil, nil),
        restaurantsStruct("Prova esercente sub", "shop1", nil, nil),
        restaurantsStruct("Rossi srl", "shop1", nil, nil),
        restaurantsStruct("Xjdjd", "shop1", nil, nil),
        restaurantsStruct("Gdo sub", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 2", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 6", "shop2", "Address1", nil),
        restaurantsStruct("Esercente SUb", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 2", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 7", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 6", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente sub 7", "shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Sub 8", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Capo","shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("CAntonoo","shop3", "Address2", "city1"),
        restaurantsStruct("Nuova unità", "shop3", "Address2", "city1"),
        restaurantsStruct("Ristorante Test Nuovo", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test 3", "shop4", "Address3", "city2"),
        restaurantsStruct("Ristobuono", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Risto test 1610", "shop4", "Address3", "city2"),
        restaurantsStruct("Bih", "shop4", "Address3", "city2"),
        restaurantsStruct("Tre", "shop4", "Address3", "city2"),
        restaurantsStruct("Gdo admin", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Usjsjs", "shop4", "Address3", "city2"),
        restaurantsStruct("Merchant 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Esercente Admin 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Test risto admin 2901", "shop5", "Address4", "city3"),
        restaurantsStruct("Test GDO sub", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sotto risto", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sede 1 0603", "shop5", "Address4", "city3"),
        restaurantsStruct("UUUUUUUU", "shop5", "Address4", "city3"),
        restaurantsStruct("TEST", "shop5", "Address4", "city3"),
        restaurantsStruct("Ciao", "shop5", "Address4", "city3"),
        restaurantsStruct("Kkkk", "shop5", "Address4", "city3"),
        restaurantsStruct("Bar Della Borsa", "shop5", "Address4", "city3"),
        restaurantsStruct("Iajaja", "shop6", "Address5", "city4"),
        restaurantsStruct("ristobuon", "shop6", "Address5", "city4"),
        restaurantsStruct("abcde", "shop6", "Address5", "city4"),
        restaurantsStruct("sidasdj", "shop6", "Address5", "city4"),
        restaurantsStruct("skdasd", "shop6", "Address5", "city4"),
        restaurantsStruct("GDO Test Multi", "shop6", "Address5", "city4"),
        restaurantsStruct("Rossi srl", "shop6", "Address5", "city4"),
        restaurantsStruct("III", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Arimondo Test", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Assiopay", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Tigros", "shop6", "Address5", "city4"),
        restaurantsStruct("testcall", "shop6", "Address5", "city4"),
        restaurantsStruct("GAB Tamagnini SRL - test market", "shop6", "Address5", "city4"),
        restaurantsStruct("Bar Clikapp UEUE", nil, nil, nil),
        restaurantsStruct("Pizzeria La Margherita", nil, nil, nil),
        restaurantsStruct("La Vie", nil, nil, nil),
        restaurantsStruct("Boh", nil, nil, nil),
        restaurantsStruct("Aiajajai", nil, nil, nil),
        restaurantsStruct("Auaja", nil, nil, nil),
        restaurantsStruct("Uuuu", nil, nil, nil),
        restaurantsStruct("Ciao", nil, nil, nil),
        restaurantsStruct("Tre mozzarelle", nil, nil, nil),
        restaurantsStruct("Bar Clikapp PPP", nil, nil, nil),
        restaurantsStruct("Bar Sku", nil, nil, nil),
        restaurantsStruct("Bar wow", nil, nil, nil),
        restaurantsStruct("Bar delle Bocce","shop1", nil, nil),
        restaurantsStruct("Prova Esercente", "shop1", nil, nil),
        restaurantsStruct("Gdo", "shop1", nil, nil),
        restaurantsStruct("Obiiii", "shop1", nil, nil),
        restaurantsStruct("Ywuaja", "shop1", nil, nil),
        restaurantsStruct("Prova esercente sub", "shop1", nil, nil),
        restaurantsStruct("Rossi srl", "shop1", nil, nil),
        restaurantsStruct("Xjdjd", "shop1", nil, nil),
        restaurantsStruct("Gdo sub", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 2", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 6", "shop2", "Address1", nil),
        restaurantsStruct("Esercente SUb", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 2", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 7", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 6", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente sub 7", "shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Sub 8", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Capo","shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("CAntonoo","shop3", "Address2", "city1"),
        restaurantsStruct("Nuova unità", "shop3", "Address2", "city1"),
        restaurantsStruct("Ristorante Test Nuovo", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test 3", "shop4", "Address3", "city2"),
        restaurantsStruct("Ristobuono", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Risto test 1610", "shop4", "Address3", "city2"),
        restaurantsStruct("Bih", "shop4", "Address3", "city2"),
        restaurantsStruct("Tre", "shop4", "Address3", "city2"),
        restaurantsStruct("Gdo admin", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Usjsjs", "shop4", "Address3", "city2"),
        restaurantsStruct("Merchant 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Esercente Admin 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Test risto admin 2901", "shop5", "Address4", "city3"),
        restaurantsStruct("Test GDO sub", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sotto risto", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sede 1 0603", "shop5", "Address4", "city3"),
        restaurantsStruct("UUUUUUUU", "shop5", "Address4", "city3"),
        restaurantsStruct("TEST", "shop5", "Address4", "city3"),
        restaurantsStruct("Ciao", "shop5", "Address4", "city3"),
        restaurantsStruct("Kkkk", "shop5", "Address4", "city3"),
        restaurantsStruct("Bar Della Borsa", "shop5", "Address4", "city3"),
        restaurantsStruct("Iajaja", "shop6", "Address5", "city4"),
        restaurantsStruct("ristobuon", "shop6", "Address5", "city4"),
        restaurantsStruct("abcde", "shop6", "Address5", "city4"),
        restaurantsStruct("sidasdj", "shop6", "Address5", "city4"),
        restaurantsStruct("skdasd", "shop6", "Address5", "city4"),
        restaurantsStruct("GDO Test Multi", "shop6", "Address5", "city4"),
        restaurantsStruct("Rossi srl", "shop6", "Address5", "city4"),
        restaurantsStruct("III", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Arimondo Test", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Assiopay", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Tigros", "shop6", "Address5", "city4"),
        restaurantsStruct("testcall", "shop6", "Address5", "city4"),
        restaurantsStruct("GAB Tamagnini SRL - test market", "shop6", "Address5", "city4"),
        restaurantsStruct("Bar Clikapp UEUE", nil, nil, nil),
        restaurantsStruct("Pizzeria La Margherita", nil, nil, nil),
        restaurantsStruct("La Vie", nil, nil, nil),
        restaurantsStruct("Boh", nil, nil, nil),
        restaurantsStruct("Aiajajai", nil, nil, nil),
        restaurantsStruct("Auaja", nil, nil, nil),
        restaurantsStruct("Uuuu", nil, nil, nil),
        restaurantsStruct("Ciao", nil, nil, nil),
        restaurantsStruct("Tre mozzarelle", nil, nil, nil),
        restaurantsStruct("Bar Clikapp PPP", nil, nil, nil),
        restaurantsStruct("Bar Sku", nil, nil, nil),
        restaurantsStruct("Bar wow", nil, nil, nil),
        restaurantsStruct("Bar delle Bocce","shop1", nil, nil),
        restaurantsStruct("Prova Esercente", "shop1", nil, nil),
        restaurantsStruct("Gdo", "shop1", nil, nil),
        restaurantsStruct("Obiiii", "shop1", nil, nil),
        restaurantsStruct("Ywuaja", "shop1", nil, nil),
        restaurantsStruct("Prova esercente sub", "shop1", nil, nil),
        restaurantsStruct("Rossi srl", "shop1", nil, nil),
        restaurantsStruct("Xjdjd", "shop1", nil, nil),
        restaurantsStruct("Gdo sub", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 2", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 6", "shop2", "Address1", nil),
        restaurantsStruct("Esercente SUb", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 2", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 7", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 6", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente sub 7", "shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Sub 8", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Capo","shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("CAntonoo","shop3", "Address2", "city1"),
        restaurantsStruct("Nuova unità", "shop3", "Address2", "city1"),
        restaurantsStruct("Ristorante Test Nuovo", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test 3", "shop4", "Address3", "city2"),
        restaurantsStruct("Ristobuono", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Risto test 1610", "shop4", "Address3", "city2"),
        restaurantsStruct("Bih", "shop4", "Address3", "city2"),
        restaurantsStruct("Tre", "shop4", "Address3", "city2"),
        restaurantsStruct("Gdo admin", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Usjsjs", "shop4", "Address3", "city2"),
        restaurantsStruct("Merchant 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Esercente Admin 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Test risto admin 2901", "shop5", "Address4", "city3"),
        restaurantsStruct("Test GDO sub", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sotto risto", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sede 1 0603", "shop5", "Address4", "city3"),
        restaurantsStruct("UUUUUUUU", "shop5", "Address4", "city3"),
        restaurantsStruct("TEST", "shop5", "Address4", "city3"),
        restaurantsStruct("Ciao", "shop5", "Address4", "city3"),
        restaurantsStruct("Kkkk", "shop5", "Address4", "city3"),
        restaurantsStruct("Bar Della Borsa", "shop5", "Address4", "city3"),
        restaurantsStruct("Iajaja", "shop6", "Address5", "city4"),
        restaurantsStruct("ristobuon", "shop6", "Address5", "city4"),
        restaurantsStruct("abcde", "shop6", "Address5", "city4"),
        restaurantsStruct("sidasdj", "shop6", "Address5", "city4"),
        restaurantsStruct("skdasd", "shop6", "Address5", "city4"),
        restaurantsStruct("GDO Test Multi", "shop6", "Address5", "city4"),
        restaurantsStruct("Rossi srl", "shop6", "Address5", "city4"),
        restaurantsStruct("III", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Arimondo Test", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Assiopay", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Tigros", "shop6", "Address5", "city4"),
        restaurantsStruct("testcall", "shop6", "Address5", "city4"),
        restaurantsStruct("GAB Tamagnini SRL - test market", "shop6", "Address5", "city4"),
        restaurantsStruct("Bar Clikapp UEUE", nil, nil, nil),
        restaurantsStruct("Pizzeria La Margherita", nil, nil, nil),
        restaurantsStruct("La Vie", nil, nil, nil),
        restaurantsStruct("Boh", nil, nil, nil),
        restaurantsStruct("Aiajajai", nil, nil, nil),
        restaurantsStruct("Auaja", nil, nil, nil),
        restaurantsStruct("Uuuu", nil, nil, nil),
        restaurantsStruct("Ciao", nil, nil, nil),
        restaurantsStruct("Tre mozzarelle", nil, nil, nil),
        restaurantsStruct("Bar Clikapp PPP", nil, nil, nil),
        restaurantsStruct("Bar Sku", nil, nil, nil),
        restaurantsStruct("Bar wow", nil, nil, nil),
        restaurantsStruct("Bar delle Bocce","shop1", nil, nil),
        restaurantsStruct("Prova Esercente", "shop1", nil, nil),
        restaurantsStruct("Gdo", "shop1", nil, nil),
        restaurantsStruct("Obiiii", "shop1", nil, nil),
        restaurantsStruct("Ywuaja", "shop1", nil, nil),
        restaurantsStruct("Prova esercente sub", "shop1", nil, nil),
        restaurantsStruct("Rossi srl", "shop1", nil, nil),
        restaurantsStruct("Xjdjd", "shop1", nil, nil),
        restaurantsStruct("Gdo sub", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 2", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 6", "shop2", "Address1", nil),
        restaurantsStruct("Esercente SUb", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 2", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 7", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 6", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente sub 7", "shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Sub 8", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Capo","shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("CAntonoo","shop3", "Address2", "city1"),
        restaurantsStruct("Nuova unità", "shop3", "Address2", "city1"),
        restaurantsStruct("Ristorante Test Nuovo", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test 3", "shop4", "Address3", "city2"),
        restaurantsStruct("Ristobuono", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Risto test 1610", "shop4", "Address3", "city2"),
        restaurantsStruct("Bih", "shop4", "Address3", "city2"),
        restaurantsStruct("Tre", "shop4", "Address3", "city2"),
        restaurantsStruct("Gdo admin", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Usjsjs", "shop4", "Address3", "city2"),
        restaurantsStruct("Merchant 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Esercente Admin 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Test risto admin 2901", "shop5", "Address4", "city3"),
        restaurantsStruct("Test GDO sub", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sotto risto", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sede 1 0603", "shop5", "Address4", "city3"),
        restaurantsStruct("UUUUUUUU", "shop5", "Address4", "city3"),
        restaurantsStruct("TEST", "shop5", "Address4", "city3"),
        restaurantsStruct("Ciao", "shop5", "Address4", "city3"),
        restaurantsStruct("Kkkk", "shop5", "Address4", "city3"),
        restaurantsStruct("Bar Della Borsa", "shop5", "Address4", "city3"),
        restaurantsStruct("Iajaja", "shop6", "Address5", "city4"),
        restaurantsStruct("ristobuon", "shop6", "Address5", "city4"),
        restaurantsStruct("abcde", "shop6", "Address5", "city4"),
        restaurantsStruct("sidasdj", "shop6", "Address5", "city4"),
        restaurantsStruct("skdasd", "shop6", "Address5", "city4"),
        restaurantsStruct("GDO Test Multi", "shop6", "Address5", "city4"),
        restaurantsStruct("Rossi srl", "shop6", "Address5", "city4"),
        restaurantsStruct("III", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Arimondo Test", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Assiopay", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Tigros", "shop6", "Address5", "city4"),
        restaurantsStruct("testcall", "shop6", "Address5", "city4"),
        restaurantsStruct("GAB Tamagnini SRL - test market", "shop6", "Address5", "city4"),
        restaurantsStruct("Bar Clikapp UEUE", nil, nil, nil),
        restaurantsStruct("Pizzeria La Margherita", nil, nil, nil),
        restaurantsStruct("La Vie", nil, nil, nil),
        restaurantsStruct("Boh", nil, nil, nil),
        restaurantsStruct("Aiajajai", nil, nil, nil),
        restaurantsStruct("Auaja", nil, nil, nil),
        restaurantsStruct("Uuuu", nil, nil, nil),
        restaurantsStruct("Ciao", nil, nil, nil),
        restaurantsStruct("Tre mozzarelle", nil, nil, nil),
        restaurantsStruct("Bar Clikapp PPP", nil, nil, nil),
        restaurantsStruct("Bar Sku", nil, nil, nil),
        restaurantsStruct("Bar wow", nil, nil, nil),
        restaurantsStruct("Bar delle Bocce","shop1", nil, nil),
        restaurantsStruct("Prova Esercente", "shop1", nil, nil),
        restaurantsStruct("Gdo", "shop1", nil, nil),
        restaurantsStruct("Obiiii", "shop1", nil, nil),
        restaurantsStruct("Ywuaja", "shop1", nil, nil),
        restaurantsStruct("Prova esercente sub", "shop1", nil, nil),
        restaurantsStruct("Rossi srl", "shop1", nil, nil),
        restaurantsStruct("Xjdjd", "shop1", nil, nil),
        restaurantsStruct("Gdo sub", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 2", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 6", "shop2", "Address1", nil),
        restaurantsStruct("Esercente SUb", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 2", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 7", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 6", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente sub 7", "shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Sub 8", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Capo","shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("CAntonoo","shop3", "Address2", "city1"),
        restaurantsStruct("Nuova unità", "shop3", "Address2", "city1"),
        restaurantsStruct("Ristorante Test Nuovo", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test 3", "shop4", "Address3", "city2"),
        restaurantsStruct("Ristobuono", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Risto test 1610", "shop4", "Address3", "city2"),
        restaurantsStruct("Bih", "shop4", "Address3", "city2"),
        restaurantsStruct("Tre", "shop4", "Address3", "city2"),
        restaurantsStruct("Gdo admin", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Usjsjs", "shop4", "Address3", "city2"),
        restaurantsStruct("Merchant 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Esercente Admin 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Test risto admin 2901", "shop5", "Address4", "city3"),
        restaurantsStruct("Test GDO sub", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sotto risto", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sede 1 0603", "shop5", "Address4", "city3"),
        restaurantsStruct("UUUUUUUU", "shop5", "Address4", "city3"),
        restaurantsStruct("TEST", "shop5", "Address4", "city3"),
        restaurantsStruct("Ciao", "shop5", "Address4", "city3"),
        restaurantsStruct("Kkkk", "shop5", "Address4", "city3"),
        restaurantsStruct("Bar Della Borsa", "shop5", "Address4", "city3"),
        restaurantsStruct("Iajaja", "shop6", "Address5", "city4"),
        restaurantsStruct("ristobuon", "shop6", "Address5", "city4"),
        restaurantsStruct("abcde", "shop6", "Address5", "city4"),
        restaurantsStruct("sidasdj", "shop6", "Address5", "city4"),
        restaurantsStruct("skdasd", "shop6", "Address5", "city4"),
        restaurantsStruct("GDO Test Multi", "shop6", "Address5", "city4"),
        restaurantsStruct("Rossi srl", "shop6", "Address5", "city4"),
        restaurantsStruct("III", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Arimondo Test", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Assiopay", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Tigros", "shop6", "Address5", "city4"),
        restaurantsStruct("testcall", "shop6", "Address5", "city4"),
        restaurantsStruct("GAB Tamagnini SRL - test market", "shop6", "Address5", "city4"),
        restaurantsStruct("Bar Clikapp UEUE", nil, nil, nil),
        restaurantsStruct("Pizzeria La Margherita", nil, nil, nil),
        restaurantsStruct("La Vie", nil, nil, nil),
        restaurantsStruct("Boh", nil, nil, nil),
        restaurantsStruct("Aiajajai", nil, nil, nil),
        restaurantsStruct("Auaja", nil, nil, nil),
        restaurantsStruct("Uuuu", nil, nil, nil),
        restaurantsStruct("Ciao", nil, nil, nil),
        restaurantsStruct("Tre mozzarelle", nil, nil, nil),
        restaurantsStruct("Bar Clikapp PPP", nil, nil, nil),
        restaurantsStruct("Bar Sku", nil, nil, nil),
        restaurantsStruct("Bar wow", nil, nil, nil),
        restaurantsStruct("Bar delle Bocce","shop1", nil, nil),
        restaurantsStruct("Prova Esercente", "shop1", nil, nil),
        restaurantsStruct("Gdo", "shop1", nil, nil),
        restaurantsStruct("Obiiii", "shop1", nil, nil),
        restaurantsStruct("Ywuaja", "shop1", nil, nil),
        restaurantsStruct("Prova esercente sub", "shop1", nil, nil),
        restaurantsStruct("Rossi srl", "shop1", nil, nil),
        restaurantsStruct("Xjdjd", "shop1", nil, nil),
        restaurantsStruct("Gdo sub", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 2", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 6", "shop2", "Address1", nil),
        restaurantsStruct("Esercente SUb", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 2", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 7", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 6", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente sub 7", "shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Sub 8", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Capo","shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("CAntonoo","shop3", "Address2", "city1"),
        restaurantsStruct("Nuova unità", "shop3", "Address2", "city1"),
        restaurantsStruct("Ristorante Test Nuovo", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test 3", "shop4", "Address3", "city2"),
        restaurantsStruct("Ristobuono", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Risto test 1610", "shop4", "Address3", "city2"),
        restaurantsStruct("Bih", "shop4", "Address3", "city2"),
        restaurantsStruct("Tre", "shop4", "Address3", "city2"),
        restaurantsStruct("Gdo admin", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Usjsjs", "shop4", "Address3", "city2"),
        restaurantsStruct("Merchant 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Esercente Admin 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Test risto admin 2901", "shop5", "Address4", "city3"),
        restaurantsStruct("Test GDO sub", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sotto risto", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sede 1 0603", "shop5", "Address4", "city3"),
        restaurantsStruct("UUUUUUUU", "shop5", "Address4", "city3"),
        restaurantsStruct("TEST", "shop5", "Address4", "city3"),
        restaurantsStruct("Ciao", "shop5", "Address4", "city3"),
        restaurantsStruct("Kkkk", "shop5", "Address4", "city3"),
        restaurantsStruct("Bar Della Borsa", "shop5", "Address4", "city3"),
        restaurantsStruct("Iajaja", "shop6", "Address5", "city4"),
        restaurantsStruct("ristobuon", "shop6", "Address5", "city4"),
        restaurantsStruct("abcde", "shop6", "Address5", "city4"),
        restaurantsStruct("sidasdj", "shop6", "Address5", "city4"),
        restaurantsStruct("skdasd", "shop6", "Address5", "city4"),
        restaurantsStruct("GDO Test Multi", "shop6", "Address5", "city4"),
        restaurantsStruct("Rossi srl", "shop6", "Address5", "city4"),
        restaurantsStruct("III", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Arimondo Test", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Assiopay", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Tigros", "shop6", "Address5", "city4"),
        restaurantsStruct("testcall", "shop6", "Address5", "city4"),
        restaurantsStruct("GAB Tamagnini SRL - test market", "shop6", "Address5", "city4"),
        restaurantsStruct("Bar Clikapp UEUE", nil, nil, nil),
        restaurantsStruct("Pizzeria La Margherita", nil, nil, nil),
        restaurantsStruct("La Vie", nil, nil, nil),
        restaurantsStruct("Boh", nil, nil, nil),
        restaurantsStruct("Aiajajai", nil, nil, nil),
        restaurantsStruct("Auaja", nil, nil, nil),
        restaurantsStruct("Uuuu", nil, nil, nil),
        restaurantsStruct("Ciao", nil, nil, nil),
        restaurantsStruct("Tre mozzarelle", nil, nil, nil),
        restaurantsStruct("Bar Clikapp PPP", nil, nil, nil),
        restaurantsStruct("Bar Sku", nil, nil, nil),
        restaurantsStruct("Bar wow", nil, nil, nil),
        restaurantsStruct("Bar delle Bocce","shop1", nil, nil),
        restaurantsStruct("Prova Esercente", "shop1", nil, nil),
        restaurantsStruct("Gdo", "shop1", nil, nil),
        restaurantsStruct("Obiiii", "shop1", nil, nil),
        restaurantsStruct("Ywuaja", "shop1", nil, nil),
        restaurantsStruct("Prova esercente sub", "shop1", nil, nil),
        restaurantsStruct("Rossi srl", "shop1", nil, nil),
        restaurantsStruct("Xjdjd", "shop1", nil, nil),
        restaurantsStruct("Gdo sub", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 2", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 6", "shop2", "Address1", nil),
        restaurantsStruct("Esercente SUb", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 2", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 7", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 6", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente sub 7", "shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Sub 8", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Capo","shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("CAntonoo","shop3", "Address2", "city1"),
        restaurantsStruct("Nuova unità", "shop3", "Address2", "city1"),
        restaurantsStruct("Ristorante Test Nuovo", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test 3", "shop4", "Address3", "city2"),
        restaurantsStruct("Ristobuono", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Risto test 1610", "shop4", "Address3", "city2"),
        restaurantsStruct("Bih", "shop4", "Address3", "city2"),
        restaurantsStruct("Tre", "shop4", "Address3", "city2"),
        restaurantsStruct("Gdo admin", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Usjsjs", "shop4", "Address3", "city2"),
        restaurantsStruct("Merchant 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Esercente Admin 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Test risto admin 2901", "shop5", "Address4", "city3"),
        restaurantsStruct("Test GDO sub", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sotto risto", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sede 1 0603", "shop5", "Address4", "city3"),
        restaurantsStruct("UUUUUUUU", "shop5", "Address4", "city3"),
        restaurantsStruct("TEST", "shop5", "Address4", "city3"),
        restaurantsStruct("Ciao", "shop5", "Address4", "city3"),
        restaurantsStruct("Kkkk", "shop5", "Address4", "city3"),
        restaurantsStruct("Bar Della Borsa", "shop5", "Address4", "city3"),
        restaurantsStruct("Iajaja", "shop6", "Address5", "city4"),
        restaurantsStruct("ristobuon", "shop6", "Address5", "city4"),
        restaurantsStruct("abcde", "shop6", "Address5", "city4"),
        restaurantsStruct("sidasdj", "shop6", "Address5", "city4"),
        restaurantsStruct("skdasd", "shop6", "Address5", "city4"),
        restaurantsStruct("GDO Test Multi", "shop6", "Address5", "city4"),
        restaurantsStruct("Rossi srl", "shop6", "Address5", "city4"),
        restaurantsStruct("III", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Arimondo Test", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Assiopay", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Tigros", "shop6", "Address5", "city4"),
        restaurantsStruct("testcall", "shop6", "Address5", "city4"),
        restaurantsStruct("GAB Tamagnini SRL - test market", "shop6", "Address5", "city4"),
        restaurantsStruct("Bar Clikapp UEUE", nil, nil, nil),
        restaurantsStruct("Pizzeria La Margherita", nil, nil, nil),
        restaurantsStruct("La Vie", nil, nil, nil),
        restaurantsStruct("Boh", nil, nil, nil),
        restaurantsStruct("Aiajajai", nil, nil, nil),
        restaurantsStruct("Auaja", nil, nil, nil),
        restaurantsStruct("Uuuu", nil, nil, nil),
        restaurantsStruct("Ciao", nil, nil, nil),
        restaurantsStruct("Tre mozzarelle", nil, nil, nil),
        restaurantsStruct("Bar Clikapp PPP", nil, nil, nil),
        restaurantsStruct("Bar Sku", nil, nil, nil),
        restaurantsStruct("Bar wow", nil, nil, nil),
        restaurantsStruct("Bar delle Bocce","shop1", nil, nil),
        restaurantsStruct("Prova Esercente", "shop1", nil, nil),
        restaurantsStruct("Gdo", "shop1", nil, nil),
        restaurantsStruct("Obiiii", "shop1", nil, nil),
        restaurantsStruct("Ywuaja", "shop1", nil, nil),
        restaurantsStruct("Prova esercente sub", "shop1", nil, nil),
        restaurantsStruct("Rossi srl", "shop1", nil, nil),
        restaurantsStruct("Xjdjd", "shop1", nil, nil),
        restaurantsStruct("Gdo sub", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 2", "shop1", nil, nil),
        restaurantsStruct("Gdo sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 6", "shop2", "Address1", nil),
        restaurantsStruct("Esercente SUb", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 2", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 3", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 4", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 5", "shop2", "Address1", nil),
        restaurantsStruct("Gdo sub 7", "shop2", "Address1", nil),
        restaurantsStruct("Esercente sub 6", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente sub 7", "shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Sub 8", "shop3", "Address2", "city1"),
        restaurantsStruct("Esercente Capo","shop3", "Address2", "city1"),
        restaurantsStruct("Buon Market", "shop3", "Address2", "city1"),
        restaurantsStruct("CAntonoo","shop3", "Address2", "city1"),
        restaurantsStruct("Nuova unità", "shop3", "Address2", "city1"),
        restaurantsStruct("Ristorante Test Nuovo", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test", "shop3", "Address2", "city1"),
        restaurantsStruct("Sub risto test 3", "shop4", "Address3", "city2"),
        restaurantsStruct("Ristobuono", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Risto test 1610", "shop4", "Address3", "city2"),
        restaurantsStruct("Bih", "shop4", "Address3", "city2"),
        restaurantsStruct("Tre", "shop4", "Address3", "city2"),
        restaurantsStruct("Gdo admin", "shop4", "Address3", "city2"),
        restaurantsStruct("Nuova sede", "shop4", "Address3", "city2"),
        restaurantsStruct("Usjsjs", "shop4", "Address3", "city2"),
        restaurantsStruct("Merchant 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Esercente Admin 2210", "shop4", "Address3", "city2"),
        restaurantsStruct("Test risto admin 2901", "shop5", "Address4", "city3"),
        restaurantsStruct("Test GDO sub", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sotto risto", "shop5", "Address4", "city3"),
        restaurantsStruct("Test sede 1 0603", "shop5", "Address4", "city3"),
        restaurantsStruct("UUUUUUUU", "shop5", "Address4", "city3"),
        restaurantsStruct("TEST", "shop5", "Address4", "city3"),
        restaurantsStruct("Ciao", "shop5", "Address4", "city3"),
        restaurantsStruct("Kkkk", "shop5", "Address4", "city3"),
        restaurantsStruct("Bar Della Borsa", "shop5", "Address4", "city3"),
        restaurantsStruct("Iajaja", "shop6", "Address5", "city4"),
        restaurantsStruct("ristobuon", "shop6", "Address5", "city4"),
        restaurantsStruct("abcde", "shop6", "Address5", "city4"),
        restaurantsStruct("sidasdj", "shop6", "Address5", "city4"),
        restaurantsStruct("skdasd", "shop6", "Address5", "city4"),
        restaurantsStruct("GDO Test Multi", "shop6", "Address5", "city4"),
        restaurantsStruct("Rossi srl", "shop6", "Address5", "city4"),
        restaurantsStruct("III", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Arimondo Test", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Assiopay", "shop6", "Address5", "city4"),
        restaurantsStruct("Market Test Tigros", "shop6", "Address5", "city4"),
        restaurantsStruct("testcall", "shop6", "Address5", "city4"),
        restaurantsStruct("GAB Tamagnini SRL - test market", "shop6", "Address5", "city4"),
        restaurantsStruct("my restaurant in New York", "shop6", "Address5", "city4")
    ]
    
    private let restaurantsDatesNothing: [restaurantsStruct] = [
        restaurantsStruct("nothing to find", nil, nil, nil)
    ]
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Data Helper
    // ---------------------------------------------------------------------------------------------
    
    /**
     -----------------------------------------------------------------------------------------------
     
     initFilteredRestaurants()
     
     -----------------------------------------------------------------------------------------------
     */
    private func initFilteredRestaurants() {
        
        // if we have valid restaurants
        if restaurants != nil {
            
            self.filteredRestaurants = self.restaurants!
            self.numberLabel.text = "\(filteredRestaurants.count) esercizi disponibili"
            
        } else {
            
            self.filteredRestaurants = []
            self.numberLabel.text = "0 esercizi disponibili"
        }
        
        self.restaurantsTableView.reloadData()
    }
    
    
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - IB Outlets
    // ---------------------------------------------------------------------------------------------
    
    @IBOutlet weak var restaurantsSearchBar: UISearchBar!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var restaurantsTableView: UITableView!
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Life Cycle
    // ---------------------------------------------------------------------------------------------
    
    /**
     -----------------------------------------------------------------------------------------------
     
     viewDidLoad()
     
     -----------------------------------------------------------------------------------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.restaurantsTableView.delegate = self
        self.restaurantsTableView.dataSource = self
        self.restaurantsSearchBar.delegate = self
        
        
        // set the data with the test data
        self.restaurants = self.restaurantsDates.sorted()
        
        // set the initial filtered restaurants
        self.initFilteredRestaurants()
        
        // initialize the searchBar
        self.restaurantsSearchBar.text = ""
    }
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - SearchBar Delegate
    // ---------------------------------------------------------------------------------------------

    /**
     -----------------------------------------------------------------------------------------------
     
     textDidChange()
     
     -----------------------------------------------------------------------------------------------
     */
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            initFilteredRestaurants()
        }
        else {
            
            // * we save the current search text to a local copy to freeze it an use it in the async call
            let asyncSearchText = searchText
            
            // * now get off main thread!
            // * we use the global queue with the qos .userintiated, which is the second highest class
            DispatchQueue.global(qos: .userInitiated).async(execute: {
                
                // * split the searchText into single words
                let searchTextArr = asyncSearchText.split(separator: " ")
                
                // * in the async call we prepare the filtered restaurants in a local storage, just to
                // * avoid disturbing the ongoing things on the main thread
                let asyncFilteredRestaurants = (self.restaurants?.filter { restaurant in
                    
                    // walk over the tokens
                    for token in searchTextArr {
                        
                        // if we find something, return true
                        if restaurant.name.localizedStandardContains(token) {
                            
                            return true
                        }
                        
                        // we do not find it by name, so print it for testing
                        // but you can add here next search for .street etc.)
                        
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
                
                
                // * we are finished, so we have to resync with the main thread, by calling the main thread
                DispatchQueue.main.async(execute: {
                    
                    // * here we are, back on main thread
                    
                    // * first step: make the filtered restaurants available
                    self.filteredRestaurants = asyncFilteredRestaurants
                    
                    
                    // second step: update UI (old code)
                    self.numberLabel?.text = "\(self.filteredRestaurants.count) esercizi disponibili"
                    
                    self.restaurantsTableView?.reloadData()
                    
                    if self.filteredRestaurants.count > 0 {
                        
                        self.restaurantsTableView?.scrollToRow(at: IndexPath.init(row: 0, section: 0),
                                                               at: UITableView.ScrollPosition.top,
                                                               animated: true)
                    } // if count > 0
                    
                }) // * main
            }) // * global.userinitiated
            
        } // searchText != ""
    }
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Table view data source
    // ---------------------------------------------------------------------------------------------
    
    /**
     -----------------------------------------------------------------------------------------------
     
     numberOfSections:
     
     -----------------------------------------------------------------------------------------------
     */
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     numberOfRowsInSection:
     
     -----------------------------------------------------------------------------------------------
     */
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // we have the arry and one special row for the inhabitants
        return self.filteredRestaurants.count
    }
    
    
    /**
     -----------------------------------------------------------------------------------------------
     
     heightForRowAt:
     
     -----------------------------------------------------------------------------------------------
     */
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //tableView.estimatedRowHeight = 116
        return UITableView.automaticDimension
    }
    
    
    /**
     -----------------------------------------------------------------------------------------------
     
     cellForRowAt:
     
     -----------------------------------------------------------------------------------------------
     */
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        // get the related data set from local storage
        let index = indexPath.row
        
        // dequeue a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell",
                                                 for: indexPath) as! TableViewCell
        
        cell.Name.text = filteredRestaurants[index].name
        
        return cell
        
        
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
}

