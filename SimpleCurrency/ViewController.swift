//
//  ViewController.swift
//  SimpleCurrency
//
//  Created by Ramzil Bayguskarov on 01.10.2020.
//  Copyright © 2020 Ramzil Bayguskarov. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, XMLParserDelegate, UISearchControllerDelegate, UISearchBarDelegate {
    
    let cellId = "cellId"
    let recordKey = "Valute"
    let dictionaryKeys = Set<String>(["Name", "Value"])
    var results: [[String: String]] = []          // the whole array of dictionaries
    var filteredResults : [[String: String]] = [] // the filtered array for search
    var currentDictionary: [String: String] = [:] // the current dictionary
    var currentValue: String = ""                 // the current value for one of the keys in the dictionary

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationBarSetup()
        tableViewSetup()
        XMLParserSetup()
        
        
        
    }
    
    // MARK: - Custom Methods
    
    func tableViewSetup() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    func navigationBarSetup() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.title = "Simple Currency"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.2462111578, green: 0.6654991576, blue: 1, alpha: 1)
    }
    
    func XMLParserSetup() {
        let myStringUrl = "http://www.cbr.ru/scripts/XML_daily.asp"
        guard let url = URL(string: myStringUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            //check err
            //chesk response
             
            guard let data = data else { return }
            let parser = XMLParser(data: data)
            parser.delegate = self
            if parser.parse() {
//                print(self.results)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }.resume()
    }
   
    // MARK: - XMLParser methods
    
    func parserDidStartDocument(_ parser: XMLParser) {
            results = []
        }

        // start element

        func parser(_ parser: XMLParser,
                    didStartElement elementName: String,
                    namespaceURI: String?,
                    qualifiedName qName: String?,
                    attributes attributeDict: [String : String]) {
            
            if elementName == recordKey {
                currentDictionary = [:]
            } else if dictionaryKeys.contains(elementName) {
                currentValue = ""
            }
        }

        // found characters

        func parser(_ parser: XMLParser,
                    foundCharacters string: String) {
            currentValue += string
        }

        // end element

        func parser(_ parser: XMLParser,
                    didEndElement elementName: String,
                    namespaceURI: String?,
                    qualifiedName qName: String?) {
            if elementName == recordKey {
                results.append(currentDictionary)
                filteredResults.append(currentDictionary)
                currentDictionary = [String:String]()
            } else if dictionaryKeys.contains(elementName) {                currentDictionary[elementName] = currentValue
                currentValue = ""
            }
        }
    
    // MARK: - TableView mehods
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let currentDictionary = filteredResults[indexPath.row]
        cell.textLabel?.text = currentDictionary["Name"]!
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 25))
        label.text = currentDictionary["Value"]!
        cell.accessoryView = label
        return cell
    }

    // MARK: - SearchBar mehods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredResults = []
        
        if searchText == "" {
            filteredResults = results
        } else {
                for currency in results {
                    if currency["Name"]!.lowercased().contains(searchText.lowercased()) {
                        filteredResults.append(currency)
                        print(filteredResults)
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredResults = results
        self.tableView.reloadData()
    }
}




