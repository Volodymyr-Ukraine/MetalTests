//
//  Filter.swift
//  Image Editor Demo
//
//  Created by Volodymyr Shynkarenko on 13.01.2023.
//

import Foundation

import SettingsViewController

public enum Filter {
    case temperature(Float)
    case tint(Float)
    case brightness(Float)
    case bw(Bool)
    
    case contrast(Float)
    case saturation(Float)
    
    var id: String {
        switch self {
        case .temperature(_):
            return "temperature"
        case .tint(_):
            return "tint"
        case .brightness(_):
            return "brightness"
        case .bw(_):
            return "bw"
        case .contrast(_):
            return "contrast"
        case .saturation(_):
            return "saturation"
        }
    }
    
    var value: Any {
        switch self {
        case .temperature(let temperature):
            return temperature
        case .tint(let tint):
            return tint
        case .brightness(let brightness):
            return brightness
        case .bw(let bw):
            return bw
        case .contrast(let contrast):
            return contrast
        case .saturation(let saturation):
            return saturation
        }
    }
    
    var floatValue: Float? {
        value as? Float
    }
}

//public extension FloatSetting {
//    init?(name: String,
//         defaultFilter: Filter,
//         min: Float,
//         max: Float,
//         context: ShaderContext,
//         onChangeHandler: @escaping Handler) {
//
//        self.init(name: name,
//                  defaultValue: defaultFilter.value,
//             min: min,
//             max: max) {
//            context.addFilter(<#T##filter: Filter##Filter#>)
//    self.adjustments.temperature = $0
//    self.redraw()
//}
//
//    }
//}
