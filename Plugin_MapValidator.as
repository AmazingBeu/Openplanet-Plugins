#name "Map Validator"
#author "Beu"
#category "Map Editor"

// Based on the Moski plugin which is also based on the Miss plugin :)

#include "Icons.as"

bool menu_visibility = false;
int author_time;

void Main() {}

void validate(int author_time) {
	auto app = GetApp();
	auto editor = cast<CGameCtnEditorFree>(app.Editor);
	auto map = app.RootMap;
	if (editor is null) {
		return;
	}

	if (editor.PluginMapType !is null) {
		editor.PluginMapType.ValidationStatus = EValidationStatus::Validated;
	}
	if (map !is null) {
		map.TMObjective_AuthorTime = author_time;
		map.TMObjective_BronzeTime = author_time * 4;
		map.TMObjective_SilverTime = author_time * 3;
		map.TMObjective_GoldTime = author_time * 2;
	}
}

void Render() {
	if (!menu_visibility) {
		return;
	}

	auto app = cast<CGameManiaPlanet>(GetApp());

	UI::Begin("\\$cf9" + Icons::Flag + "\\$z Map Validator###MapValidator", menu_visibility, UI::WindowFlags::NoResize | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse);
	if (app.RootMap !is null) {
		author_time = UI::InputInt("Author time in ms", author_time ,1);
		if (UI::Button("Validate")) {
			validate(author_time);
			menu_visibility = false;
		}
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
