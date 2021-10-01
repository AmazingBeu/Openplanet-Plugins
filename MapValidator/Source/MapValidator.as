// Based on the Moski plugin which is also based on the Miss plugin :)

bool menu_visibility = false;
int author_time;

void Main() {}

void validate(int author_time) {
	CGameCtnEditorFree@ editor = cast<CGameCtnEditorFree>(GetApp().Editor);
#if TMNEXT || MP4
	CGameCtnChallenge@ map = cast<CGameCtnChallenge>(GetApp().RootMap);
	CGameEditorPluginMapMapType@ pluginmaptype = cast<CGameEditorPluginMapMapType>(editor.PluginMapType);
#elif TURBO
	CGameCtnChallenge@ map = cast<CGameCtnChallenge>(GetApp().Challenge);
	CGameCtnEditorPluginMapType@ pluginmaptype = cast<CGameCtnEditorPluginMapType>(editor.EditorMapType);
#endif

	if (editor is null) {
		return;
	}

	if (pluginmaptype !is null) {
#if TMNEXT || MP4
		pluginmaptype.ValidationStatus = CGameEditorPluginMapMapType::EValidationStatus::Validated;
#elif TURBO
		pluginmaptype.ValidationStatus = CGameCtnEditorPluginMapType::EValidationStatus::Validated;
#endif
		
	}
	if (map !is null) {
		map.TMObjective_AuthorTime = author_time;
#if MP4 || TURBO
		map.IdName = "";
#endif
	}
}

void Render() {
	if (!menu_visibility) {
		return;
	}

	CGameCtnEditorFree@ editor = cast<CGameCtnEditorFree>(GetApp().Editor);
#if TMNEXT || MP4
	CGameCtnChallenge@ map = cast<CGameCtnChallenge>(GetApp().RootMap);
	CGameEditorPluginMapMapType@ pluginmaptype = cast<CGameEditorPluginMapMapType>(editor.PluginMapType);
#elif TURBO
	CGameCtnChallenge@ map = cast<CGameCtnChallenge>(GetApp().Challenge);
	CGameCtnEditorPluginMapType@ pluginmaptype = cast<CGameCtnEditorPluginMapType>(editor.EditorMapType);
#endif

	UI::Begin("\\$cf9" + Icons::Flag + "\\$z Map Validator###MapValidator", menu_visibility, UI::WindowFlags::NoResize | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse);
	if (map !is null && editor !is null) {
		author_time = UI::InputInt("Author time in ms", author_time ,1);

		if (author_time < 0) author_time = 0;

		if (UI::Button("Validate")) {
			validate(author_time);
			menu_visibility = false;
		}
		
		// Convert time in ms to humain readable time
		string display_time = Text::Format('%02d',(author_time / 1000 / 60) % 60) + ":" + Text::Format('%02d',(author_time / 1000) % 60) + "." + Text::Format('%03d',author_time % 1000);
		if (Math::Floor(author_time / 1000 / 60 / 60) > 0) {
			display_time = Text::Format('%d',author_time / 1000 / 60 / 60) + ":" + display_time;
		}
		UI::SameLine();
		UI::Text("with " + display_time + " of author time");

#if TURBO
		UI::Text("Note: your map must have a start and a finish\n(or a multilap + 1CP) to be validated with the plugin");
#endif
	} else {
		UI::Text("Open this plugin in the map editor");
	}

	UI::End();
	
}
	
void RenderMenu() {
	if(UI::MenuItem("\\$cf9" + Icons::Flag + "\\$z Map Validator", "", menu_visibility)) {
		menu_visibility = !menu_visibility;
	}
}
