enum ESortColumn {
	ItemName,
	Type,
	Source,
	Size,
	Count
}

bool menu_visibility = false;
uint camerafocusindex = 0;
bool include_default_objects = false;
bool refreshobject;

string searchStr = "";

bool sort_reverse;
bool forcesort;
string infotext;

array<Objects@> objects = {};
array<Objects@> sortableobjects = {};
array<string> objectsindex = {};


ESortColumn sortCol = ESortColumn(-1);

void Main() {
	while (true) {
		if (refreshobject) {
			objects.Resize(0);
			objectsindex.Resize(0);
			sortableobjects.Resize(0);
			RefreshBlocks();
			RefreshItems();
			sortableobjects = objects;
			sortableobjects.Sort(function(a,b) { return a.size > b.size; }); // Sort by size by default, it will be used as second sort criteria
			refreshobject = false;
		}
		yield();
	}
}

void RenderInterface() {
	if (!menu_visibility) return;
	if (!RenderLib::InMapEditor()) return;

	CGameCtnEditorFree@ editor = cast<CGameCtnEditorFree>(GetApp().Editor);
	CGameCtnChallenge@ map = cast<CGameCtnChallenge>(GetApp().RootMap);

	infotext = "";

	UI::SetNextWindowPos(200, 200, UI::Cond::Once);
	UI::PushStyleVar(UI::StyleVar::WindowMinSize, vec2(600, 400));
	if (UI::Begin("\\$cf9" + Icons::Table + "\\$z Blocks & Items Counter###Blocks & Items Counter", menu_visibility, UI::WindowFlags::NoCollapse)) {
		if (refreshobject) {
			RenderLib::LoadingButton();
		} else {
			if (UI::Button(Icons::Refresh + " Refresh")) {
				refreshobject = true;
				forcesort = true;
			}
		}
		UI::SameLine();
		UI::PushStyleColor(UI::Col::FrameBg, vec4(0.169,0.388,0.651,0.1));
		include_default_objects = UI::Checkbox("Include In-Game Blocks and Items", include_default_objects);

		UI::SameLine();
		UI::Dummy(vec2(UI::GetWindowSize().x - 600, 10));
		UI::SameLine();
		UI::SetNextItemWidth(200);
		if (refreshobject) {
			searchStr = "";
			string newSearchStr = UI::InputText("Filter", searchStr, UI::InputTextFlags(UI::InputTextFlags::AutoSelectAll | UI::InputTextFlags::NoUndoRedo | UI::InputTextFlags::ReadOnly));
		} else {
			string newSearchStr = UI::InputText("Filter", searchStr, UI::InputTextFlags(UI::InputTextFlags::AutoSelectAll | UI::InputTextFlags::NoUndoRedo));
			if (newSearchStr != searchStr) {
				searchStr = newSearchStr;
				string searchStrLower = searchStr.ToLower();
				sortableobjects = {};
				for(uint i = 0; i < objects.Length; i++) {
					if(searchStrLower == "" || objects[i].name.ToLower().Contains(searchStrLower)) {
						sortableobjects.InsertLast(objects[i]);
					}
				}
			}
		}
		UI::PopStyleColor();

		UI::Separator();
		vec2 winsize = UI::GetWindowSize();
		winsize.x = winsize.x-10;
		winsize.y = winsize.y-105;
		if (UI::BeginTable("ItemsTable", 5, UI::TableFlags(UI::TableFlags::Resizable | UI::TableFlags::Sortable | UI::TableFlags::NoSavedSettings | UI::TableFlags::BordersInnerV | UI::TableFlags::SizingStretchProp | UI::TableFlags::ScrollY), winsize)) {				UI::TableSetupScrollFreeze(0, 1);
			UI::TableSetupColumn("Item Name", UI::TableColumnFlags::None, 55.f, ESortColumn::ItemName);	
			UI::TableSetupColumn("Type", UI::TableColumnFlags::None, 7.f, ESortColumn::Type);
			UI::TableSetupColumn("Source", UI::TableColumnFlags::None, 13.f, ESortColumn::Source);
			UI::TableSetupColumn("Size", UI::TableColumnFlags::None, 15.f, ESortColumn::Size);
			UI::TableSetupColumn("Count", UI::TableColumnFlags::DefaultSort, 10.f, ESortColumn::Count);
			UI::TableHeadersRow();

			UI::TableSortSpecs@ sortSpecs = UI::TableGetSortSpecs();
			if(sortSpecs !is null && sortSpecs.Specs.Length == 1 && sortableobjects.Length > 1) {
				if(sortSpecs.Dirty || (forcesort && !refreshobject)) {
					if(sortCol != ESortColumn(sortSpecs.Specs[0].ColumnUserID) || (forcesort && !refreshobject)) {
						sortCol = ESortColumn(sortSpecs.Specs[0].ColumnUserID);
						switch(sortCol) {
							case ESortColumn::ItemName:
								sortableobjects.Sort(function(a,b) { return a.name < b.name; });
								break;
							case ESortColumn::Type:
								sortableobjects.Sort(function(a,b) { return a.type < b.type; });
								break;
							case ESortColumn::Source:
								sortableobjects.Sort(function(a,b) { return a.source < b.source; });
								break;
							case ESortColumn::Size:
								sortableobjects.Sort(function(a,b) { return a.size < b.size; });
								break;
							case ESortColumn::Count:
								sortableobjects.Sort(function(a,b) { return a.count < b.count; });
								break;
						}
						if (forcesort && sort_reverse) {
							sortableobjects.Reverse();
						} else {
							sort_reverse = false;
						}
					} else if (sortCol == ESortColumn(sortSpecs.Specs[0].ColumnUserID)) {
						sortableobjects.Reverse();
						sort_reverse = !sort_reverse;
					}

					sortSpecs.Dirty = false;
					forcesort = false;
				}
			}
			if (sortableobjects.Length > 0 ) {
				for(uint i = 0; i < sortableobjects.Length; i++) {
					RenderLib::GenerateRow(sortableobjects[i]);
				}
			} else if (refreshobject) { // Display the items during the refresh
				for(uint i = 0; i < objects.Length; i++) {
					RenderLib::GenerateRow(objects[i]);
				}
			}
			UI::EndTable();
			UI::Separator();
			UI::Text(Icons::Info + " " + infotext);
		}
	}
	
	UI::End();
	UI::PopStyleVar();
}
	
void RenderMenu() {
	if (!RenderLib::InMapEditor()) return;

	if(UI::MenuItem("\\$cf9" + Icons::Table + "\\$z Blocks & Items Counter", "", menu_visibility)) {
		menu_visibility = !menu_visibility;
		refreshobject = true;
		forcesort = true;
	}
}
