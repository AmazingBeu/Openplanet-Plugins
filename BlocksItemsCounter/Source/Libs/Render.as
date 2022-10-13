namespace RenderLib
{
	bool InMapEditor() {
		CGameCtnEditorFree@ editor = cast<CGameCtnEditorFree>(GetApp().Editor);
		CGameCtnChallenge@ map = cast<CGameCtnChallenge>(GetApp().RootMap);

		if (map !is null && editor !is null) {
			return true;
		}
		return false;
	}

	void LoadingButton() {
		if (Time::get_Now() % 3000 > 2000) {
				UI::Button("Loading...");
		} else if (Time::get_Now() % 3000 > 1000) {
				UI::Button("Loading.. ");
		} else {
				UI::Button("Loading.  ");
		}
		if (UI::IsItemHovered()) infotext = "Parsing all blocks and items to generate the table. Please wait...";
	}

	void GenerateRow(Objects@ object) {
		UI::TableNextRow();
		UI::TableNextColumn();
		if (UI::Button(Icons::Search + "###" + object.name)) {
			FocusCam(object.name);
		}
		if (UI::IsItemHovered() && object.type == "Block" && cast<CGameEditorPluginMapMapType>(cast<CGameCtnEditorFree>(GetApp().Editor).PluginMapType) is null) infotext = "Editor plugins are disabled, the coordinates of the blocks are estimated and can be imprecise";
		UI::SameLine();
		switch(object.trigger){
			case CGameCtnBlockInfo::EWayPointType::Start:
				UI::Text("\\$9f9" + object.name);
				if (UI::IsItemHovered()) infotext = "It's a start block/item";
				break;
			case CGameCtnBlockInfo::EWayPointType::Finish:
				UI::Text("\\$f66" + object.name);
				if (UI::IsItemHovered()) infotext = "It's a finish block/item";
				break;
			case CGameCtnBlockInfo::EWayPointType::Checkpoint:
				UI::Text("\\$99f" + object.name);
				if (UI::IsItemHovered()) infotext = "It's a checkpoint block/item";
				break;
			case CGameCtnBlockInfo::EWayPointType::StartFinish:
				UI::Text("\\$ff6" + object.name);
				if (UI::IsItemHovered()) infotext = "It's a multilap block/item";
				break;
			default:
				UI::Text(object.name);
				break;
		}

		UI::TableNextColumn();
		UI::Text(object.type);
		UI::TableNextColumn();
		UI::Text(object.source);
		UI::TableNextColumn();
		if (object.size == 0 && object.source != "In-Game" && object.source != "In TP") {
			UI::Text("\\$555" + Text::Format("%lld",object.size));
			if (UI::IsItemHovered()) infotext = "Impossible to get the size of this block/item";
		} else {
			if (object.icon) {
				UI::Text("\\$fc0" + Text::Format("%lld",object.size));
				if (UI::IsItemHovered()) infotext = "All items with size in orange contains the icon. You must re-open the map to have the real size.";
			} else {
				UI::Text(Text::Format("%lld",object.size));
			}
		}

		UI::TableNextColumn();
		UI::Text(Text::Format("%lld",object.count));
	}
}
