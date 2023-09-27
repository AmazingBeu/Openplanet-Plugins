const string C_Class_UIModules = 'component-cmgame-uimodules-module';
const string C_Id_TMWT_LiveRanking = 'TMWTCommon_LiveRanking';
const string C_Id_TMWT_Header = 'TMWTCommon_Header';
const string C_Id_TMWC2023_LiveRanking = 'TMWC2023_LiveRanking';
const string C_Id_TMWC2023_Header = 'TMWC2023_Header';


bool G_InterfacesAreHidden;
bool G_HideInterfaces;
string G_Last_ServerLogin;
CGameUILayer@ G_UILayer_LiveRanking;
CGameUILayer@ G_UILayer_TeamsScores;

void OnSettingsChanged() {
	trace("Settings updated");
    @G_UILayer_LiveRanking = null;
    @G_UILayer_TeamsScores = null;
    G_InterfacesAreHidden = false;
}


void RenderMenu() {
    if(UI::MenuItem("\\$77d" + Icons::User + " \\$fffTMWT Interfaces Remover", "", G_HideInterfaces)) {
        auto app = cast<CTrackMania>(GetApp());
        auto network = cast<CTrackManiaNetwork>(app.Network);
        auto serverinfo = cast<CTrackManiaNetworkServerInfo>(network.ServerInfo);
        if (network !is null && serverinfo !is null && serverinfo.ServerLogin != "") {
            G_HideInterfaces = !G_HideInterfaces;
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
    for (uint Index = 0; Index < _UILayers.Length; ++Index) {
		CGameUILayer@ Layer = _UILayers[Index];
		CGameManialinkPage@ Page = Layer.LocalPage;

		// Check if we have the main UI module
		Page.GetClassChildren(C_Class_UIModules, Page.MainFrame, true);

		if (Page.GetClassChildren_Result.Length > 0) {
			if (Page.GetClassChildren_Result[0].ControlId == _ManialinkId) {
				return _UILayers[Index];
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
            if (G_Last_ServerLogin != serverinfo.ServerLogin) {
                G_Last_ServerLogin = serverinfo.ServerLogin;
                @G_UILayer_LiveRanking = null;
                @G_UILayer_TeamsScores = null;
                G_HideInterfaces = false;
                G_InterfacesAreHidden = false;
            }

            // Prevent to continue the loop when not needed
            if (!G_HideInterfaces && !G_InterfacesAreHidden) continue;

            CGameManiaAppPlayground@ ManiaApp = cast<CGameManiaAppPlayground>(network.ClientManiaAppPlayground);
            if (ManiaApp !is null) {
                if (G_UILayer_LiveRanking is null) {
                    if (Setting_GameMode == GameMode::TMWT) @G_UILayer_LiveRanking = findUILayer(ManiaApp.UILayers, C_Id_TMWT_LiveRanking);
                    else if (Setting_GameMode == GameMode::TMWC2023) @G_UILayer_LiveRanking = findUILayer(ManiaApp.UILayers, C_Id_TMWC2023_LiveRanking);
                }
                if (G_UILayer_TeamsScores is null) {
                    if (Setting_GameMode == GameMode::TMWT) @G_UILayer_TeamsScores = findUILayer(ManiaApp.UILayers, C_Id_TMWT_Header);
                    else if (Setting_GameMode == GameMode::TMWC2023) @G_UILayer_TeamsScores = findUILayer(ManiaApp.UILayers, C_Id_TMWC2023_Header);
                }
                if (G_UILayer_TeamsScores is null && G_UILayer_LiveRanking is null) {
                    UI::ShowNotification("\\$77d" + Icons::User + " \\$fffTMWT Interfaces Remover", "Can't find Interfaces to hide, disabling the plugin");
                    G_HideInterfaces = false;
                    G_InterfacesAreHidden = false;
                }
                if (G_HideInterfaces && !G_InterfacesAreHidden && IsPlaying() ) {
                    if (HideLiveRanking && G_UILayer_LiveRanking !is null) {
                        G_UILayer_LiveRanking.IsVisible = false;
                    }
                    if (HideTeamsScores && G_UILayer_TeamsScores !is null) {
                        G_UILayer_TeamsScores.IsVisible = false;
                    }
                    G_InterfacesAreHidden = true;
                } else if (G_InterfacesAreHidden && (!G_HideInterfaces || !IsPlaying())) {
                    if (G_UILayer_LiveRanking !is null) {
                        G_UILayer_LiveRanking.IsVisible = true;
                    }
                    if (G_UILayer_TeamsScores !is null) {
                        G_UILayer_TeamsScores.IsVisible = true;
                    }
                    G_InterfacesAreHidden = false;
                }
            }
        } else {
            G_Last_ServerLogin = "";
            G_HideInterfaces = false;
            G_InterfacesAreHidden = false;
            @G_UILayer_LiveRanking = null;
            @G_UILayer_TeamsScores = null;
        }

    }
}

