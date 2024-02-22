//
//  KakaoMapView.swift
//  TravelMap
//
//  Created by 안병욱 on 1/27/24.
//

import SwiftUI
import UIKit
import KakaoMapsSDK

struct KakaoMapView: UIViewRepresentable {
    @Binding var draw: Bool
    @Binding var tap: Bool
    @Binding var day: Int
    @Binding var tap_place: Places
    @Binding var day_old: Int
    @Binding var points: [Places]
    //var positions: [MapPoint]
    var travel: TravelModel
    
    func makeUIView(context: Context) -> KMViewContainer {
        let view: KMViewContainer = KMViewContainer()
        view.sizeToFit()
        //view.frame(forAlignmentRect: CGRect(x: 0, y: 0, width: 100, height: 200))
        context.coordinator.createController(view)
        //context.coordinator.controller?.initEngine()
        
        return view
    }
    
    func updateUIView(_ uiView: KMViewContainer, context: Context) {
        if draw {
            context.coordinator.controller?.startEngine()
            context.coordinator.controller?.startRendering()
            context.coordinator.positions = self.travel
            //let msg = context.coordinator.controller?.getStateDescMessage()
            //print("////////////////")
            //print(msg ?? "메세지")
        } else {
            context.coordinator.controller?.stopEngine()
            context.coordinator.controller?.stopRendering()
        }
        //MARK: 선택된 일차 감지후 poi 호출
        if self.day != self.day_old {
            //self.kakaoSearch.route = []
            //self.kakaoSearch.searchRoute(places: self.travel.days.filter{$0.date == self.day}.first?.places.sorted(by: {$0.sequence < $1.sequence}) ?? [])
            context.coordinator.createPois(day: self.day)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                // 바로 바꾸면 뷰가 그려지지 않을 순간 호출되어 에러남
                self.day_old = self.day
                context.coordinator.move_whenPoiCreate()
            }
            //self.day_old = self.day
        }
        if !points.isEmpty {
            //context.coordinator.createRouteStyleSet(day: self.day)
            context.coordinator.createRouteline(day: self.day, points: self.points)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.points = []
            }
        }
    }
    
    func makeCoordinator() -> kakaoMapCoordinator {
        return kakaoMapCoordinator(tap: $tap, positions: self.travel, day: $day, tap_place: $tap_place)
    }
    
    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: kakaoMapCoordinator) {
        
    }
    
    class kakaoMapCoordinator: NSObject, MapControllerDelegate {
        
        func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
           let size = image.size
           
           let widthRatio  = targetSize.width  / size.width
           let heightRatio = targetSize.height / size.height
           
           // Figure out what our orientation is, and use that to form the rectangle
           var newSize: CGSize
           if(widthRatio > heightRatio) {
               newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
           } else {
               newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
           }
           
           // This is the rect that we've calculated out and this is what is actually used below
           let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
           
           // Actually do the resizing to the rect using the ImageContext stuff
           UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
           image.draw(in: rect)
           let newImage = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
           
           return newImage!
       }
        
        func authenticationSucceeded() {
            // 인증 감지
            print("성공")
            //인증 후 뷰 그리기
            addViews()
        }
        override init() {
            first = true
            _auth = false
            positions = TravelModel(title: "", days: [], icon: "", start_date: Date())
            self._tap = .constant(false)
            self._day = .constant(0)
            self._tap_place = .constant(Places(name: "", longitude: 0.0, latitude: 0.0, sequence: 1))
            super.init()
        }
        init(tap: Binding<Bool>, positions: TravelModel, day: Binding<Int>, tap_place: Binding<Places>) {
            first = true
            _auth = false
            self.positions = positions
            self._tap = tap
            self._day = day
            self._tap_place = tap_place
        }
        
        func createLabelLayer() {
            //Poi 레이어 그려줌
            //Poi가 지도에 그려지는 마크(맵핀임)
                let view = controller?.getView("mapview") as! KakaoMap
                let manager = view.getLabelManager()
                let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 10000)
                let _ = manager.addLabelLayer(option: layerOption)
            }
            
            // Poi 표시 스타일 생성
            func createPoiStyle() {
                let view = controller?.getView("mapview") as! KakaoMap
                let manager = view.getLabelManager()
                
                // PoiBadge는 스타일에도 추가될 수 있다. 이렇게 추가된 Badge는 해당 스타일이 적용될 때 함께 그려진다.
                let noti1 = PoiBadge(badgeID: "badge1", image: UIImage(systemName: "swift"), offset: CGPoint(x: 0.9, y: 0.1), zOrder: 0)
                // 줌 안되었을 때 그려지는 icon
                let poiImage = UIImage(named: "POI")
                let poiResize = resizeImage(image: poiImage!, targetSize: CGSizeMake(200.0, 200.0))
                let iconStyle1 = PoiIconStyle(symbol: poiImage, anchorPoint: CGPoint(x: 0.5, y: 0.5),transition: PoiTransition(entrance: .scale, exit: .scale) ,badges: [])
                //iconStyle1.symbol?.size = CGSize(width: 50, height: 50)
                let noti2 = PoiBadge(badgeID: "badge2", image: UIImage(systemName: "circle"), offset: CGPoint(x: 0.9, y: 0.1), zOrder: 0)
                // 일정 이상 줌하면 그려지는 icon
                let iconStyle2 = PoiIconStyle(symbol: poiImage/*?.withTintColor(.systemRed)*/, anchorPoint: CGPoint(x: 0.5, y: 0.5), badges: [])
                
                let red = TextStyle(fontSize: 40, fontColor: UIColor.black, strokeThickness: 2, strokeColor: UIColor.white)
                let blue = TextStyle(fontSize: 40, fontColor: UIColor.black, strokeThickness: 2, strokeColor: UIColor.white)
                
                // PoiTextStyle 생성
                let textStyle1 = PoiTextStyle(textLineStyles: [PoiTextLineStyle(textStyle: red)]) // 줌 안되었을 때 그려지는 스타일
                let textStyle2 = PoiTextStyle(textLineStyles: [PoiTextLineStyle(textStyle: blue)]) // 일정 이상 줌하면 그려지는 스타일
                
                let poiStyle = PoiStyle(styleID: "PerLevelStyle", styles: [
                    PerLevelPoiStyle(iconStyle: iconStyle1, textStyle: textStyle1, level: 5), // 줌 안되었을 때 그려지는 스타일
                    //PerLevelPoiStyle(iconStyle: iconStyle2, textStyle: textStyle2, level: 12) // 일정 이상 줌하면 그려지는 스타일
                ])
                manager.addPoiStyle(poiStyle)
            }
        
        // RouteStyleSet을 생성한다.
        func createRouteStyleSet(day: Int) {
            let mapView = self.controller?.getView("mapview") as? KakaoMap
            let manager = mapView?.getRouteManager()
            
            let _ = manager?.addRouteLayer(layerID: "RouteLayer", zOrder: 0)
            //let patternImages = [poiResize, UIImage(systemName: "arrowtriangle.right.fill"), UIImage(systemName: "arrowshape.up.circle.fill")]
            

//            styleSet.addPattern(RoutePattern(pattern: patternImages[1]!, distance: 6, symbol: nil, pinStart: true, pinEnd: true))
//            styleSet.addPattern(RoutePattern(pattern: patternImages[2]!, distance: 6, symbol: UIImage(named: "route_pattern_long_airplane.png")!, pinStart: true, pinEnd: true))
            
            //MARK: - 은수님 경로색 여기 추가하세요
            let colors = [ // 색 여기 추가하세요
                UIColor(red: 0.68, green: 0.87, blue: 1.00, alpha: 1.00),
                UIColor.black,
                UIColor.red,
                UIColor.green,
                UIColor.blue,
                UIColor.brown,
                UIColor.cyan,
                UIColor.darkGray
            ]
            //MARK: - 은수님 경로안 화살표 색 여기 추가하세요
            let patternColors = [
                UIColor(red: 0.32, green: 0.68, blue: 0.95, alpha: 1.00)
            ]
            //MARK: - 은수님 경로 아웃라인 여기 추가하세요
            let strokeColors = [
                UIColor.black
            ]
            // 위 색 array 개수 동일하게 맞추세요
            
            
            // StyleSet에 pattern을 추가한다.
            for dayIndex in 0...day {
                //MARK: - 은수님 주석 보고 변경하세요
                let patternImage = UIImage(systemName: "arrowtriangle.up.fill")?.withTintColor(patternColors[0]/*patternColors[dayIndex]로 변경하세요*/)
                let patternResize = resizeImage(image: patternImage!, targetSize: CGSizeMake(20.0, 20.0))
                let styleSet = RouteStyleSet(styleID: "routeStyleSet\(dayIndex)")
                styleSet.addPattern(RoutePattern(pattern: patternResize, distance: 60, symbol: nil, pinStart: false, pinEnd: false))
                
                let routeStyle = RouteStyle(styles: [PerLevelRouteStyle(width: 16, color: colors[dayIndex], strokeWidth: 3, strokeColor: strokeColors[0]/*strokeColors[dayIndex]로 변경하세요*/, level: 0, patternIndex: 0)])
                styleSet.addStyle(routeStyle)
                
                manager?.addRouteStyleSet(styleSet)
            }
            
        }
        
        func createRouteline(day: Int, points: [Places]) {
            //kakaoSearch.searchRoute(places: (self.positions.days.filter({ $0.date == day }).first?.places ?? []).sorted(by: {$0.sequence < $1.sequence}))
            let mapView = self.controller?.getView("mapview") as! KakaoMap
            let manager = mapView.getRouteManager()
            
            // Route 생성을 위해 RouteLayer를 생성한다.
            let layer = manager.getRouteLayer(layerID: "RouteLayer")/* manager.addRouteLayer(layerID: "RouteLayer", zOrder: 0)*/
            //manager.removeRouteLayer(layerID: "RouteLayer")
            
            layer?.clearAllRoutes()
            //print(layer?.layerID)
            // Route 생성을 위한 RouteSegment 생성
//            let points = (self.positions.days.filter({ $0.date == day }).first?.places ?? []).sorted(by: {$0.sequence < $1.sequence}).map{
//                MapPoint(longitude: $0.longitude, latitude: $0.latitude)
//            }
            let Points = points.map{MapPoint(longitude: $0.longitude, latitude: $0.latitude)}
            let segs = RouteSegment(points: Points, styleIndex: 0)
            //let seg = RouteSegment(points: points, styleIndex: styleIndex)
            //segments.append(segs)
//                let segmentPoints = route
//                var segments: [RouteSegment] = [RouteSegment]()
//                var styleIndex: UInt = 0
//                for points in segmentPoints {
//                    // 경로 포인트로 RouteSegment 생성. 사용할 스타일 인덱스도 지정한다.
//                    let seg = RouteSegment(points: points, styleIndex: styleIndex)
//                    segments.append(seg)
//                    styleIndex = (styleIndex + 1) % 4
//                }
                
                // Route 생성을 위해 ID, styleID, zOrder, segment를 전달한다.
            let routeOption = RouteOptions(styleID: "routeStyleSet\(day-1)", zOrder: 0)
            routeOption.segments = [segs]
            let routes = layer?.addRoute(option: routeOption)
            
            //let route = layer?.addRoute(option: <#RouteOptions#>, routeID: "routes", styleID: "routeStyleSet1", zOrder: 0, segments: segments)
                routes?.show()
            }
        
        func createPois(day: Int) {
            let view = controller?.getView("mapview") as! KakaoMap // 맵 뷰
            let manager = view.getLabelManager()
            let layer = manager.getLabelLayer(layerID: "PoiLayer") // poi 레이어 가져옴
            layer?.clearAllItems() // 일차가 달라지면 해당 일차 핀만 그리기 위해서 먼저 다 지움
            let poiOption = PoiOptions(styleID: "PerLevelStyle")
            poiOption.rank = 0 // poi스타일별 랭크
            poiOption.clickable = true  //클릭 이벤트 설정
            poiOption.addText(PoiText(text: "name", styleIndex: 0)) // 텍스트
            print(day, "//////////////////////////")
            for position in (self.positions.days.filter({ $0.date == day }).first?.places ?? []).sorted(by: {$0.sequence < $1.sequence}) { //선택된 일차의 장소 리스트 가져옴
                let poi = layer?.addPoi(option:poiOption, at: MapPoint(longitude: position.longitude, latitude: position.latitude)) // Poi 추가
                // Poi 랭크가 0 이라 그 위에 그려지기 위해서 zOrder 1임
                let badge_back = PoiBadge(badgeID: "num0", image: UIImage(systemName: "circle.fill")?.withTintColor(.white), offset: CGPoint(x: 0.9, y: 0.1), zOrder: 1)
                let badge = PoiBadge(badgeID: "num", image: UIImage(systemName: "\(position.sequence).circle.fill")?.withTintColor(.systemPink), offset: CGPoint(x: 0.9, y: 0.1), zOrder: 2)
                poi?.addBadge(badge)
                poi?.addBadge(badge_back)
                //Poi의 글자 그려줌
                self.tapPoint[poi?.itemID ?? "itemID"] = position
                poi?.changeTextAndStyle(texts: [PoiText(text: position.name, styleIndex: 0)], styleID: "PerLevelStyle")
                // poi 클릭되면 이벤트 실행
                let  poi_event = poi?.addPoiTappedEventHandler(target: self, handler: kakaoMapCoordinator.tapHandler)
                poi?.show()
                poi?.showBadges(badgeIDs: ["num", "num0"])
                }
            }
        
        
        func tapHandler(_ param: PoiInteractionEventParam) {
            self.tap = true
            let cameraPos = self.tapPoint[param.poiItem.itemID]
            self.tap_place = cameraPos!
            let mapView: KakaoMap? = controller?.getView("mapview") as? KakaoMap
            let cameraUpdate: CameraUpdate = CameraUpdate.make(target: MapPoint(longitude: cameraPos?.longitude ?? 0.0, latitude: cameraPos?.latitude ?? 0.0), mapView: mapView!)
            mapView?.moveCamera(cameraUpdate)
        }
        func move_whenPoiCreate() {
            let mapView: KakaoMap? = controller?.getView("mapview") as? KakaoMap
            let cameraUpdate: CameraUpdate = CameraUpdate.make(target: self.positions.days.filter{$0.date == self.day}.first?.places.filter{$0.sequence == 1}.first.map{MapPoint(longitude: $0.longitude, latitude: $0.latitude)} ?? MapPoint(longitude: 126.942250, latitude: 33.458528), mapView: mapView!)
            mapView?.moveCamera(cameraUpdate)
        }
        // 인증 실패시 호출.
        func authenticationFailed(_ errorCode: Int, desc: String) {
            print("error code: \(errorCode)")
            print("desc: \(desc)")
            _auth = false
            switch errorCode {
            case 400:
                print( "지도 종료(API인증 파라미터 오류)")
                break;
            case 401:
                print( "지도 종료(API인증 키 오류)")
                break;
            case 403:
                print( "지도 종료(API인증 권한 오류)")
                break;
            case 429:
                print( "지도 종료(API 사용쿼터 초과)")
                break;
            case 499:
                print( "지도 종료(네트워크 오류) 5초 후 재시도..")
                
                // 인증 실패 delegate 호출 이후 5초뒤에 재인증 시도..
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    print("retry auth...")
                    
                    self.controller?.authenticate()
                }
                break;
            default:
                break;
            }
        }
        
        func addViews() {
            let defaultPosition: MapPoint = self.positions.days.filter{$0.date == self.day}.first?.places.map{MapPoint(longitude: $0.longitude, latitude: $0.latitude)}.first ?? MapPoint(longitude: 126.942250, latitude: 33.458528)
            let mapviwInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 7)
            
            if controller?.addView(mapviwInfo) == Result.OK {
                print("OK")
            }
        }
        
       
        
        func containerDidResized(_ size: CGSize) {
            let mapView: KakaoMap? = controller?.getView("mapview") as? KakaoMap
            mapView?.viewRect = CGRect(origin: CGPoint.zero, size: size)
            if first {
                //초기화시 카레라 위치 정해줌 첫 장소 위치로 설정함
                let cameraUpdate: CameraUpdate = CameraUpdate.make(target: self.positions.days.filter{$0.date == self.day}.first?.places.filter{$0.sequence == 1}.first.map{MapPoint(longitude: $0.longitude, latitude: $0.latitude)} ?? MapPoint(longitude: 126.942250, latitude: 33.458528), mapView: mapView!)
                mapView?.moveCamera(cameraUpdate)
                first = false
            }
        }
        
        
        
        func createController(_ view: KMViewContainer) {
            // kakaomap 예시와 달리 update 뷰 전에 엔진을 작동해야 뷰가 그려짐
            controller = KMController(viewContainer: view)
            //controller?.proMotionSupport = true
            controller?.delegate = self
            controller?.initEngine()
            controller?.startEngine()
            controller?.startRendering()
            //self.controller?.authenticate()
            print(controller?.getStateDescMessage() ?? "")
            createLabelLayer()
            createPoiStyle()
            createPois(day: 1)
            createRouteStyleSet(day: positions.days.count-1)
            print(positions.days.count-1, "!")
            createRouteline(day: 1, points: [])
        }
        
        var _auth: Bool
        var controller: KMController?
        var first: Bool
        var positions: TravelModel
        var tapPoint: [String : Places] = [:]
        @Binding var tap: Bool
        @Binding var day: Int
        @Binding var tap_place: Places
    }
}

