import MultipeerConnectivity

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


