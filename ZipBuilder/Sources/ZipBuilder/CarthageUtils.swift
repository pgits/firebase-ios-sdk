/*
 * Copyright 2019 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import CommonCrypto
import Foundation

/// Carthage related utility functions. The enum type is used as a namespace here instead of having
/// root functions, and no cases should be added to it.
public enum CarthageUtils {}

public extension CarthageUtils {
  static func generateCarthageRelease(fromPackagedDir packagedDir: URL, outputDir: URL) {
    // TODO: Get Firebase version (either parse readme or pass it in, likely pass it in)

    let directories: [String]
    do {
      directories = try FileManager.default.contentsOfDirectory(atPath: packagedDir.path)
    } catch {
      fatalError("Could not get contents of Firebase directory to package Carthage build. \(error)")
    }

    // Loop through each directory available
    for productDir in directories {
      let fullPath = packagedDir.appendingPathComponent(productDir)
      guard FileManager.default.isDirectory(at: fullPath) else { continue }

      // TODO: Get JSON file and parse it.
      // TODO: Skip this directory if it's already been published.

      // Find all the .frameworks in this directory.
      let allContents: [String]
      do {
        allContents = try FileManager.default.contentsOfDirectory(atPath: fullPath.path)
      } catch {
        fatalError("Could not get contents of \(productDir) for Carthage build in order to add " +
          "an Info.plist in each framework. \(error)")
      }

      // Carthage will fail to install a framework if it doesn't have an Info.plist, even though
      // they're not used for static frameworks. Generate one and write it to each framework.
      let frameworks = allContents.filter { $0.hasSuffix(".framework") }
      for framework in frameworks {
        let plistPath = fullPath.appendingPathComponents([framework, "Info.plist"])
        // Drop the extension of the framework name.
        let plist = generatePlistContents(forName: framework.components(separatedBy: ".").first!)
        do {
          try plist.write(to: plistPath)
        } catch {
          fatalError("Could not copy plist for \(framework) for Carthage release. \(error)")
        }
      }

      // Analytics includes all the Core frameworks and Firebase module, do extra work to package
      // it.
      if productDir == "Analytics" {
        // TODO: Create a `Firebase` framework to support `import Firebase` and `Firebase.h`.
        // TODO: Rebuild CoreDiagnostics to include the correct compiler flag.
        //    let builder = FrameworkBuilder(projectDir: <#T##URL#>, carthageBuild: true)

        // Copy the NOTICES file from FirebaseCore.
        let noticesName = "NOTICES"
        let coreNotices = fullPath.appendingPathComponents(["FirebaseCore.framework", noticesName])
        let noticesPath = packagedDir.appendingPathComponent(noticesName)
        do {
          try FileManager.default.copyItem(at: noticesPath, to: coreNotices)
        } catch {
          fatalError("Could not copy \(noticesName) to FirebaseCore for Carthage build. \(error)")
        }
      }

      // Hash the contents of the directory to get a unique name for Carthage.
      let hash: String
      do {
        // Only use the first 16 characters, that's what we did before.
        hash = try String(hashContents(forDir: fullPath).prefix(16))
      } catch {
        fatalError("Could not hash contents of \(productDir) for Carthage build. \(error)")
      }

      let zipName = "\(productDir)-\(hash).zip"
      let productZip = outputDir.appendingPathComponent(zipName)
      let zipped = Zip.zipContents(ofDir: fullPath)
      do {
        try FileManager.default.moveItem(at: zipped, to: productZip)
      } catch {
        fatalError("Could not move packaged zip file for \(productDir) during Carthage build. " +
          "\(error)")
      }
    }
  }

  private static func generatePlistContents(forName name: String) -> Data {
    let plist: [String: String] = ["CFBundleIdentifier": "com.firebase.Firebase",
                                   "CFBundleInfoDictionaryVersion": "6.0",
                                   "CFBundlePackageType": "FMWK",
                                   "CFBundleVersion": "1",
                                   "DTSDKName": "iphonesimulator11.2",
                                   "CFBundleExecutable": name,
                                   "CFBundleName": name]

    // Generate the data for an XML based plist.
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml
    do {
      return try encoder.encode(plist)
    } catch {
      fatalError("Failed to create Info.plist for \(name) during Carthage build: \(error)")
    }
  }

  /// Hashes the contents of the directory recursively.
  private static func hashContents(forDir dir: URL) throws -> String {
    var hasher = Hasher()
    let allContents = try FileManager.default.recursivelySearch(for: .allFiles, in: dir)
    // Sort the contents to make it deterministic.
    let sortedContents = allContents.sorted { $0.absoluteString < $1.absoluteString }
    for file in sortedContents {
      guard let data = FileManager.default.contents(atPath: file.path) else {
        fatalError("Could not get contents of \(file) when hashing for Carthage.")
      }

      data.withUnsafeBytes {
        hasher.combine(bytes: $0)
      }
    }

    let hashValue = hasher.finalize()
    return "\(hashValue)"
  }
}