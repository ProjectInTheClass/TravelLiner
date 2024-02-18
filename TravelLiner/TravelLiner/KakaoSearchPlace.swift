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
    @Published var imgDoc: [ImgDocuments] = []
    @Published var route: [Route] = []
    
    func searchPlacewithKeyword(keyword: String, page: Int, x: Double = 0.0, y: Double = 0.0, radius: Int = 200) {
        
        var url_pre = "https://dapi.kakao.com/v2/local/search/keyword.json?query=\(keyword)&page=\(page)&size=15&asort=accuracy"
        if x != 0.0 {
            url_pre = url_pre + "&x=\(x)&y=\(y)&radius=\(radius)"
        }
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
                    //print(self.placeDoc.map{ $0.place_name })
                }
                
            } catch {
                
            }
        }.resume()
    }
    
    func searchImage(keyword: String, page: Int) {
        let url_pre = "https://dapi.kakao.com/v2/search/image?query=\(keyword)&page=\(page)&size=5&asort=accuracy"
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
                let datas = try JSONDecoder().decode(SearchImageData.self, from: data_unwrapped)
                //print(response ?? "")
                DispatchQueue.main.async {
                    self.imgDoc = datas.documents 
                    //print(self.imgDoc.first?.image_url)
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func searchRoute(places: [Places], priority: String = "RECOMMEND", avoid: String = "", road_details: Bool = false, alternatives: Bool = false, car_type: Int = 1, car_fuel: String = "GASOLINE", summary: Bool = false) {
        
        if places.count < 2 {
            return
        }
        let origin = places.first ?? Places(name: "", longitude: 0.0, latitude: 0.0, sequence: 1)
        let destination = places.last ?? Places(name: "", longitude: 0.0, latitude: 0.0, sequence: 1)
        var wayPoints: [Places] = places.filter{$0.sequence != 1 && $0.sequence != places.count}
        //print(wayPoints.map{$0.sequence})
        let origins = "origin=\(origin.longitude),\(origin.latitude),name=\(origin.name)"
        let destinations = "destination=\(destination.longitude),\(destination.latitude),name=\(destination.name)"
        var wayPointOrigin = "&waypoints="
        for waypointElement in wayPoints {
            if waypointElement == wayPoints.last {
                wayPointOrigin += "\(waypointElement.longitude),\(waypointElement.latitude),name=\(waypointElement.name)"
            } else {
                wayPointOrigin += "\(waypointElement.longitude),\(waypointElement.latitude),name=\(waypointElement.name)|"
            }
        }
        if wayPoints == [] {
            wayPointOrigin = ""
        }
        let url_pre = "https://apis-navi.kakaomobility.com/v1/directions?\(origins)&\(destinations)\(wayPointOrigin)&priority=\(priority)&avoid=\(avoid)&road_details=\(road_details)&alternatives=\(alternatives)&car_type=\(car_type)&summary=\(summary)&car_fuel=\(car_fuel)"
        //print("????????")
        //print(url_pre)
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
                //print(String(data: data_unwrapped, encoding: .utf8) ?? "")
                let datas = try JSONDecoder().decode(RouteData.self, from: data_unwrapped)
                //print(response ?? "")
                DispatchQueue.main.async {
                    self.route = datas.routes
                    //print(self.route.first?.result_msg ?? "")
                }
                
            } catch {
                print(error.localizedDescription)
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
let kakaoCategoryGroupCode: [String: String] = [
    "MT1" : "대형마트",
    "CS2" : "편의점",
    "PS3" : "어린이집, 유치원",
    "SC4" : "학교",
    "AC5" : "학원",
    "PK6" : "주차장",
    "OL7" : "주유소, 충전소",
    "SW8" : "지하철역",
    "BK9" : "은행",
    "CT1" : "문화시설",
    "AG2" : "중개업소",
    "PO3" : "공공기관",
    "AT4" : "광광명소",
    "AD5" : "숙박",
    "FD6" : "음식점",
    "CE7" : "카페",
    "HP8" : "병원",
    "PM9" : "약국"
]

struct SearchImageData: Codable {
    var meta: MetaData
    var documents: [ImgDocuments]
    
    struct MetaData: Codable {
        var total_count: Int?
        var pageable_count: Int?
        var is_end: Bool?
    }
}

struct ImgDocuments: Codable, Hashable {
    var collection: String?
    var thumbnail_url: String?
    var image_url: String?
    var width: Int?
    var height: Int?
    var display_sitename: String?
    var doc_url: String?
    var datetime: String?
}

struct RouteData: Codable {
    var trans_id: String
    var routes: [Route]
}

struct Route: Codable {
    var result_code: Int
    var result_msg: String
    var summary: RouteSummary
    var sections: [Sections]
    
    struct RouteSummary: Codable {
        var origin: RoutePlacesInfo
        var destination: RoutePlacesInfo
        var waypoints: [RoutePlacesInfo]
        var priority: String
        var bound: BoundBox?
        var fare: Fare // 택시 및 통행 요금
        var distance: Int //전체 검색 결과 거리(미터)
        var duration: Int //소요시간
        
        struct RoutePlacesInfo: Codable {
            var name: String
            var x: Double
            var y: Double
        }
        struct Fare: Codable {
            var taxi: Int //택시
            var toll: Int //통행
        }
        
    }
    struct BoundBox: Codable {
        var min_x: Double
        var min_y: Double
        var max_x: Double
        var max_y: Double
    }
    struct Sections: Codable {
        var distance: Int
        var duration: Int
        var bound: BoundBox?
        var roads: [Roads]?
        var guides: [Guides]?
        
        struct Roads: Codable {
            var name: String
            var distance: Int
            var duration: Int
            var traffic_speed: Double
            var traffic_state: Int
            var vertexes: [Double]
        }
        struct Guides: Codable {
            var name: String
            var distance: Int
            var duration: Int
            var x: Double
            var y: Double
            var type: Int
            var guidance: String
            var road_index: Int
        }
    }
}
