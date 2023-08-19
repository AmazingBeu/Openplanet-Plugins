[Setting name="Countdown Position"]
vec2 Setting_CountdownOffset = vec2(155. , 4.);

const string C_Class_UIModules = 'component-modelibs-uimodules-module';
const string C_Id_Countdown = 'Race_Countdown';

string G_Last_ServerLogin = "";
uint G_Last_UILayers_Length = 0;
CGameManialinkControl@ G_Control;
bool Update;

// Search and return the CMlFrame of the Race_Countdown UIModule
CGameManialinkControl@ GetControl(CGameManiaAppPlayground@ _ManiaApp) {
	for (uint Index = 0; Index < _ManiaApp.UILayers.Length; ++Index) {
		CGameUILayer@ Layer = _ManiaApp.UILayers[Index];
		CGameManialinkPage@ Page = Layer.LocalPage;

		// Check if we have the main UI module
		Page.GetClassChildren(C_Class_UIModules, Page.MainFrame, true);

		if (Page.GetClassChildren_Result.Length > 0) {
			if (Page.GetClassChildren_Result[0].ControlId == C_Id_Countdown) {
				return Page.GetClassChildren_Result[0];
			}
		}
	}
	return null;
}

void OnSettingsChanged() {
	Update = true;
}

void Main() {
    while(true) {
        CTrackMania@ App = cast<CTrackMania>(GetApp());
        CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork>(App.Network);
        CTrackManiaNetworkServerInfo@ ServerInfo = cast<CTrackManiaNetworkServerInfo>(Network.ServerInfo);
		CGameManiaAppPlayground@ ManiaApp = Network.ClientManiaAppPlayground;

        if (Network !is null && ServerInfo !is null && ManiaApp !is null) {
            if (G_Last_ServerLogin != ServerInfo.ServerLogin || G_Last_UILayers_Length != ManiaApp.UILayers.Length) {
                G_Last_ServerLogin = ServerInfo.ServerLogin;
				G_Last_UILayers_Length = ManiaApp.UILayers.Length;
				@G_Control = GetControl(ManiaApp);
				Update = true;
            }

			if (G_Control !is null && Update) {
				Update = false;
				G_Control.RelativePosition_V3 = Setting_CountdownOffset;
			}
        } else {
			G_Last_ServerLogin = "";
			G_Last_UILayers_Length = 0;
			@G_Control = null;
			Update = true;
        }

        sleep(1000);
    }
}
