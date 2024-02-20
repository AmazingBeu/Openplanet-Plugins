// Based on the Moski plugin which is also based on the Miss plugin :)

const string C_InvalidValueError = "Invalid value. You can set a human readable value like \\$<\\$aaa1:23.456\\$>\nor a value in milliseconds like \\$<\\$aaa83456\\$>";

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

	UI::SetNextItemWidth(200.0);
	if (UI::Begin("\\$cf9" + Icons::Flag + "\\$z Map Validator###MapValidator", G_MenuVisibility, UI::WindowFlags::NoResize | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse)){
		UI::SetNextItemWidth(100.0);
		G_AuthorTimeText = UI::InputText("###AuthorTimeText", G_AuthorTimeText);
		UI::SameLine();

		const bool IsMilliseconds = IsMillisecondsFormat(G_AuthorTimeText);
		const bool IsButtonDisabled = (!IsMilliseconds && !IsValidAuthorTime(G_AuthorTimeText));

		// Creating group to be able to display the tooltip even when the button is disabled
		UI::BeginGroup();
		UI::BeginDisabled(IsButtonDisabled);
		if (UI::Button("Validate")) {
			int AuthorTime = 0;
			if (IsMilliseconds) AuthorTime = Text::ParseUInt(G_AuthorTimeText);
			else AuthorTime = Time::ParseRelativeTime(G_AuthorTimeText);

			setAuthorTime(map, AuthorTime);
			setValidationStatus(editor);
			G_MenuVisibility = false;
		}
		UI::EndDisabled();
		UI::EndGroup();

		// Time tooltip
		if (UI::IsItemHovered()) {
			UI::BeginTooltip();
			if (IsButtonDisabled) {
				UI::Text(C_InvalidValueError);
			} else if (IsMilliseconds) {
				UI::Text(Time::Format(Text::ParseUInt(G_AuthorTimeText)));
			} else {
				UI::Text("" + Time::ParseRelativeTime(G_AuthorTimeText) + " ms");
			}
			UI::EndTooltip();
		}

		// Warning tooltip depending the game
		const string warning = GetWarning();
		if (warning != "") {
			UI::SameLine();
			UI::Text("\\$fa2" + Icons::Info);
			if (UI::IsItemHovered()) {
				UI::BeginTooltip();
				UI::Text(warning);
				UI::EndTooltip();
			}
		}
	}
	UI::End();
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

bool IsMillisecondsFormat(string _AuthorTimeText) {
	return Regex::IsMatch(_AuthorTimeText, '\\d+');
}

bool IsValidAuthorTime(string _AuthorTimeText) {
	if (!Regex::IsMatch(_AuthorTimeText, '[\\d\\.:]+')) {
		return false;
	}
	if (!Regex::IsMatch(_AuthorTimeText, '^(((((\\d+:)?[0-5])?\\d:)?[0-5])?\\d)\\.\\d{3}$')) {
		return false;
	}

	return true;
}