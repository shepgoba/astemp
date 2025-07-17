import Foundation

func get_sensors_for_platform() -> [String] {
    var size = 0
    sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)

    var result = [CChar](repeating: 0, count: size)
    sysctlbyname("machdep.cpu.brand_string", &result, &size, nil, 0)

    let chipName = String(cString: result).lowercased()

    let platform: String
    if chipName.contains("m1") {
        platform = "m1"
    } else if chipName.contains("m2") {
        platform = "m2"
    } else if chipName.contains("m3") {
        platform = "m3"
    } else if chipName.contains("m4") {
        platform = "m4"
    } else {
        platform = "unknown"
    }

    switch platform {
    case "m1":
        return ["Tp09", "Tp0T", "Tp01", "Tp05", "Tp0D", "Tp0H", "Tp0L", "Tp0P", "Tp0X", "Tp0b"]
    case "m2":
        return ["Tp1h", "Tp1t", "Tp1p", "Tp1l", "Tp01", "Tp05", "Tp09", "Tp0D", "Tp0X", "Tp0b", "Tp0f", "Tp0j"]
    case "m3":
        return ["Te05", "Te0L", "Te0P", "Te0S", "Tf04", "Tf09", "Tf0A", "Tf0B", "Tf0D", "Tf0E", "Tf44", "Tf49", "Tf4A", "Tf4B", "Tf4D", "Tf4E"]
    case "m4":
        return ["Te05", "Te09", "Te0H", "Te0S", "Tp01", "Tp05", "Tp09", "Tp0D", "Tp0V", "Tp0Y", "Tp0b", "Tp0e"]
    default:
        return []
    }
}

func get_temp(fallback_sensors: [String]) -> Double {
    var temperature: Double? = nil
    
    if let value = SMC.shared.getValue("TC0D"), value < 110 {
        temperature = value
    } else if let value = SMC.shared.getValue("TC0E"), value < 110 {
        temperature = value
    } else if let value = SMC.shared.getValue("TC0F"), value < 110 {
        temperature = value
    } else if let value = SMC.shared.getValue("TC0P"), value < 110 {
        temperature = value
    } else if let value = SMC.shared.getValue("TC0H"), value < 110 {
        temperature = value
    } else {
        var total: Double = 0
        var counter: Double = 0
        fallback_sensors.forEach { (key: String) in
            if let value = SMC.shared.getValue(key) {
                total += value
                counter += 1
            }
        }
        if total != 0 && counter != 0 {
            temperature = total / counter
        }
    }
    
    return temperature!
}


let sensors = get_sensors_for_platform()
while (true) {
    let t = String(format: "%.2f", get_temp(fallback_sensors: sensors))
    print("CPU Temp: \(t) °C")
    sleep(1)
}
