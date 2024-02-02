//
//  KakaoSearchPlace.swift
//  TravelMap
//
//  Created by 안병욱 on 1/31/24.
//

import Foundation
import SwiftUI

class KakaoSearchPlace: ObservableObject {
    @Published var placeDoc: [Documents] = []
    
    func searchPlacewithKeyword(keyword: String, page: Int) {
        
        let url_pre = "https://dapi.kakao.com/v2/local/search/keyword.json?query=\(keyword)&page=\(page)&size=15&asort=accuracy"
        let url_encoded = url_pre.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: url_encoded)!
        let api_key = Bundle.main.infoDictionary?["Rest_api_key"] as? String ?? ""
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("KakaoAK \(api_key)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            do {
                guard let data_unwrapped = data else {
                    print("data unwrap error")
                    return
                }
                let datas = try JSONDecoder().decode(SearchPlacewithKeywordData.self, from: data_unwrapped)
                //print(response ?? "")
                DispatchQueue.main.async {
                    self.placeDoc = datas.documents ?? []
                    print(self.placeDoc.map{ $0.place_name })
                }
                
            } catch {
                
            }
        }.resume()
    }
}

struct SearchPlacewithKeywordData: Codable {
    var meta: MetaData
    var documents: [Documents]?
    
    struct MetaData: Codable {
        var total_count: Int?
        var pageable_count: Int?
        var is_end: Bool?
        var same_name: SameName?
    }
    
    struct SameName: Codable {
        var region: [String]?
        var keyword: String?
        var selected_region: String?
    }
}
struct Documents: Codable, Hashable {
    var id: String?
    var place_name: String?
    var category_name: String?
    var category_group_code: String?
    var category_group_name: String?
    var phone: String?
    var address_name: String?
    var road_address_name: String?
    var x: String?
    var y: String?
    var place_url: String?
    var distance: String?
}
