import LocalAuthentication

public typealias argv_t = UnsafePointer<UnsafeMutablePointer<CChar>>
public typealias pam_handle_t = UnsafeRawPointer

@_silgen_name("pam_sm_authenticate")
public func pam_sm_authenticate(pamh: pam_handle_t, flags: Int, argc: Int, argv: argv_t) -> Int {
    let arguments = parseArguments(argc: argc, argv: argv)

    let reason: String
    if let r = arguments["reason"] ?? "", !r.isEmpty {
        reason = r
    } else {
        reason = "perform an action that requires authentication"
    }

    let semaphore = DispatchSemaphore(value: 0)
    let context = LAContext()
    var result = PAM_AUTH_ERR

    context.evaluatePolicy(.deviceOwnerAuthenticationIgnoringUserID, localizedReason: reason) { success, error in
        defer { semaphore.signal() }

        if let error = error {
            fputs("\(error.localizedDescription)\n", stderr)
        }

        result = success ? PAM_SUCCESS : PAM_AUTH_ERR
    }

    semaphore.wait()
    return result
}

@_silgen_name("pam_sm_chauthtok")
public func pam_sm_chauthtok(pamh: pam_handle_t, flags: Int, argc: Int, argv: argv_t) -> Int {
    return PAM_IGNORE
}

@_silgen_name("pam_sm_setcred")
public func pam_sm_setcred(pamh: pam_handle_t, flags: Int, argc: Int, argv: argv_t) -> Int {
    return PAM_IGNORE
}

@_silgen_name("pam_sm_acct_mgmt")
public func pam_sm_acct_mgmt(pamh: pam_handle_t, flags: Int, argc: Int, argv: argv_t) -> Int {
    return PAM_IGNORE
}

private extension LAPolicy {
    static let deviceOwnerAuthenticationIgnoringUserID: LAPolicy = LAPolicy(rawValue: 0x3f0)!
}

private func parseArguments(argc: Int, argv: argv_t) -> [String: String?] {
    let args = (0..<argc)
        .map { String(cString: argv[$0]) }
        .joined(separator: " ") as NSString

    // The following code turns an input string like
    //   "a b=c d=\"e f\" g= h"
    // into a map like
    //   ["b": Optional("c"), "a": nil, "g": nil, "d": Optional("e f"), "h": nil]
    let regex = try! NSRegularExpression(pattern: "([^ =]+)(?:=(?:\"((?:[^\"\\\\]|\\\\.)*)\"|([^ ]*)))?", options: [])
    let matches = regex.matches(in: args as String, range: NSRange(location: 0, length: args.length))
    var results = [String: String?]()

    for m in matches {
        let key = args.substring(with: m.range(at: 1))

        let valueRange1 = m.range(at: 2)
        let valueRange2 = m.range(at: 3)
        let value: String?

        if valueRange1.lowerBound != NSNotFound && valueRange1.lowerBound != valueRange1.upperBound {
            value = args.substring(with: valueRange1)
        } else if valueRange2.lowerBound != NSNotFound && valueRange2.lowerBound != valueRange2.upperBound {
            value = args.substring(with: valueRange2)
        } else {
            value = nil
        }

        results[key] = value
    }

    return results
}

