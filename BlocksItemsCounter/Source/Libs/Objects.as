class Objects { //Items or Blocks
	string name;
	int trigger; // CGameItemModel::EnumWaypointType or CGameCtnBlockInfo::EWayPointType
	string type;
	string source;
	int size;
	int count;
	bool icon;
	array<vec3> positions;

	Objects(const string &in name, int trigger, bool icon, const string &in type, const string &in source, int size, vec3 pos ) {
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
					uint16 offset = Reflection::GetType("CGameCtnBlock").GetMember("Dir").Offset + 0x8;
					pos = Dev::GetOffsetVec3(blocks[i], offset);
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

void AddNewObject(const string &in objectname, int trigger, const string &in type, vec3 pos, int fallbacksize, bool isofficial) {
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

			if (type == "Block" && tempfile.ByteSize == 0) { // Block is in Items dir
				@tempfile = Fids::GetFake('MemoryTemp\\CurrentMap_EmbeddedFiles\\ContentLoaded\\Items\\' + objectname);
			}
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
#if TMNEXT
			source = "Local";
#else
			source = "In TP";
#endif
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

bool FocusCam(const string &in objectname) {
	auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
	auto camera = editor.OrbitalCameraControl;
	auto map = GetApp().RootMap;


	if (camera !is null) {
		int index = objectsindex.Find(objectname);

		camerafocusindex++;

		if (camerafocusindex > objects[index].positions.Length - 1 ) {
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
