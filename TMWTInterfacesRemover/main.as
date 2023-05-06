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

bool IsPlaying() {
    auto app = cast<CTrackMania>(GetApp());
    auto CurrentPlayground = cast<CGamePlayground>(app.CurrentPlayground);

    if (CurrentPlayground is null) return false;
    if (CurrentPlayground.GameTerminals.Length < 1) return false;
    if (CurrentPlayground.GameTerminals[0].ControlledPlayer is null) return false;
    if (CurrentPlayground.GameTerminals[0].ControlledPlayer.User is null) return false;
    if (CurrentPlayground.GameTerminals[0].GUIPlayer is null) return false;
    if (CurrentPlayground.GameTerminals[0].GUIPlayer.User is null) return false;

    if (CurrentPlayground.GameTerminals[0].ControlledPlayer.User.Login == CurrentPlayground.GameTerminals[0].GUIPlayer.User.Login) return true;

    return false;
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
        yield();
        auto app = cast<CTrackMania>(GetApp());
        auto network = cast<CTrackManiaNetwork>(app.Network);
        auto serverinfo = cast<CTrackManiaNetworkServerInfo>(network.ServerInfo);

        if (network !is null && serverinfo !is null) {
            if (Last_ServerLogin != serverinfo.ServerLogin) {
                Last_ServerLogin = serverinfo.ServerLogin;
                @UILayer_LiveRanking = null;
                @UILayer_TeamsScores = null;
                HideInterfaces = false;
                InterfacesAreHidden = false;
            }

            // Prevent to continue the loop when not needed
            if (!HideInterfaces && !InterfacesAreHidden) continue;

            CGameManiaAppPlayground@ ManiaApp = cast<CGameManiaAppPlayground>(network.ClientManiaAppPlayground);
            if (ManiaApp !is null) {
                if (UILayer_LiveRanking is null) {
                    @UILayer_LiveRanking = findUILayer(ManiaApp.UILayers, "UIModule_TMWTCommon_LiveRanking");
                }
                if (UILayer_TeamsScores is null) {
                    @UILayer_TeamsScores = findUILayer(ManiaApp.UILayers, "UIModule_TMWTCommon_Header");
                }
                if (UILayer_TeamsScores is null && UILayer_LiveRanking is null) {
                    UI::ShowNotification("\\$77d" + Icons::User + " \\$fffTMWT Interfaces Remover", "Can't find Interfaces to hide, disabling the plugin");
                    HideInterfaces = false;
                    InterfacesAreHidden = false;
                }
                if (HideInterfaces && !InterfacesAreHidden && IsPlaying() ) {
                    if (HideLiveRanking && UILayer_LiveRanking !is null) {
                        UILayer_LiveRanking.IsVisible = false;
                    }
                    if (HideTeamsScores && UILayer_TeamsScores !is null) {
                        UILayer_TeamsScores.IsVisible = false;
                    }
                    InterfacesAreHidden = true;
                } else if (InterfacesAreHidden && (!HideInterfaces || !IsPlaying())) {
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

    }
}
