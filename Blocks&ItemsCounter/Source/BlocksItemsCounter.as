class Objects { //Items or Blocks
	string name;
	int trigger; // CGameItemModel::EnumWaypointType or CGameCtnBlockInfo::EWayPointType
	string type;
	string source;
	int size;
	int count;
	bool icon;
	array<vec3> positions;

	Objects(string name, int trigger, bool icon, string type, string source, int size, vec3 pos ) {
		this.name = name;
		this.trigger = trigger;
		this.count = 1;
		this.type = type;
		this.icon = icon;
		this.source = source;
		this.size = size;
		this.positions = {pos};
	}
}

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
			refreshobject = false;
		}
		yield();
	}
}

// Force to split the refresh functions to bypass the script execution delay on heavy maps
void RefreshBlocks() {
	auto map = GetApp().RootMap;

	if (map !is null) {
		// Blocks
		auto blocks = map.Blocks;

		// Editor plugin API for GetVec3FromCoord function
		auto pluginmaptype = cast<CGameEditorPluginMapMapType>(cast<CGameCtnEditorFree>(GetApp().Editor).PluginMapType);

		for(uint i = 0; i < blocks.Length; i++) {
			int idifexist = -1;
			string blockname;
			bool isofficial = true;
			blockname = blocks[i].BlockModel.IdName;
			if (blockname.ToLower().SubStr(blockname.Length - 22, 22) == ".block.gbx_customblock") {
				isofficial = false;
				blockname = blockname.SubStr(0, blockname.Length - 12);
			}
			if (include_default_objects || blockname.ToLower().SubStr(blockname.Length - 10, 10) == ".block.gbx") {
				vec3 pos;
				if (blocks[i].CoordX != 4294967295 && blocks[i].CoordZ != 4294967295) { // Not placed in free mapping
					if (pluginmaptype !is null) { // Editor plugin is available
						pos = pluginmaptype.GetVec3FromCoord(blocks[i].Coord);
					} else {
						pos.x = blocks[i].CoordX * 32 + 16;
						pos.y = (blocks[i].CoordY - 8) * 8 + 4;
						pos.z = blocks[i].CoordZ * 32 + 16;
					}
				} else {
					pos = Dev::GetOffsetVec3(blocks[i], 0x6c);
					// center the coordinates in the middle of the block
					pos.x += 16;
					pos.y += 4;
					pos.z += 16;
				}


				int index = objectsindex.Find(blockname);
				
				if (index >= 0) {
					objects[index].count++;
					objects[index].positions.InsertLast(pos);
				} else {
					int trigger = blocks[i].BlockModel.EdWaypointType;
					AddNewObject(blockname, trigger, "Block", pos, 0, isofficial);
					objectsindex.InsertLast(blockname);
				}
			}
			if (i % 100 == 0) yield(); // to avoid timeout
		}
	}
}

// Force to split the refresh functions to bypass the script execution delay on heavy maps
void RefreshItems() {
	auto map = GetApp().RootMap;

	if (map !is null) {
		// Items
		auto items = map.AnchoredObjects;
		for(uint i = 0; i < items.Length; i++) {
			int idifexist = -1;
			string itemname = items[i].ItemModel.IdName;
			int fallbacksize = 0;
			bool isofficial = true;

			if (itemname.ToLower().SubStr(itemname.Length - 9, 9) == ".item.gbx") {
				isofficial = false;
				auto article = cast<CGameCtnArticle>(items[i].ItemModel.ArticlePtr);
				if (article !is null) {
					itemname = string(article.PageName) + string(article.Name) + ".Item.Gbx";
				} else {
					auto fid = cast<CSystemFidFile@>(GetFidFromNod(items[i].ItemModel));
					fallbacksize = fid.ByteSize;
				}
			}

			if (include_default_objects || itemname.ToLower().SubStr(itemname.Length - 9, 9) == ".item.gbx") {
				int index = objectsindex.Find(itemname);
				if (index >= 0) {
					objects[index].count++;
					objects[index].positions.InsertLast(items[i].AbsolutePositionInMap);
				} else {
					int trigger = items[i].ItemModel.WaypointType;
					AddNewObject(itemname, trigger, "Item", items[i].AbsolutePositionInMap, fallbacksize, isofficial);
					objectsindex.InsertLast(itemname);
				}
			}
			if (i % 100 == 0) yield(); // to avoid timeout
		}
	}
}

