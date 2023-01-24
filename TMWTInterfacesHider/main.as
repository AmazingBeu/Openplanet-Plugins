bool InterfacesAreHidden;
bool HideInterfaces;
string Last_ServerLogin;
CGameUILayer@ UILayer_LiveRanking;
CGameUILayer@ UILayer_TeamsScores;

void RenderMenu() {
    if(UI::MenuItem("\\$77d" + Icons::User + " \\$fffTMWT Interfaces Remover", "", HideInterfaces)) {
        auto app = cast<CTrackMania>(GetApp());
        auto network = cast<CTrackManiaNetwork>(app.Network);
        auto serverinfo = cast<CTrackManiaNetworkServerInfo>(network.ServerInfo);
        if (network !is null && serverinfo !is null && serverinfo.ServerLogin != "") {
            HideInterfaces = !HideInterfaces;
        }
    }
}

CGameUILayer@ findUILayer(const MwFastBuffer<CGameUILayer@> _UILayers, string _ManialinkId) {
    for (uint i = 0; i < _UILayers.Length; i++) {
        string manialink = _UILayers[i].ManialinkPage;
        auto firstlines = manialink.Split("\n", 5);
        if (firstlines.Length > 0) {
            for (uint j = 0; j < firstlines.Length - 1; j++) {
                if (firstlines[j].Contains(_ManialinkId)) {
                    return _UILayers[i];
                }
            }
        }
    }
    return null;
}

void Main() {
    while(true) {
        auto app = cast<CTrackMania>(GetApp());
        auto network = cast<CTrackManiaNetwork>(app.Network);
        auto serverinfo = cast<CTrackManiaNetworkServerInfo>(network.ServerInfo);

        if (network !is null && serverinfo !is null) {
            if (Last_ServerLogin != serverinfo.ServerLogin) {
                Last_ServerLogin = serverinfo.ServerLogin;
                HideInterfaces = false;
                InterfacesAreHidden = false;
            }

            CGameManiaAppPlayground@ ManiaApp = cast<CGameManiaAppPlayground>(network.ClientManiaAppPlayground);
            if (ManiaApp !is null) {
                if (UILayer_LiveRanking is null) {
                    @UILayer_LiveRanking = findUILayer(ManiaApp.UILayers, "UIModule_TMWTTeams_LiveRanking");
                }
                if (UILayer_TeamsScores is null) {
                    @UILayer_TeamsScores = findUILayer(ManiaApp.UILayers, "UIModule_TMWTTeams_Header");
                }
                if (HideInterfaces && !InterfacesAreHidden && ManiaApp.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::Playing) {
                    if (HideLiveRanking && UILayer_LiveRanking !is null) {
                        UILayer_LiveRanking.IsVisible = false;
                    }
                    if (HideTeamsScores && UILayer_TeamsScores !is null) {
                        UILayer_TeamsScores.IsVisible = false;
                    }
                    InterfacesAreHidden = true;
                } else if (InterfacesAreHidden && (!HideInterfaces || ManiaApp.UI.UISequence != CGamePlaygroundUIConfig::EUISequence::Playing)) {
                    if (UILayer_LiveRanking !is null) {
                        UILayer_LiveRanking.IsVisible = true;
                    }
                    if (UILayer_TeamsScores !is null) {
                        UILayer_TeamsScores.IsVisible = true;
                    }
                    InterfacesAreHidden = false;
                }
            }
        } else {
            Last_ServerLogin = "";
            HideInterfaces = false;
            InterfacesAreHidden = false;
            @UILayer_LiveRanking = null;
            @UILayer_TeamsScores = null;
        }
        yield();
    }
}
