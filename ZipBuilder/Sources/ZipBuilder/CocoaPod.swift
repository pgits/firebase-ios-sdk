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

import Foundation

// TODO: Auto generate this list from the Firebase.podspec and others, probably with a script.
/// All the CocoaPods related to packaging and distributing Firebase.
public enum CocoaPod: String, CaseIterable {
  case abTesting = "ABTesting"
  case adMob = "Google-Mobile-Ads-SDK"
  case analytics = "Analytics"
  case auth = "Auth"
  case core = "Core"
  case database = "Database"
  case dynamicLinks = "DynamicLinks"
  case firebase = "" // The Firebase pod
  case firestore = "Firestore"
  case functions = "Functions"
  case googleSignIn = "GoogleSignIn"
  case inAppMessaging = "InAppMessaging"
  case inAppMessagingDisplay = "InAppMessagingDisplay"
  case messaging = "Messaging"
  case mlModelInterpreter = "MLModelInterpreter"
  case mlNaturalLanguage = "MLNaturalLanguage"
  case mlNLLanguageID = "MLNLLanguageID"
  case mlNLSmartReply = "MLNLSmartReply"
  case mlNLTranslate = "MLNLTranslate"
  case mlVision = "MLVision"
  case mlVisionAutoML = "MLVisionAutoML"
  case mlVisionObjectDetection = "MLVisionObjectDetection"
  case mlVisionBarcodeModel = "MLVisionBarcodeModel"
  case mlVisionFaceModel = "MLVisionFaceModel"
  case mlVisionLabelModel = "MLVisionLabelModel"
  case mlVisionTextModel = "MLVisionTextModel"
  case performance = "Performance"
  case remoteConfig = "RemoteConfig"
  case storage = "Storage"

  /// Flag to explicitly exclude any Resources from being copied.
  public var excludeResources: Bool {
    switch self {
    case .mlVision, .mlVisionBarcodeModel, .mlVisionLabelModel:
      return true
    default:
      return false
    }
  }

  /// The name of the pod in the CocoaPods repo.
  public static func podName(pod :String) -> String {
    if (!pod.starts(with:"Google") && CocoaPod.allCases.map{ $0.rawValue }.contains(pod)) {
      return "Firebase\(pod)"
    }
    return pod
  }

  /// Describes the dependency on other frameworks for the README file.
  public static func readmeHeader(pod: String) -> String {
    var header = "## \(pod)"
    if !(pod == "Analytics" || pod == "GoogleSignIn") {
      header += " (~> Analytics)"
    }
    header += "\n"
    return header
  }

  // TODO: Evaluate if there's a way to do this that doesn't require the hardcoded values to be
  //   maintained. Likely looking at the `vendored_frameworks` from each Pod's Podspec.
  /// Returns folders to remove from the Zip file from a specific pod for de-duplication. This
  /// is necessary for the MLKit frameworks because of their unique structure, an unnecessary amount
  /// of frameworks get pulled in.
  public static func duplicateFrameworksToRemove(pod: String) -> [String] {
    switch pod {
    case "MLVisionBarcodeModel", "MLVisionFaceModel", "MLVisionLabelModel", "MLVisionTextModel":
      return ["GTMSessionFetcher.framework", "Protobuf.framework"]
    default:
      return []
    }
  }
}

/// Add comparitor for OperatingSystemVersion. We only need the `>` since we don't care about equals
/// or anything else, we just need to find the largest value between two structs.
extension OperatingSystemVersion: Comparable, Equatable {
  public static func < (lhs: OperatingSystemVersion, rhs: OperatingSystemVersion) -> Bool {
    // The priority is major.minor.patch, only keep searching to lower importance if the higher
    // levels are equal.
    if lhs.majorVersion < rhs.majorVersion { return true }
    if lhs.majorVersion > rhs.majorVersion { return false }

    // Major version must be equal, continue to minor.
    if lhs.minorVersion < rhs.minorVersion { return true }
    if lhs.minorVersion > rhs.minorVersion { return false }

    // Down to patch, just return the comparison since there are no more levels.
    return lhs.minorVersion < rhs.minorVersion
  }

  public static func > (lhs: OperatingSystemVersion, rhs: OperatingSystemVersion) -> Bool {
    // The priority is major.minor.patch, only keep searching to lower importance if the higher
    // levels are equal.
    if lhs.majorVersion > rhs.majorVersion { return true }
    if lhs.majorVersion < rhs.majorVersion { return false }

    // Major version must be equal, continue to minor.
    if lhs.minorVersion > rhs.minorVersion { return true }
    if lhs.minorVersion < rhs.minorVersion { return false }

    // Down to patch, just return the comparison since there are no more levels.
    return lhs.minorVersion > rhs.minorVersion
  }

  public static func == (lhs: OperatingSystemVersion, rhs: OperatingSystemVersion) -> Bool {
    return lhs.majorVersion == rhs.majorVersion &&
      lhs.minorVersion == rhs.minorVersion &&
      lhs.patchVersion == rhs.patchVersion
  }
}

extension OperatingSystemVersion {
  /// The string to define this operating system in a Podfile. In the form "MAJOR.MINOR"
  public func podVersion() -> String {
    return "\(majorVersion).\(minorVersion)"
  }
}