void AddNewObject(string objectname, int trigger, string type, vec3 pos, int fallbacksize, bool isofficial) {
	bool icon = false;
	int size;
	string source;
	CSystemFidFile@ file;
	CGameCtnCollector@ collector;
	CSystemFidFile@ tempfile;

	if (type == "Item" && Regex::IsMatch(objectname, "^[0-9]*/.*.zip/.*", Regex::Flags::None)) {//  ItemCollections
		source = "Club";
		@file = Fids::GetFake('MemoryTemp\\FavoriteClubItems\\' + objectname);
		@collector = cast<CGameCtnCollector>(cast<CGameItemModel>(file.Nod));
		if (collector is null || (collector.Icon !is null || file.ByteSize == 0)) {
			@tempfile = Fids::GetFake('MemoryTemp\\CurrentMap_EmbeddedFiles\\ContentLoaded\\ClubItems\\' + objectname);
		}
	} else { // Blocks and Items
		source = "Local";
		@file = Fids::GetUser(type + 's\\' + objectname);
		@collector = cast<CGameCtnCollector>(cast<CGameItemModel>(file.Nod));
		if (collector is null || (collector.Icon !is null || file.ByteSize == 0)) {
			@tempfile = Fids::GetFake('MemoryTemp\\CurrentMap_EmbeddedFiles\\ContentLoaded\\' + type + 's\\' + objectname);
		}
	}
	if (tempfile !is null) {
		if (collector !is null && collector.Icon !is null && tempfile.ByteSize == 0) {
			icon = true;
			size = file.ByteSize;
		} else  {
			size = tempfile.ByteSize;
		}
		if (isofficial) {
			source = "In-Game";
		} else if (file.ByteSize == 0 && tempfile.ByteSize == 0 && fallbacksize == 0) {
			source = "Local";
		} else if (file.ByteSize == 0 && tempfile.ByteSize == 0 && fallbacksize > 0 ) {
			source = "Embedded";
			size = fallbacksize;
		} else if (file.ByteSize == 0 && tempfile.ByteSize > 0) {
			source = "Embedded";
		}
	} else {
		size = file.ByteSize;
	}

	objects.InsertLast(Objects(objectname, trigger, icon, type, source, size, pos));
}

bool FocusCam(string objectname) {
	auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
	auto camera = editor.OrbitalCameraControl;
	auto map = GetApp().RootMap;


	if (camera !is null) {
		int index = objectsindex.Find(objectname);

		camerafocusindex++;

		if (camerafocusindex > objects[index].positions.get_Length() - 1 ) {
			camerafocusindex = 0;
		}

		camera.m_TargetedPosition = objects[index].positions[camerafocusindex];
		// Workaround to update camera TargetedPosition
		editor.ButtonZoomInOnClick();
		editor.ButtonZoomOutOnClick();
		return true;
	}
	return false;
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
	if (object.size == 0 && object.source != "In-Game") {
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

void Render() {
	if (!menu_visibility) {
		return;
	}

	CGameCtnEditorFree@ editor = cast<CGameCtnEditorFree>(GetApp().Editor);
	CGameCtnChallenge@ map = cast<CGameCtnChallenge>(GetApp().RootMap);

	if (map is null && editor is null) {
		menu_visibility = false;
		return;
	}

	infotext = "";

	UI::SetNextWindowSize(600, 400);
	UI::SetNextWindowPos(200, 200, UI::Cond::Once);
	UI::Begin("\\$cf9" + Icons::Table + "\\$z Blocks & Items Counter###Blocks & Items Counter", menu_visibility);
	if (editor !is null) {
		if (refreshobject) {
			if (Time::get_Now() % 3000 > 2000) {
				UI::Button("Loading...");
			} else if (Time::get_Now() % 3000 > 1000) {
				UI::Button("Loading.. ");
			} else {
				UI::Button("Loading.  ");
			}
			if (UI::IsItemHovered()) infotext = "Parsing all blocks and items to generate the table. Please wait...";
		} else {
			if (UI::Button(Icons::SyncAlt + " Refresh")) {
				refreshobject = true;
				forcesort = true;
			}
		}
		UI::SameLine();
		include_default_objects = UI::Checkbox("Include In-Game Blocks and Items", include_default_objects);
		UI::Separator();
		vec2 winsize = UI::GetWindowSize();
		winsize.x = winsize.x-10;
		winsize.y = winsize.y-105;
		if (UI::BeginTable("ItemsTable", 5, UI::TableFlags(UI::TableFlags::Resizable | UI::TableFlags::Sortable | UI::TableFlags::NoSavedSettings | UI::TableFlags::BordersInnerV | UI::TableFlags::SizingStretchProp | UI::TableFlags::ScrollY),winsize )) {
			UI::TableSetupScrollFreeze(0, 1);
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
					GenerateRow(sortableobjects[i]);
				}
			} else {
				for(uint i = 0; i < objects.Length; i++) {
					GenerateRow(objects[i]);
				}
			}
			UI::EndTable();
			UI::Separator();
			UI::Text(Icons::Info + " " + infotext);
		}
	} else {
		UI::Text("Open this plugin in the map editor");
	}
	UI::End();
	
}
	
void RenderMenu() {
	CGameCtnEditorFree@ editor = cast<CGameCtnEditorFree>(GetApp().Editor);
	CGameCtnChallenge@ map = cast<CGameCtnChallenge>(GetApp().RootMap);

	if (map is null && editor is null) {
		return;
	}

	if(UI::MenuItem("\\$cf9" + Icons::Table + "\\$z Blocks & Items Counter", "", menu_visibility)) {
		menu_visibility = !menu_visibility;
		refreshobject = true;
	}
}
