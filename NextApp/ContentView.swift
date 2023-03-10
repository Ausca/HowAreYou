//
//  ContentView.swift
//  NextApp
//
//  Created by Allen Zhang on 12/13/22.
//

import SwiftUI
import Combine
import Foundation


let defaults = UserDefaults.standard
let format = "EEEE, MM-dd-yyyy"
struct Data : Codable{
    var date: String
    var value: Float
}
extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
func getData() -> [Data] {
    let fetchedData = UserDefaults.standard.data(forKey: "values")
    if fetchedData == nil {
        return []
    }
    return try! PropertyListDecoder().decode([Data].self, from: fetchedData!)
}
func defaultValue() -> Float {
    let values = getData()
    print(values)
    if values.count == 0 {
        return 50
    }
    else {
        return values.last!.value
    }
}
func getValueByDate(date: Date) -> Float {
    let data = getData()
    for datum in data {
        if (datum.date == convDate(date: date)) {
            return datum.value
        }
    }
    return 50
}
func convDate(date: Date) -> String {
    return date.string(format: format);
}
func getImage(value: Float) -> String {
    let toInt: Int = Int(value)+10
    return "frame_" + String(toInt);
}
struct ContentView: View {

    @State var progress: Float = defaultValue()
    @State var date: Date = Date()
    var body: some View {
       VStack{
           DatePicker("What day?", selection: $date, in:...Date(), displayedComponents: [.date]).id(date)
               .onChange(of: date) { newDate in
                   self.progress = getValueByDate(date: newDate)
               }
               .padding()
          // Image(getImage(value: progress)).resizable()
//               .scaledToFit()
           //Text(convDate(date: date))
           Spacer()
               Slider(value: Binding(get: {
                   self.progress
               }, set: { (newVal) in
                   self.progress = newVal
                   self.sliderChanged()
               }), in: 0...100) {
                   Text("Slider").foregroundColor(.white)
               } minimumValueLabel: {
                   Text("0").foregroundColor(.white)
               } maximumValueLabel: {
                   Text("100").foregroundColor(.white)
               }
               .padding([.trailing, .top, .leading]).disabled(convDate(date: self.date) != convDate(date: Date()))
                
           Text(String(Int(getValueByDate(date: date)))).padding(.bottom).foregroundColor(.white)
       }.background(Image(getImage(value: progress)).resizable().scaledToFill())
    }

    func sliderChanged() {
        print("Slider value changed to \(progress)")
        let date = convDate(date: date)
        var values = getData()
        if (values.count > 0 && values.last!.date == date) {
            values[values.endIndex-1] = Data(date: date, value: progress)
        }
        else {
            values.append(Data(date: date, value: progress))
        }
        print(values)
        defaults.set(try! PropertyListEncoder().encode(values), forKey: "values")
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
