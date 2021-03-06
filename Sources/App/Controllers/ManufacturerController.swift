//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import HTTP

final class ManufacturerController {

    var droplet: Droplet!

    func addRoutes(droplet: Droplet) {
        self.droplet = droplet
        let group = droplet.grouped("manufacturer")
        group.get(handler: manufacturer)
    }

    func manufacturer(request: Request) throws -> ResponseRepresentable {
        let queryManufacturer = request.query?["name"]?.string ?? ""
        let manufacturer = try Manufacturer.makeQuery().filter("approved", true).filter("name", queryManufacturer).first()
        let categories = try Category.all()

        let node: Node

        if let manufacturer = manufacturer {
            let accessories = try manufacturer.accessories.filter("approved", true).all()
            let pageTitle = manufacturer.name
            node = try Node(node: [
                "manufacturerSelected": true,
                "categories": categories.makeNode(in: nil),
                "accessories": accessories.makeNode(in: nil),
                "pageTitle": pageTitle.makeNode(in: nil),
                "manufacturerLink": accessories.first?.manufacturer.get()?.websiteLink ?? ""
            ])
        } else {
            let manufacturers = try Manufacturer.makeQuery().filter("approved", true).all()
            let pageTitle = "All Manufacturers"
            let pageIcon = ""
            node = try Node(node: [
                "manufacturerSelected": false,
                "categories": categories.makeNode(in: nil),
                "manufacturers": manufacturers.makeNode(in: nil),
                "pageTitle": pageTitle.makeNode(in: nil),
                "pageIcon": pageIcon.makeNode(in: nil)
            ])
        }
        return try droplet.view.make("manufacturer", node)
    }
}
