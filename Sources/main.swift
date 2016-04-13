#if os(Linux)
    import Glibc
#else
    import Foundation
#endif

import Taylor

let server = Taylor.Server()
server.use("*", Middleware.requestLogger { print($0) })

server.get("/") {
    r, s in
    s.bodyString = "<html><body><form method=\"POST\">Name: <input type=\"text\" name=\"name\"/><input type=\"submit\"/></form></body></html>"
    s.headers["Content-Type"] = "text/html"
    return .Send
}

server.post("/", Middleware.bodyParser(), {
    r, s in

    let name = r.body["name"] ?? "<unknown>"
    s.bodyString = "Hi \(name)"
    return .Send
})

func getPort(default defaultPort: Int) -> Int {
  guard let portString = String.fromCString(getenv("PORT")),
            portNumber = Int(portString) else { return defaultPort }

  return portNumber
}

var port = getPort(default: 3002)

do {
    print("Staring server on port: \(port)")
    try server.serveHTTP(port: port, forever: true)
} catch let e {
    print("Server start failed \(e)")
}
