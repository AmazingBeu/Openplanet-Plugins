#if TURBO
CGameCtnEditorFree@ getEditor() {
	return cast<CGameCtnEditorFree>(GetApp().Editor);
}

CGameCtnChallenge@ getMap() {
	return cast<CGameCtnChallenge>(GetApp().Challenge);
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
	CGameCtnEditorPluginMapType@ pluginmaptype = cast<CGameCtnEditorPluginMapType>(_Editor.EditorMapType);
    if (pluginmaptype is null) return;
    pluginmaptype.ValidationStatus = CGameCtnEditorPluginMapType::EValidationStatus::Validated;
}

string GetWarning() {
    return "Note: your map must have a start and a finish\n(or a multilap + 1CP) to be validated with the plugin";
}
#endif