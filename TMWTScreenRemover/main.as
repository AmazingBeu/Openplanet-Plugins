string last_serverlogin = "";
bool removesign;
bool signremoved;

void RenderMenu() {
    if(UI::MenuItem("\\$77d" + Icons::User + " \\$fffTMWT Screen Remover", "", removesign)) {
        auto app = cast<CTrackMania>(GetApp());
        auto network = cast<CTrackManiaNetwork>(app.Network);
        auto serverinfo = cast<CTrackManiaNetworkServerInfo>(network.ServerInfo);
        if (network !is null && serverinfo !is null && serverinfo.ServerLogin != "") {
            removesign = true;
            signremoved = false;
        }
    }
}

void Main() {
    while(true) {

        auto app = cast<CTrackMania>(GetApp());
        auto network = cast<CTrackManiaNetwork>(app.Network);
        auto serverinfo = cast<CTrackManiaNetworkServerInfo>(network.ServerInfo);

        if (network !is null && serverinfo !is null) {
            if (last_serverlogin != serverinfo.ServerLogin) {
                last_serverlogin = serverinfo.ServerLogin;
                if (removesign) {
                    removesign = false;
                }
                if (signremoved) {
                    signremoved = false;
                }
            }

            if (removesign && !signremoved) {
                auto maniaapp = network.ClientManiaAppPlayground;
                if (maniaapp !is null) {
                    signremoved = true;
                    auto uilayers = maniaapp.UILayers;
                    for (uint i = 0; i < uilayers.Length; i++) {
                        string manialink = uilayers[i].ManialinkPage;
                        auto firstlines = manialink.Split("\n", 5);
                        if (firstlines.Length > 0) {
                            for (uint j = 0; j < firstlines.Length - 1; j++) {
                                if (firstlines[j].Contains("UIModule_TMWTTeams_Sign")) {
                                    maniaapp.UILayerDestroy(uilayers[i]);
                                }
                            }
                        }                   
                    }
                }
            }
        } else {
            if (last_serverlogin != "") {
                last_serverlogin = "";
            }
            if (removesign) {
                removesign = false;
            }
            if (signremoved) {
                signremoved = false;
            }
        }

        sleep(1000);
    }
}
