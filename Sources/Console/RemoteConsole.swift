import MultipeerConnectivity
import ExtensionKit
import Everything

public class RemoteConsole {

}

@MainActor
public class Server {

    let helper = MultipeerHelper(serviceType: "console")

    init() {
        print(helper)
        
    }

}


