class Objects { //Items or Blocks
	string name;
	string type;
	int count;
	vec3 position;
	vec3 rotation;
	Objects(string name, string type, vec3 pos, vec3 rot ) {
		this.name = name;
		this.type = type;
		this.count = 2; // Object if added only if duplicate
		this.position = pos;
		this.rotation = rot;
	}
}

enum ESortColumn {
	ItemName,
	Count
}

const float pi =  3.14159265359;

bool include_default_blocks;
bool menu_visibility = false;
bool refreshobject;

bool sort_reverse;
bool forcesort;
string infotext;

array<Objects@> objects = {};
array<Objects@> sortableobjects = {};
array<string> objectsindex = {};

int totalobjects;
int computedobjects;

ESortColumn sortCol = ESortColumn(-1);

void Main() {
	while (true) {
		if (refreshobject) {
			objects.Resize(0);
			objectsindex.Resize(0);
			sortableobjects.Resize(0);
			RefreshBlocksAndItems();
			sortableobjects = objects;
			refreshobject = false;
		}
		yield();
	}
}

// Force to split the refresh functions to bypass the script execution delay on heavy maps
void RefreshBlocksAndItems() {
	auto map = GetApp().RootMap;
	dictionary singleobjectdico = {};

	if (map !is null) {
		totalobjects = map.Blocks.Length +  map.AnchoredObjects.Length;
		computedobjects = 0;

		// Blocks
		auto blocks = map.Blocks;

		// Editor plugin API for GetVec3FromCoord function
		auto pluginmaptype = cast<CGameEditorPluginMapMapType>(cast<CGameCtnEditorFree>(GetApp().Editor).PluginMapType);

		for(uint i = 0; i < blocks.Length; i++) {
			if (i % 1000 == 0) yield(); // to avoid timeout
			computedobjects++;
			
			string blockname;
			blockname = blocks[i].BlockModel.IdName;
			if (blockname.ToLower().SubStr(blockname.Length - 22, 22) == ".block.gbx_customblock") blockname = blockname.SubStr(0, blockname.Length - 12);

			vec3 pos;
			vec3 rot;
			if (blocks[i].CoordX != 4294967295 && blocks[i].CoordZ != 4294967295) { // Not placed in free mapping
				if (!include_default_blocks) continue;
				if (pluginmaptype !is null) { // Editor plugin is available
					pos = pluginmaptype.GetVec3FromCoord(blocks[i].Coord);
				} else {
					pos.x = blocks[i].CoordX * 32;
					pos.y = (blocks[i].CoordY - 8) * 8;
					pos.z = blocks[i].CoordZ * 32;
				}
				switch(blocks[i].BlockDir) {
					case CGameCtnBlock::ECardinalDirections::East:
						rot.x = 90;
						break;
					case CGameCtnBlock::ECardinalDirections::South:
						rot.x = 180;
						break;
					case CGameCtnBlock::ECardinalDirections::West:
						rot.x = 270;
						break;
				}

			} else {
				uint16 FreeBlockPosOffset = Reflection::GetType("CGameCtnBlock").GetMember("Dir").Offset + 0x8;
				uint16 FreeBlockRotOffset = FreeBlockPosOffset + 0xC;    
				
				pos = Dev::GetOffsetVec3(blocks[i], FreeBlockPosOffset);
				rot = Dev::GetOffsetVec3(blocks[i], FreeBlockRotOffset) / pi * 180;
			}

			string uniqueid = pos.x + ";" + pos.y + ";" + pos.z + ";;"  + rot.x + ";" + rot.y + ";" + rot.z + ";;"+ blockname;

			if (singleobjectdico.Exists(uniqueid)) {
				int index = objectsindex.Find(uniqueid);
				if (index >= 0) {
					objects[index].count++;
				} else {
					objects.InsertLast(Objects(blockname, "Block", pos, rot));
					objectsindex.InsertLast(uniqueid);
				}
			} else {
				singleobjectdico.Set(uniqueid, 0);
			}
		}
		singleobjectdico.DeleteAll();

		auto items = map.AnchoredObjects;

		for(uint i = 0; i < items.Length; i++) {
			if (i % 1000 == 0) yield(); // to avoid timeout
			computedobjects++;

			string itemname = items[i].ItemModel.IdName;

			vec3 pos = items[i].AbsolutePositionInMap;
			vec3 rot;
			rot.x = items[i].Yaw;
			rot.y = items[i].Pitch;
			rot.z = items[i].Roll;

			string uniqueid = pos.x + ";" + pos.y + ";" + pos.z + ";;"  + rot.x + ";" + rot.y + ";" + rot.z + ";;"+ itemname;

			if (singleobjectdico.Exists(uniqueid)) {
				int index = objectsindex.Find(uniqueid);
				if (index >= 0) {
					objects[index].count++;
				} else {
					objects.InsertLast(Objects(itemname, "Item", pos, rot));
					objectsindex.InsertLast(uniqueid);
				}
			} else {
				singleobjectdico.Set(uniqueid, 0);
			}
		}
	}
}

