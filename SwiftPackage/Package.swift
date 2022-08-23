// swift-tools-version: 5.6

import PackageDescription
import Foundation

let package = Package(
  name: "ICU4C_WASI",
  products: [.library(name: "ICU4C_WASI", targets: ["ICU4C_WASI"])],
  targets: [
    .target(name: "ICU4C_WASI", cSettings: [
      .define("PACKAGE_DIR", to: "\"\(URL(fileURLWithPath: #filePath).deletingLastPathComponent().path)\""),
    ]),
  ]
)
