// Based on the Moski plugin which is also based on the Miss plugin :)

bool G_MenuVisibility = false;
string G_AuthorTimeText = "0:00:00.000";

void Main() {}	

void Render() {
	auto editor = getEditor();
	if (editor is null) {
		G_MenuVisibility = false;
		return;
	} 

	auto map = getMap();
	if (map is null) {
		G_MenuVisibility = false;
		return;
	}

	if (!G_MenuVisibility) {
		// Store the last Author Time when hidden
		uint CurrentAuthorTime = getAuthorTime(map);
		if (CurrentAuthorTime < 4294967295) {
			G_AuthorTimeText = Time::Format(CurrentAuthorTime);
		}	
		return;
	}


	if (UI::Begin("\\$cf9" + Icons::Flag + "\\$z Map Validator###MapValidator", G_MenuVisibility, UI::WindowFlags::NoResize | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse)){
		UI::SetNextItemWidth(100.0);
		G_AuthorTimeText = UI::InputText("###AuthorTimeText", G_AuthorTimeText);
		UI::SameLine();

		UI::BeginDisabled(!IsValidAuthorTime(G_AuthorTimeText));
		if (UI::Button("Validate")) {
			setAuthorTime(map, Time::ParseRelativeTime(G_AuthorTimeText));
			setValidationStatus(editor);
			G_MenuVisibility = false;
		}
		UI::EndDisabled();

		string warning = GetWarning();
		if (warning != "") {
			UI::SameLine();
			UI::Text("\\$fa2" + Icons::Info);
			if (UI::IsItemHovered()) {
				UI::BeginTooltip();
				UI::Text(warning);
				UI::EndTooltip();
			}
		}

		UI::End();
	}	
}

void RenderMenu() {
	auto editor = getEditor();
	if (editor is null) return;

	auto map = getMap();
	if (map is null) return;

	if(UI::MenuItem("\\$cf9" + Icons::Flag + "\\$z Map Validator", "", G_MenuVisibility)) {
		G_MenuVisibility = !G_MenuVisibility;
	}
}

bool IsValidAuthorTime(string _AuthorTimeText) {
	if (!Regex::IsMatch(_AuthorTimeText, '[\\d\\.:]+')) {
		return false;
	}
	if (!Regex::IsMatch(_AuthorTimeText, '^((\\d+):)?(\\d|[0-5]\\d):(\\d|[0-5]\\d)\\.\\d{3}$')) {
		return false;
	}


	return true;
}