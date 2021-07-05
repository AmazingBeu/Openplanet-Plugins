bool menu_visibility = false;
string quickURL;

void Main() {}

void Render() {
	if (!menu_visibility) {
		return;
	}
	UI::Begin("\\$cf9" + Icons::ExternalLinkAlt + "\\$z Quick Link Opener###Quick Link Opener", menu_visibility,  UI::WindowFlags::NoResize | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse);
	quickURL = UI::InputText("", quickURL);
	UI::SameLine();
	if (UI::Button(Icons::ExternalLinkAlt + " Go !###QuickURL")) {
		string parsedURL = Regex::Replace(quickURL,'uplay:\\/\\/launch\\/5595\\/0\\/','maniaplanet://');
		CTrackMania@ app = cast<CTrackMania>(GetApp());
		app.ManiaPlanetScriptAPI.OpenLink(parsedURL, CGameManiaPlanetScriptAPI::ELinkType::ManialinkBrowser);
		menu_visibility = false;
	}
	UI::End();
}

void RenderMenu() {
	if(UI::MenuItem("\\$cf9" + Icons::ExternalLinkAlt + "\\$z Quick Link Opener", "", menu_visibility)) {
		menu_visibility = !menu_visibility;
	}
}
