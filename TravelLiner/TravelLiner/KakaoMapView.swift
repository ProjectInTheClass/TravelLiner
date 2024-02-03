//
//  KakaoMapView.swift
//  TravelMap
//
//  Created by 안병욱 on 1/27/24.
//

import SwiftUI
import KakaoMapsSDK

struct KakaoMapView: UIViewRepresentable {
    @Binding var draw: Bool
    @Binding var tap: Bool
    @Binding var day: Int
    @State var day_old: Int  = 1
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
        if self.day != self.day_old {
            context.coordinator.createPois(day: self.day)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.day_old = self.day
            }
            //self.day_old = self.day
        }
    }
    
    func makeCoordinator() -> kakaoMapCoordinator {
        return kakaoMapCoordinator(tap: $tap, positions: self.travel, day: $day)
    }
    
    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: kakaoMapCoordinator) {
        
    }
    
    class kakaoMapCoordinator: NSObject, MapControllerDelegate {
        
        func authenticationSucceeded() {
            print("성공")
            addViews()
        }
//        func authenticationFailed(_ errorCode: Int, desc: String) {
//            print("error: ", errorCode)
//        }
        
        override init() {
            first = true
            _auth = false
            positions = TravelModel(title: "", days: [], icon: "", start_date: Date())
            self._tap = .constant(false)
            self._day = .constant(0)
            super.init()
        }
        init(tap: Binding<Bool>, positions: TravelModel, day: Binding<Int>) {
            first = true
            _auth = false
            self.positions = positions
            self._tap = tap
            self._day = day
        }
        
        func createLabelLayer() {
                let view = controller?.getView("mapview") as! KakaoMap
                let manager = view.getLabelManager()
                let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 0)
                let _ = manager.addLabelLayer(option: layerOption)
            }
            
            // Poi 표시 스타일 생성
            func createPoiStyle() {
                let view = controller?.getView("mapview") as! KakaoMap
                let manager = view.getLabelManager()
                
                // PoiBadge는 스타일에도 추가될 수 있다. 이렇게 추가된 Badge는 해당 스타일이 적용될 때 함께 그려진다.
                let noti1 = PoiBadge(badgeID: "badge1", image: UIImage(systemName: "swift"), offset: CGPoint(x: 0.9, y: 0.1), zOrder: 0)
                let iconStyle1 = PoiIconStyle(symbol: UIImage(systemName: "mapin"), anchorPoint: CGPoint(x: 0.0, y: 0.5),transition: PoiTransition(entrance: .scale, exit: .scale) ,badges: [])
                let noti2 = PoiBadge(badgeID: "badge2", image: UIImage(systemName: "circle"), offset: CGPoint(x: 0.9, y: 0.1), zOrder: 0)
                let iconStyle2 = PoiIconStyle(symbol: UIImage(systemName: "mappin.and.ellipse")?.withTintColor(.systemRed), anchorPoint: CGPoint(x: 0.5, y: 0.5), badges: [])
                
                let red = TextStyle(fontSize: 20, fontColor: UIColor.white, strokeThickness: 2, strokeColor: UIColor.red)
                let blue = TextStyle(fontSize: 40, fontColor: UIColor.black, strokeThickness: 2, strokeColor: UIColor.white)
                
                // PoiTextStyle 생성
                let textStyle1 = PoiTextStyle(textLineStyles: [PoiTextLineStyle(textStyle: red)])
                let textStyle2 = PoiTextStyle(textLineStyles: [PoiTextLineStyle(textStyle: blue)])
                
                let poiStyle = PoiStyle(styleID: "PerLevelStyle", styles: [
                    PerLevelPoiStyle(iconStyle: iconStyle1, textStyle: textStyle1, level: 5),
                    PerLevelPoiStyle(iconStyle: iconStyle2, textStyle: textStyle2, level: 12)
                ])
                manager.addPoiStyle(poiStyle)
            }
            
        
        func createPois(day: Int) {
            let view = controller?.getView("mapview") as! KakaoMap
            let manager = view.getLabelManager()
            let layer = manager.getLabelLayer(layerID: "PoiLayer")
            layer?.clearAllItems()
            let poiOption = PoiOptions(styleID: "PerLevelStyle")
            poiOption.rank = 0
            poiOption.clickable = true
            poiOption.addText(PoiText(text: "name", styleIndex: 0))
            //var PoiArrays: [Poi] = []
            print(day, "//////////////////////////")
            for position in self.positions.days.filter({ $0.date == day }).first?.places ?? [] {
                let poi = layer?.addPoi(option:poiOption, at: MapPoint(longitude: position.longitude, latitude: position.latitude))
                poi?.changeTextAndStyle(texts: [PoiText(text: position.name, styleIndex: 0)], styleID: "PerLevelStyle")
                    let  poi_event = poi?.addPoiTappedEventHandler(target: self, handler: kakaoMapCoordinator.tapHandler)
                    poi?.show()
                }
//                ForEach(self.positions, id: \.self) { position in
//                    let poi1 = layer?.addPoi(option:poiOption, at: position)
//                    let  _ = poi1?.addPoiTappedEventHandler(target: self, handler: kakaoMapCoordinator.tapHandler)
//                    // Poi 개별 Badge추가. 즉, 아래에서 생성된 Poi는 Style에 빌트인되어있는 badge와, Poi가 개별적으로 가지고 있는 Badge를 갖게 된다.
//                    //let badge = PoiBadge(badgeID: "noti", image: UIImage(systemName: "swift"), offset: CGPoint(x: 0, y: 0), zOrder: 1)
//                    //poi1?.addBadge(badge)
//                    //poi1?.show()
//                    
//                }
                //poi1?.showBadge(badgeID: "noti")
            }
        
        func tapHandler(_ param: PoiInteractionEventParam) {
            self.tap = true
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
                let cameraUpdate: CameraUpdate = CameraUpdate.make(target: self.positions.days.filter{$0.date == self.day}.first?.places.map{MapPoint(longitude: $0.longitude, latitude: $0.latitude)}.first ?? MapPoint(longitude: 126.942250, latitude: 33.458528), mapView: mapView!)
                mapView?.moveCamera(cameraUpdate)
                first = false
            }
        }
        
        func createController(_ view: KMViewContainer) {
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
        }
        
        var _auth: Bool
        var controller: KMController?
        var first: Bool
        var positions: TravelModel
        @Binding var tap: Bool
        @Binding var day: Int
    }
}

