// Based on the Moski plugin which is also based on the Miss plugin :)

bool menu_visibility = false;
int author_time;

void Main() {}

void validate(int author_time) {
	// Get editor var
#if UNITED
	CTrackManiaEditor@ editor = cast<CTrackManiaEditor>(cast<CTrackMania>(GetApp()).Editor);
#else
	CGameCtnEditorFree@ editor = cast<CGameCtnEditorFree>(GetApp().Editor);
#endif

	// Get map & pluginmaptype if possible
#if TURBO
	CGameCtnChallenge@ map = cast<CGameCtnChallenge>(GetApp().Challenge);
	CGameCtnEditorPluginMapType@ pluginmaptype = cast<CGameCtnEditorPluginMapType>(editor.EditorMapType);
#elif UNITED
	CGameCtnChallenge@ map = cast<CGameCtnChallenge>(GetApp().Challenge);
	auto pluginmaptype == null;
#else
	CGameCtnChallenge@ map = cast<CGameCtnChallenge>(GetApp().RootMap);
	CGameEditorPluginMapMapType@ pluginmaptype = cast<CGameEditorPluginMapMapType>(editor.PluginMapType);
#endif

	if (editor is null) {
		return;
	}

	if (pluginmaptype !is null) {
#if TURBO
			pluginmaptype.ValidationStatus = CGameCtnEditorPluginMapType::EValidationStatus::Validated;
#else
			pluginmaptype.ValidationStatus = CGameEditorPluginMapMapType::EValidationStatus::Validated;
#endif
	}


	if (map !is null) {
#if UNITED
			map.ChallengeParameters.AuthorTime = author_time;
			map.ChallengeParameters.AuthorScore = author_time;
			map.ChallengeParameters.GoldTime = Math::Floor((1000 + author_time + author_time * 0.06)/1000)*1000;
			map.ChallengeParameters.SilverTime = Math::Floor((1000 + author_time + author_time * 0.2)/1000)*1000;
			map.ChallengeParameters.BronzeTime = Math::Floor((1000 + author_time + author_time * 0.5)/1000)*1000;
#else
			map.TMObjective_AuthorTime = author_time;
#endif

#if !TMNEXT
			map.IdName = ""; // Remove the map UID, the game will generate it again when saving
#endif
	}
}

void Render() {
	if (!menu_visibility) {
		return;
	}

#if UNITED
		CTrackManiaEditor@ editor = cast<CTrackManiaEditor>(cast<CTrackMania>(GetApp()).Editor);
#else
		CGameCtnEditorFree@ editor = cast<CGameCtnEditorFree>(GetApp().Editor);
#endif

#if TMNEXT || MP4
		CGameCtnChallenge@ map = cast<CGameCtnChallenge>(GetApp().RootMap);
#else
		CGameCtnChallenge@ map = cast<CGameCtnChallenge>(GetApp().Challenge);
#endif

	if (map is null || editor is null) {
		menu_visibility = false;
		return;
	}

	if (UI::Begin("\\$cf9" + Icons::Flag + "\\$z Map Validator###MapValidator", menu_visibility, UI::WindowFlags::NoResize | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse)){
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
#elif UNITED
			UI::Text("Note: for an unknown reason, it happens that the times of\nthe medals are not updated, I invite you to check by yourself");
#endif

		UI::End();
	}	
}
	
void RenderMenu() {
#if UNITED
		CTrackManiaEditor@ editor = cast<CTrackManiaEditor>(cast<CTrackMania>(GetApp()).Editor);
#else
		CGameCtnEditorFree@ editor = cast<CGameCtnEditorFree>(GetApp().Editor);
#endif

#if TMNEXT || MP4
		CGameCtnChallenge@ map = cast<CGameCtnChallenge>(GetApp().RootMap);
#else
		CGameCtnChallenge@ map = cast<CGameCtnChallenge>(GetApp().Challenge);
#endif

	if (map is null || editor is null) {
		return;
	}

	if(UI::MenuItem("\\$cf9" + Icons::Flag + "\\$z Map Validator", "", menu_visibility)) {
		menu_visibility = !menu_visibility;
	}
}
