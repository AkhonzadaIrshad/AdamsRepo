//
//  LocationAPIHelper+Nearby.swift
//  rzq
//
//  Created by Said Elmansour on 2020-10-10.
//  Copyright © 2020 technzone. All rights reserved.
//

import UIKit

class NearbyExtension: NSObject {
    
    static let shared: NearbyExtension = NearbyExtension()
    
    var allResults: [GApiResponse.NearBy] = []
    var completion: GoogleApi.GCallback?
    
    func getAllNearBy(input:GInput, clearAll:Bool=true) {
        if (clearAll) {
            allResults.removeAll()
        }
        
        GoogleApi.shared.callApi(.nearBy, input: input, lati: "", long: "") { (response) in
            if let nearByPlaces =  response.data as? [GApiResponse.NearBy]{
                self.allResults.append(contentsOf: nearByPlaces)
                if let token = response.nextPageToken {
                    var tempInput = GInput()
                    tempInput.destinationCoordinate = input.destinationCoordinate
                    tempInput.keyword = input.keyword
                    tempInput.nextPageToken = token
                    tempInput.originCoordinate = input.originCoordinate
                    tempInput.radius = input.radius
                    self.getAllNearBy(input: tempInput,clearAll: false)
                } else if let completion = self.completion {
                    let localResponse = GApiResponse()
                    localResponse.data = self.allResults
                    completion(localResponse)
                }
            } else if let error = response.error {
                if let completion = self.completion {
                    let localResponse = GApiResponse()
                    localResponse.error = error
                    completion(localResponse)
                }
                print(response.error ?? "ERROR")
            }
        }
    }
}
