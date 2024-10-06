//
//  ViewController.swift
//  carPark
//
//  Created by Ира on 02.10.2024.
//

import UIKit

enum CargoType: Equatable {
    case fragile
    case perishable(Int)
    case bulk
}

struct Cargo {
    var description: String
    var weight: Int
    var type: CargoType
    
    init?(description: String, weight: Int, type: CargoType) {
        if (weight < 0) {
            return nil
        }
        
        self.description = description
        self.weight = weight
        self.type = type
    }
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let fleet = Fleet()

        let truck1 = Truck(make: "BMW", model: "M5", year: 2023, capacity: 1000, trailerAttached: true, trailerCapacity: 300, trailerTypes: [.fragile], fuelTankVolume: 300, fuelConsumption: 20)
        let cargo1 = Cargo(description: "Сыпучий", weight: 1000, type: .bulk)

        fleet.addVehicle(truck1)
        fleet.info()

        truck1.loadCargo(cargo: cargo1!)

        if truck1.canGo(cargo: cargo1!, path: 100) {
            print("Груз может быть перевезен")
        } else {
            print("Груз не может быть перевезен из-за нехватки топлива")
        }

        fleet.info()
    }
}

class Vehicle {
    var make: String
    var model: String
    var year: Int
    var capacity: Int
    var types: [CargoType]?
    var currentLoad: Int?
    
    var totalCapacity: Int {
        capacity
    }
    
    var totalLoadCurrent: Int {
        currentLoad ?? 0
    }
    
    var fuelTankVolume: Double
    var fuelConsumption: Double
    
    init(make: String, model: String, year: Int, capacity: Int, types: [CargoType]? = nil, currentLoad: Int? = nil, fuelTankVolume: Double, fuelConsumption: Double) {
        self.make = make
        self.model = model
        self.year = year
        self.capacity = capacity
        self.types = types
        self.currentLoad = currentLoad
        self.fuelTankVolume = fuelTankVolume
        self.fuelConsumption = fuelConsumption
    }
    
    func loadCargo(cargo: Cargo) {
        print("\n  Загрузка груза в машину")
        if canLoad(cargo: cargo) {
            currentLoad = cargo.weight + (currentLoad ?? 0)
            print("Загружен \(cargo.description) весом \(cargo.weight) кг. Текущая загрузка машины \(currentLoad ?? 0)")
        }
    }
    
    func canLoad(cargo: Cargo) -> Bool {
        if let types, !types.contains(cargo.type) {
            print("Груз с типом \(cargo.type) не может перевозиться в машине")
            return false
        }
        
        if (currentLoad ?? 0) + cargo.weight > capacity {
            print("\(cargo.description) груз, весом \(cargo.weight) превышает грузоподъемность машины")
            return false
        }
        
        return true
    }
    
    func unloadCargo() {
        currentLoad = 0
        print("Машина разгружена. Текущая загрузка \(currentLoad ?? 0)")
    }
    
    func info() {
        print("Марка машины: \(make), модель машины: \(model), год выпуска: \(year), грузоподъемность машины: \(capacity), текущая загрузка: \(currentLoad ?? 0)")
    }
    
    func canGo(cargo: Cargo, path: Int) -> Bool {
        let requiredFuel = Double(path) / 100 * fuelConsumption
        
        if requiredFuel > fuelTankVolume / 2 {
            print("Груз не может быть перевезен из-за нехватки топлива")
            return false
        }
        
        return true
    }
}

class Truck: Vehicle {
    var trailerAttached: Bool
    var trailerCapacity: Int?
    var trailerTypes: [CargoType]?
    var currentLoadTrailer: Int?
    
    override var totalCapacity: Int {
        capacity + (trailerCapacity ?? 0)
    }
    
    override var totalLoadCurrent: Int {
        (currentLoad ?? 0) + (currentLoadTrailer ?? 0)
    }
    
    init(make: String, model: String, year: Int, capacity: Int, trailerAttached: Bool, trailerCapacity: Int? = nil, trailerTypes: [CargoType]? = nil, currentLoadTrailer: Int? = nil, fuelTankVolume: Double, fuelConsumption: Double) {
        self.trailerAttached = trailerAttached
        self.trailerCapacity = trailerCapacity
        self.trailerTypes = trailerTypes
        self.currentLoadTrailer = currentLoadTrailer
        super.init(make: make, model: model, year: year, capacity: capacity, fuelTankVolume: fuelTankVolume, fuelConsumption: fuelConsumption)
    }
    
    override func loadCargo(cargo: Cargo) {
        if canLoad(cargo: cargo) {
            super.loadCargo(cargo: cargo)
        } else if canLoadTrailer(cargo: cargo) {
            currentLoadTrailer = cargo.weight + (currentLoadTrailer ?? 0)
            print("В прицеп загружен груз весом \(cargo.weight)")
        }
    }
    
    override func unloadCargo() {
        currentLoad = 0
        currentLoadTrailer = 0
        print("Машина разгружена")
    }
    
    func canLoadTrailer(cargo: Cargo) -> Bool {
        if trailerAttached, let trailerCapacity {
            print("  Загрузка груза в прицеп")
            if let trailerTypes, !trailerTypes.contains(cargo.type) {
                print("Груз с типом \(cargo.type) не может перевозиться в прицепе")
                return false
            }
            
            if cargo.weight + (currentLoadTrailer ?? 0) > trailerCapacity {
                print("Груз не может быть загружен")
                return false
            }
            return true
        }
        return false
    }
    
    override func info() {
        print("Марка машины: \(make), модель машины: \(model), год выпуска: \(year), грузоподъемность машины: \(capacity), текущая загрузка: \(currentLoad ?? 0), грузоподъемность прицепа: \(trailerCapacity ?? 0), текущая загрузка прицепа: \(currentLoadTrailer ?? 0)")
    }
}

class Fleet {
    var vehicles: [Vehicle] = []
    
    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
    }
    
    func totalCapacity() -> Int {
        var total: Int = 0//!!!
        for vehicle in vehicles {
            total += vehicle.totalCapacity
        }
        return total
    }
    
    func totalCurrentLoad() -> Int {
        var total: Int = 0//!!!
        for vehicle in vehicles {
            total += vehicle.totalLoadCurrent
        }
        return total
    }
    
    func info() {
        print("  Описание автопарка")
        for vehicle in vehicles {
            vehicle.info()
        }
        print("\nОбщая грузоподъемность машин: \(totalCapacity()), общая текущая загрузка машин: \(totalCurrentLoad())")
    }
}
