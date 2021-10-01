bool menu_visibility = false;
int mode;
int lightmaptoselect = -1;
bool searchmode;
array<CGameEditorPluginMap::EMapElemLightmapQuality> activelm;

const vec4 pickedcolor = vec4(.16,.4,.65,.3);

void Main() {

	while (true) {
		if (lightmaptoselect >= 0) {
			print("Searching for the lm priority: " + lightmaptoselect);
			auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
			auto pluginmap = cast<CGameEditorPluginMapMapType>(editor.PluginMapType);

			pluginmap.EditMode = CGameEditorPluginMap::EditMode::SelectionAdd;
			auto blocks = GetApp().RootMap.Blocks;
			for (int i = 0; i < blocks.Length;) {
				print("Block number: "  + i);
				if (!(lightmaptoselect >= 0) || pluginmap.PlaceMode != CGameEditorPluginMap::EPlaceMode::CopyPaste) break; //ability to cancel
				if (pluginmap.EditMode == CGameEditorPluginMap::EditMode::SelectionAdd) {
					if (blocks[i].MapElemLmQuality == lightmaptoselect && blocks[i].BlockModel.Name != "Grass") {
						int3 coord;
						coord.x = blocks[i].Coord.x;
						coord.y = blocks[i].Coord.y;
						coord.z = blocks[i].Coord.z;
						pluginmap.CopyPaste_AddOrSubSelection(coord, coord);
					}
					if (i % 5 == 0) yield();
					i++;
				} else {
					yield();
				}
			}

			auto items = GetApp().RootMap.AnchoredObjects;
			for (int i = 0; i < items.Length;) {
				if (! (lightmaptoselect >= 0) || pluginmap.PlaceMode != CGameEditorPluginMap::EPlaceMode::CopyPaste) break; //ability to cancel
				if (pluginmap.EditMode == CGameEditorPluginMap::EditMode::SelectionAdd) {
					if (items[i].MapElemLmQuality == lightmaptoselect) {
						int3 coord;
						coord.x = items[i].BlockUnitCoord.x;
						coord.y = items[i].BlockUnitCoord.y;
						coord.z = items[i].BlockUnitCoord.z;
						pluginmap.CopyPaste_AddOrSubSelection(coord, coord);
					}
					if (i % 5 == 0) yield();
					i++;
				} else {
					yield();
				}
			}
			lightmaptoselect = -1;
		}
		yield();
	}
}

void UpdateSelectedLightmap() {
	auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
	auto pluginmap = cast<CGameEditorPluginMapMapType>(editor.PluginMapType);
	if (pluginmap.PlaceMode == CGameEditorPluginMap::EPlaceMode::CopyPaste) {

		// Value in CopyPaste_GetLightmapQualityInSelection_Results is broken

		/*pluginmap.CopyPaste_GetLightmapQualityInSelection(); 
		activelm = {};
		for (int i=0 ; i < pluginmap.CopyPaste_GetLightmapQualityInSelection_Results.Length; i++) {
			print("" + pluginmap.CopyPaste_GetLightmapQualityInSelection_Results[i]);
		}*/
	} else {
		activelm = {pluginmap.NextMapElemLightmapQuality};
	}
}
	
void ApplyLightmapPriority(string mode) {

}

