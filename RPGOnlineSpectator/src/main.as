bool displayUI = true;

void RenderMenu() {
    auto App = cast<CTrackMania>(GetApp());
    auto Network = cast<CTrackManiaNetwork>(App.Network);
    auto ServerInfo = cast<CTrackManiaNetworkServerInfo>(Network.ServerInfo);

    if (Network !is null && ServerInfo !is null && ServerInfo.ServerLogin != "") {
        if(UI::MenuItem("\\$77d" + Icons::VideoCamera + " \\$fffRPG Online Spectator", "", displayUI)) {
            displayUI = !displayUI;
        }
    } else {
        displayUI = false;
    }
}

void RenderInterface() {
    auto App = cast<CTrackMania>(GetApp());
    auto Network = cast<CTrackManiaNetwork>(App.Network);
    auto ServerInfo = cast<CTrackManiaNetworkServerInfo>(Network.ServerInfo);
    CGamePlayground@ Playground = GetApp().CurrentPlayground;

    if (Network !is null && ServerInfo !is null && ServerInfo.ServerLogin != "") {
        if (Playground is null) return;
        if (displayUI) {
            auto ManiaApp = Network.ClientManiaAppPlayground;
            UI::PushStyleVar(UI::StyleVar::WindowMinSize, vec2(200, 250));
            if (UI::Begin("\\$fc3" + Icons::VideoCamera + "\\$z RPG Online Spectator", displayUI)) {
                UI::TextWrapped("Only use this plugin to spectate other players to not cancel your run");

                if (ManiaApp.ClientUI.ForceSpectator) {
                    if (UI::Button("Continue your run")) {
                        ManiaApp.ClientUI.ForceSpectator = false;
                    }
                }

                UI::Separator();

                if (UI::BeginChild("playerlist")) {

                    for (uint i = 0; i < Playground.Players.Length; i++) {
                        CSmPlayer@ Player = cast<CSmPlayer@>(Playground.Players[i]);
                        CSmScriptPlayer@ ScriptPlayer = cast<CSmScriptPlayer@>(Player.ScriptAPI);

                        if (Playground.Interface.ManialinkScriptHandler.LocalUser.Login == Player.User.Login) continue;

                        bool isSpectator = Player.User.SpectatorMode == CGameNetPlayerInfo::ESpectatorMode::Watcher 
                            || Player.User.SpectatorMode == CGameNetPlayerInfo::ESpectatorMode::LocalWatcher
                            || Player.SpawnIndex < 0;

                        if (isSpectator) continue;

                        if (UI::MenuItem(Player.User.Name)) {
                            ManiaApp.ClientUI.ForceSpectator = true;

                            CGamePlaygroundClientScriptAPI@ Api = GetApp().CurrentPlayground.Interface.ManialinkScriptHandler.Playground;
                            Api.SetSpectateTarget(Player.User.Login);
                        }
                    }

                    UI::EndChild();
                }

                UI::End();
            }
            UI::PopStyleVar();
       }
    } else {
        displayUI = false;
    }
}