bool FocusCam(vec3 position) {
	auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
	auto camera = editor.OrbitalCameraControl;
	auto map = GetApp().RootMap;


	if (camera !is null) {
		camera.m_TargetedPosition = position;
		// Workaround to update camera TargetedPosition
		auto m_ParamScrollZoomPowe = camera.m_ParamScrollZoomPower;
		camera.m_ParamScrollZoomPower = 0;
        editor.ButtonZoomInOnClick();
        camera.m_ParamScrollZoomPower = m_ParamScrollZoomPowe;

		return true;
	}
	return false;
}

void GenerateRow(Objects@ object) {
	if (object.count <= 1) return;
	UI::TableNextRow();
	UI::TableNextColumn();
	if (UI::Button(Icons::Search + "###Search;" + object.position.x + ";" + object.position.y + ";" + object.position.z)) {
		FocusCam(object.position);
	}
	if (UI::IsItemHovered() && cast<CGameEditorPluginMapMapType>(cast<CGameCtnEditorFree>(GetApp().Editor).PluginMapType) is null) infotext = "Editor plugins are disabled, the coordinates of the blocks are estimated and can be imprecise";
	UI::SameLine();
	UI::Text(object.name);
	UI::TableNextColumn();
	UI::Text(object.type);
	UI::TableNextColumn();
	UI::Text("<" + object.position.x + ", " + object.position.y + ", " + object.position.z +">");
	UI::TableNextColumn();
	UI::Text("<" + object.rotation.x + ", " + object.rotation.y + ", " + object.rotation.z +">");
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
	UI::Begin("\\$cf9" + Icons::Table + "\\$z DuplicateFinder###DuplicateFinder", menu_visibility);
	if (editor !is null) {
		if (refreshobject) {
			if (Time::get_Now() % 3000 > 2000) {
				UI::Button("Loading...");
			} else if (Time::get_Now() % 3000 > 1000) {
				UI::Button("Loading.. ");
			} else {
				UI::Button("Loading.  ");
			}
			if (UI::IsItemHovered()) infotext = "Parsing all blocks and items to generate the table. Please wait... (" + computedobjects + "/" + totalobjects + ")";
		} else {
			if (UI::Button(Icons::SyncAlt + " Refresh")) {
				refreshobject = true;
				forcesort = true;
			}
		}
		UI::SameLine();
		include_default_blocks = UI::Checkbox("Include Blocks not placed in Free Mapping", include_default_blocks);
		UI::Separator();
		vec2 winsize = UI::GetWindowSize();
		winsize.x = winsize.x - 10;
		winsize.y = winsize.y - 105;
		if (UI::BeginTable("DuplicateBlocksTable", 5, UI::TableFlags(UI::TableFlags::Resizable | UI::TableFlags::Sortable | UI::TableFlags::NoSavedSettings | UI::TableFlags::BordersInnerV | UI::TableFlags::SizingStretchProp | UI::TableFlags::ScrollY),winsize )) {
			UI::TableSetupScrollFreeze(0, 1);
			UI::TableSetupColumn("Block Name", UI::TableColumnFlags::None, 40.f, ESortColumn::ItemName);
			UI::TableSetupColumn("Type", UI::TableColumnFlags::NoSort, 10.f);
			UI::TableSetupColumn("Position", UI::TableColumnFlags::NoSort, 20.f);
			UI::TableSetupColumn("Rotation", UI::TableColumnFlags::NoSort, 20.f);
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

	if(UI::MenuItem("\\$cf9" + Icons::Table + "\\$z DuplicateFinder", "", menu_visibility)) {
		menu_visibility = !menu_visibility;
		refreshobject = true;
	}
}

