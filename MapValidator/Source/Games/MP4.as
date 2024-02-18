#if MP4
CGameCtnEditorFree@ getEditor() {
	return cast<CGameCtnEditorFree>(GetApp().Editor);
}

CGameCtnChallenge@ getMap() {
	return cast<CGameCtnChallenge>(GetApp().RootMap);;
}

uint getAuthorTime(CGameCtnChallenge@ _Map) {
    return _Map.TMObjective_AuthorTime;
}

void setAuthorTime(CGameCtnChallenge@ _Map, uint _AuthorTime) {
    _Map.TMObjective_AuthorTime = _AuthorTime;

    // Remove the map UID, the game will generate it again when saving
    _Map.IdName = "";
}

void setValidationStatus(CGameCtnEditorFree@ _Editor) {
    CGameEditorPluginMapMapType@ pluginmaptype = cast<CGameEditorPluginMapMapType>(_Editor.PluginMapType);
    if (pluginmaptype is null) return;
    pluginmaptype.ValidationStatus = CGameEditorPluginMapMapType::EValidationStatus::Validated;
}

string GetWarning() {
    return "";
}
#endif