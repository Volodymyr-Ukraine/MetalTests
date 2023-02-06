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
    
    case blur(Float)
    
    case cropX(Float)
    case cropY(Float)
    
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
        case .blur(_):
            return "blur"
        case .cropX(_):
            return "cropX"
        case .cropY(_):
            return "cropY"
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
        case .blur(let blur):
            return blur
        case .cropX(let size):
            return size
        case .cropY(let size):
            return size
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