void Render() {
	if (!menu_visibility) {
		return;
	}

	auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);

	UI::Begin("\\$fc3" + Icons::LightbulbO + "\\$z Lightmap Quality###LightmapQuality", menu_visibility, UI::WindowFlags::NoResize | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse);
	if (editor !is null) {
		auto pluginmap = cast<CGameEditorPluginMapMapType>(editor.PluginMapType);
		bool updateselectedlightmap = false;

		if (!pluginmap.ForceMacroblockLightmapQuality) pluginmap.ForceMacroblockLightmapQuality = true; // Enable Macroblock by defaut

		if (mode != pluginmap.PlaceMode) {
			mode = pluginmap.PlaceMode;
			UpdateSelectedLightmap();
		}

		if (mode == CGameEditorPluginMap::EPlaceMode::CopyPaste) {
			UI::Text("Set Lightmap priority to the selection:");
			UI::SameLine();
			if (searchmode) UI::PushStyleColor(UI::Col::Button,pickedcolor);
			if (UI::Button(Icons::Search)) {
				lightmaptoselect = -1; //ability to cancel
				searchmode = !searchmode;
				if (!searchmode) UI::PopStyleColor();
			} else {
				if (searchmode) UI::PopStyleColor();
			}
			
			UpdateSelectedLightmap();
		} else {
			UI::Text("Set Lightmap priority to the next element:");
		}

		if (activelm.Find(CGameEditorPluginMap::EMapElemLightmapQuality::Lowest) >= 0) {
			UI::PushStyleColor(UI::Col::Button,pickedcolor);
				UI::Button("-3");
			UI::PopStyleColor();
		} else {
			if (UI::Button("-3")) {
				if (mode == CGameEditorPluginMap::EPlaceMode::CopyPaste && searchmode) {
					pluginmap.CopyPaste_ResetSelection();
					lightmaptoselect = CGameEditorPluginMap::EMapElemLightmapQuality::Lowest;
				} else {
					pluginmap.NextMapElemLightmapQuality = CGameEditorPluginMap::EMapElemLightmapQuality::Lowest;
					pluginmap.CopyPaste_ApplyLightmapQualityToSelection(CGameEditorPluginMap::EMapElemLightmapQuality::Lowest);
					UpdateSelectedLightmap();
				}
			}
		}
		UI::SameLine();
		if (activelm.Find(CGameEditorPluginMap::EMapElemLightmapQuality::VeryLow) >= 0) {
			UI::PushStyleColor(UI::Col::Button,pickedcolor);
				UI::Button("-2");
			UI::PopStyleColor();
		} else {
			if (UI::Button("-2")) {
				if (mode == CGameEditorPluginMap::EPlaceMode::CopyPaste && searchmode) {
					pluginmap.CopyPaste_ResetSelection();
					lightmaptoselect = CGameEditorPluginMap::EMapElemLightmapQuality::VeryLow;
				} else {
					pluginmap.NextMapElemLightmapQuality = CGameEditorPluginMap::EMapElemLightmapQuality::VeryLow;
					pluginmap.CopyPaste_ApplyLightmapQualityToSelection(CGameEditorPluginMap::EMapElemLightmapQuality::VeryLow);
					UpdateSelectedLightmap();
				}
			}
		}
		UI::SameLine();
		if (activelm.Find(CGameEditorPluginMap::EMapElemLightmapQuality::Low) >= 0) {
			UI::PushStyleColor(UI::Col::Button,pickedcolor);
				UI::Button("-1");
			UI::PopStyleColor();
		} else {
			if (UI::Button("-1")) {
				if (mode == CGameEditorPluginMap::EPlaceMode::CopyPaste && searchmode) {
					pluginmap.CopyPaste_ResetSelection();
					lightmaptoselect = CGameEditorPluginMap::EMapElemLightmapQuality::Low;
				} else {
					pluginmap.NextMapElemLightmapQuality = CGameEditorPluginMap::EMapElemLightmapQuality::Low;
					pluginmap.CopyPaste_ApplyLightmapQualityToSelection(CGameEditorPluginMap::EMapElemLightmapQuality::Low);
					UpdateSelectedLightmap();
				}
			}
		}
		UI::SameLine();
		if (activelm.Find(CGameEditorPluginMap::EMapElemLightmapQuality::Normal) >= 0) {
			UI::PushStyleColor(UI::Col::Button,pickedcolor);
				UI::Button("0");
			UI::PopStyleColor();
		} else {
			if (UI::Button("0")) {
				if (mode == CGameEditorPluginMap::EPlaceMode::CopyPaste && searchmode) {
					pluginmap.CopyPaste_ResetSelection();
					lightmaptoselect = CGameEditorPluginMap::EMapElemLightmapQuality::Normal;
				} else {
					pluginmap.NextMapElemLightmapQuality = CGameEditorPluginMap::EMapElemLightmapQuality::Normal;
					pluginmap.CopyPaste_ApplyLightmapQualityToSelection(CGameEditorPluginMap::EMapElemLightmapQuality::Normal);
					UpdateSelectedLightmap();
				}
			}
		}
		UI::SameLine();
		if (activelm.Find(CGameEditorPluginMap::EMapElemLightmapQuality::High) >= 0) {
			UI::PushStyleColor(UI::Col::Button,pickedcolor);
				UI::Button("+1");
			UI::PopStyleColor();
		} else {
			if (UI::Button("+1")) {
				if (mode == CGameEditorPluginMap::EPlaceMode::CopyPaste && searchmode) {
					pluginmap.CopyPaste_ResetSelection();
					lightmaptoselect = CGameEditorPluginMap::EMapElemLightmapQuality::High;
				} else {
					pluginmap.NextMapElemLightmapQuality = CGameEditorPluginMap::EMapElemLightmapQuality::High;
					pluginmap.CopyPaste_ApplyLightmapQualityToSelection(CGameEditorPluginMap::EMapElemLightmapQuality::High);
					UpdateSelectedLightmap();
				}
			}
		}
		UI::SameLine();
		if (activelm.Find(CGameEditorPluginMap::EMapElemLightmapQuality::VeryHigh) >= 0){
			UI::PushStyleColor(UI::Col::Button,pickedcolor);
				UI::Button("+2");
			UI::PopStyleColor();
		} else {
			if (UI::Button("+2")) {
				if (mode == CGameEditorPluginMap::EPlaceMode::CopyPaste && searchmode) {
					pluginmap.CopyPaste_ResetSelection();
					lightmaptoselect = CGameEditorPluginMap::EMapElemLightmapQuality::VeryHigh;
				} else {
					pluginmap.NextMapElemLightmapQuality = CGameEditorPluginMap::EMapElemLightmapQuality::VeryHigh;
					pluginmap.CopyPaste_ApplyLightmapQualityToSelection(CGameEditorPluginMap::EMapElemLightmapQuality::VeryHigh);
					UpdateSelectedLightmap();
				}
			}
		}
		UI::SameLine();
		if (activelm.Find(CGameEditorPluginMap::EMapElemLightmapQuality::Highest) >= 0) {
			UI::PushStyleColor(UI::Col::Button,pickedcolor);
				UI::Button("+3");
			UI::PopStyleColor();
		} else {
			if (UI::Button("+3")) {
				if (mode == CGameEditorPluginMap::EPlaceMode::CopyPaste && searchmode) {
					pluginmap.CopyPaste_ResetSelection();
					lightmaptoselect = CGameEditorPluginMap::EMapElemLightmapQuality::Highest;
				} else {
					pluginmap.NextMapElemLightmapQuality = CGameEditorPluginMap::EMapElemLightmapQuality::Highest;
					pluginmap.CopyPaste_ApplyLightmapQualityToSelection(CGameEditorPluginMap::EMapElemLightmapQuality::Highest);
					UpdateSelectedLightmap();
				}
			}
		}
	} else {
		UI::Text("Open this plugin in the map editor");
	}

	UI::End();
	
}
	
void RenderMenu() {
	if(UI::MenuItem("\\$fc3" + Icons::LightbulbO + "\\$z Lightmap Quality", "", menu_visibility)) {
		menu_visibility = !menu_visibility;
	}
}
