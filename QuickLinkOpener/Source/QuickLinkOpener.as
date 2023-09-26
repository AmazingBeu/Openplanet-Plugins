[Setting name="Number of links saved in cache"]
uint S_NbOfLinksInCache = 5;

const string C_LinksCache = "LinksCache.txt";

string G_QuickURL = "";
bool G_PressEnter = false;
bool G_WasEditing = false;

array<string> G_LinksCache;

void Main() {
	trace("Loading links cache");
	string filepath = IO::FromStorageFolder(C_LinksCache);
	IO::File file(filepath);

	file.Open(IO::FileMode::Read);
	while(!file.EOF()) {
		G_LinksCache.InsertLast(file.ReadLine());
	}
}

void RenderMenuMain() {
	if (!G_PressEnter && UI::BeginMenu("\\$cf9" + Icons::ExternalLink + "\\$z Quick Link Opener##QuickLinkOpenerMenu")) {
		G_QuickURL = UI::InputText("###quickURL", G_QuickURL, G_PressEnter, UI::InputTextFlags::EnterReturnsTrue + UI::InputTextFlags::CallbackAlways, UI::InputTextCallback(ITCB));

		if (G_LinksCache.Length > 0) {
			UI::Separator();

			for(uint i = 0; i < G_LinksCache.Length; i++ ) {
				if (UI::MenuItem(G_LinksCache[i] + "###" + i)) {
					LoadLink(G_LinksCache[i], false);
				}
			}
		}

		UI::EndMenu();
	} else if (G_PressEnter || G_WasEditing) {
		G_PressEnter = false;
		G_WasEditing = false;
		LoadLink(G_QuickURL, true);
		G_QuickURL = "";
	}
}

void ITCB(UI::InputTextCallbackData@ d) {
	G_WasEditing = true;
}

void LoadLink(string _Url, bool _NewUrl) {
	if (_Url == "") return;

	string parsedURL = "";
	if (_NewUrl) {
		parsedURL = Regex::Replace(_Url,'uplay:\\/\\/launch\\/5595\\/0\\/','maniaplanet://');

		G_LinksCache.InsertAt(0, parsedURL);

		// Clear cache if too long
		if (G_LinksCache.Length > S_NbOfLinksInCache) {
			G_LinksCache.RemoveRange(S_NbOfLinksInCache, G_LinksCache.Length - S_NbOfLinksInCache);
		}

		// Compute text for the cache file
		string content;
		for(uint i = 0; i < G_LinksCache.Length; i++ ) {
			content = content + G_LinksCache[i] + "\n";
		}

		trace("Writing links cache");
		string filepath = IO::FromStorageFolder(C_LinksCache);
		IO::File file(filepath, IO::FileMode::Write);
		file.Write(content);
	} else {
		parsedURL = _Url;
	}

	CTrackMania@ app = cast<CTrackMania>(GetApp());
	app.ManiaPlanetScriptAPI.OpenLink(parsedURL, CGameManiaPlanetScriptAPI::ELinkType::ManialinkBrowser);
}
