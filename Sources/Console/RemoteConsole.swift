import Everything
import ExtensionKit
import MultipeerConnectivity

public class RemoteConsole {}

@MainActor
public class Server {
    let helper = MultipeerHelper(serviceType: "console")

    init() {
        print(helper)
    }
}
