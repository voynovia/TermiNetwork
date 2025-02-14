// GlobalInterceptor.swift
//
// Copyright © 2018-2022 Vassilis Panagiotopoulos. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in the
// Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies
// or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FIESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import TermiNetwork

final class GlobalInterceptor: InterceptorProtocol {
    var retryLimit = 5
    var delay: TimeInterval = 1.3

    func requestFinished(responseData data: Data?,
                         error: TNError?,
                         request: Request,
                         proceed: (InterceptionAction) -> Void) {
        if case .networkError = error, request.retryCount < retryLimit {
            if request.retryCount == 4 {
                // Set the correct environment in order the request to succeed.
                request.environment = Env.termiNetworkRemote.configure()
            }
            proceed(.retry(delay: delay))
        } else {
            proceed(.continue)
        }
    }
}
