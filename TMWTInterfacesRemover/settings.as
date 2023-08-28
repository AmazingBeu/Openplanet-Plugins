enum GameMode {
    TMWT,
    TMWC2023,
}

[Setting category="Interfaces" name="Game mode"]
GameMode Setting_GameMode = GameMode::TMWT;

[Setting category="Interfaces" name="Hide Live Ranking"]
bool HideLiveRanking = true;

[Setting category="Interfaces" name="Hide Teams Scores"]
bool HideTeamsScores = true;
