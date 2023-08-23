[Setting name="Countdown Position"]
vec2 Setting_CountdownOffset = vec2(155. , 4.);

const string C_Class_UIModules = 'component-modelibs-uimodules-module';
const string C_Id_Countdown = 'Race_Countdown';

const string C_MLID_UIModuleUpdate = 'MLHook_CustomizableModule';
const string C_ML_UIModuleUpdate = """
main() {
	declare netread Integer Net_LibUI3_CustomizableModule_PropertiesUpdate for Teams[0];
	declare Integer Last_PropertiesUpdate;
	while (True) {
		yield;

		if (Last_PropertiesUpdate != Net_LibUI3_CustomizableModule_PropertiesUpdate) {
			Last_PropertiesUpdate = Net_LibUI3_CustomizableModule_PropertiesUpdate;
			SendCustomEvent("MLHook_CustomizableModule_Update", []);
		}
	}
}
""";

class HookCustomizableModuleEvents: MLHook::HookMLEventsByType {
	HookCustomizableModuleEvents() {
		super(C_MLID_UIModuleUpdate);
	}

    // override this method to avoid reload crash?
    void OnEvent(MLHook::PendingEvent@ Event) override {
		trace("CustomizableModule updated");
        G_Update = true;
    }
}

HookCustomizableModuleEvents@ HookEvents = null;
string G_Last_ServerLogin = "";
uint G_Last_UILayers_Length = 0;
CGameManialinkControl@ G_Control;
bool G_Update;

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
	trace("Settings updated");
	G_Update = true;
}

void Main() {
	@HookEvents = HookCustomizableModuleEvents();
    MLHook::RegisterMLHook(HookEvents, C_MLID_UIModuleUpdate + "_Update", true);
    MLHook::InjectManialinkToPlayground(C_MLID_UIModuleUpdate, C_ML_UIModuleUpdate, true);

    while(true) {
        CTrackMania@ App = cast<CTrackMania>(GetApp());
        CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork>(App.Network);
        CTrackManiaNetworkServerInfo@ ServerInfo = cast<CTrackManiaNetworkServerInfo>(Network.ServerInfo);
		CGameManiaAppPlayground@ ManiaApp = Network.ClientManiaAppPlayground;

        if (Network !is null && ServerInfo !is null && ManiaApp !is null) {
            if (G_Last_ServerLogin != ServerInfo.ServerLogin || G_Last_UILayers_Length != ManiaApp.UILayers.Length) {
				trace("Server or UILayers updated");
                G_Last_ServerLogin = ServerInfo.ServerLogin;
				G_Last_UILayers_Length = ManiaApp.UILayers.Length;
				@G_Control = GetControl(ManiaApp);
				G_Update = true;
            }

			if (G_Control !is null && G_Update) {
				G_Update = false;
				G_Control.RelativePosition_V3 = Setting_CountdownOffset;
			}
        } else {
			G_Last_ServerLogin = "";
			G_Last_UILayers_Length = 0;
			@G_Control = null;
			G_Update = true;
        }

        sleep(1000);
    }
}

void OnDestroyed() { _Unload(); }
void OnDisabled() { _Unload(); }
void _Unload() {
    trace('_Unload, unloading all hooks and removing all injected ML');
    MLHook::UnregisterMLHooksAndRemoveInjectedML();
}