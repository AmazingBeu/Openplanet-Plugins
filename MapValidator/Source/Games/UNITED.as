#if UNITED
CTrackManiaEditor@ getEditor() {
	return cast<CTrackManiaEditor>(cast<CTrackMania>(GetApp()).Editor);
}

CGameCtnChallenge@ getMap() {
	return cast<CGameCtnChallenge>(GetApp().Challenge);
}

uint getAuthorTime(CGameCtnChallenge@ _Map) {
    return _Map.ChallengeParameters.AuthorTime;
}

void setAuthorTime(CGameCtnChallenge@ _Map, uint _AuthorTime) {
    _Map.ChallengeParameters.AuthorTime = _AuthorTime;
    _Map.ChallengeParameters.AuthorScore = _AuthorTime;
    _Map.ChallengeParameters.GoldTime = Math::Floor((1000 + _AuthorTime + _AuthorTime * 0.06)/1000)*1000;
    _Map.ChallengeParameters.SilverTime = Math::Floor((1000 + _AuthorTime + _AuthorTime * 0.2)/1000)*1000;
    _Map.ChallengeParameters.BronzeTime = Math::Floor((1000 + _AuthorTime + _AuthorTime * 0.5)/1000)*1000;

    // Remove the map UID, the game will generate it again when saving
    _Map.IdName = "";
}

void setValidationStatus(CTrackManiaEditor@ _Editor) {
    return; // doesn't exists in UNITED
}

string GetWarning() {
    return "Note: for an unknown reason, it happens that the times of\nthe medals are not updated, I invite you to check by yourself";
}
#endif