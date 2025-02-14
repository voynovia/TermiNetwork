// TestDownloadOperations.swift
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

import XCTest
import TermiNetwork

class TestDownloadOperations: XCTestCase {
    lazy var configuration: Configuration = {
        return Configuration(cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                             verbose: true)
    }()

    lazy var router: Router<APIRoute> = {
        return Router<APIRoute>(environment: Env.termiNetworkRemote,
                                configuration: configuration)
    }()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Environment.set(Env.termiNetworkLocal)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    class FileResponse: Decodable {
        var success: Bool
        var checksum: String
    }

    func testFileDownload() {
        let expectation = XCTestExpectation(description: "testFileDownload")

        var failed = true

        guard var cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            XCTAssert(false)
            return
        }
        cacheURL.appendPathComponent("testDownload")

        try? FileManager.default.removeItem(at: cacheURL)

        router.request(for: .fileDownload)
            .download(destinationPath: cacheURL.path,
                      progressUpdate: { bytesSent, totalBytes, progress in
                        if bytesSent == totalBytes && progress == 1 {
                            failed = false
                        }
                      },
                      completionHandler: {
                        failed = TestHelpers.sha256(url: cacheURL) !=
                            "63b54b4506e233839f55e1228b59a1fcdec7d5ff9c13073c8a1faf92e9dcc977"

                        expectation.fulfill()
                      })
            .failure { error in
                failed = true
                print(String(describing: error.localizedDescription))
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 500)

        XCTAssert(!failed)
    }

    func testInvalidFileDownload() {
        let expectation = XCTestExpectation(description: "testInvalidFileDownload")

        var failed = true

        router.request(for: .fileDownload)
            .download(destinationPath: "",
                      progressUpdate: { bytesSent, totalBytes, progress in
                        if bytesSent == totalBytes && progress == 1 {
                            failed = false
                        }
                      },
                      completionHandler: {
                        failed = true
                        expectation.fulfill()
                      })
            .failure { error in
                if case .invalidFileURL = error {
                    failed = false
                }
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 500)

        XCTAssert(!failed)
    }
}
