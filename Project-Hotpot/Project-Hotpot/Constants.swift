import Foundation

let accessTokenKey = "access-token-key"
let redirectUri = URL(string:"project-hotpot://")!
let spotifyClientId = "2c22d6b01fd047b5bd3df14a80649f35"
let spotifyClientSecretKey = "43c562715a0e480d9bb2b9dccd2c75a1"

/*
 Scopes let you specify exactly what types of data your application wants to
 access, and the set of scopes you pass in your call determines what access
 permissions the user is asked to grant.
 For more information, see https://developer.spotify.com/web-api/using-scopes/.
 */
let scopes: SPTScope = [
    .userReadEmail, .userReadPrivate,
    .userReadPlaybackState, .userModifyPlaybackState, .userReadCurrentlyPlaying,
    .streaming, .appRemoteControl,
    .playlistReadCollaborative, .playlistModifyPublic, .playlistReadPrivate, .playlistModifyPrivate,
    .userLibraryModify, .userLibraryRead,
    .userTopRead, .userReadPlaybackState, .userReadCurrentlyPlaying,
    .userFollowRead, .userFollowModify,
]
let stringScopes = [
    "user-read-email", "user-read-private",
    "user-read-playback-state", "user-modify-playback-state", "user-read-currently-playing",
    "streaming", "app-remote-control",
    "playlist-read-collaborative", "playlist-modify-public", "playlist-read-private", "playlist-modify-private",
    "user-library-modify", "user-library-read",
    "user-top-read", "user-read-playback-position", "user-read-recently-played",
    "user-follow-read", "user-follow-modify",
]

let backupGenres = ["acoustic", "afrobeat", "alt-rock", "alternative", "ambient", "anime", "black-metal", "bluegrass", "blues", "bossanova", "brazil", "breakbeat", "british", "cantopop", "chicago-house", "children", "chill", "classical", "club", "comedy", "country", "dance", "dancehall", "death-metal", "deep-house", "detroit-techno", "disco", "disney", "drum-and-bass", "dub", "dubstep", "edm", "electro", "electronic", "emo", "folk", "forro", "french", "funk", "garage", "german", "gospel", "goth", "grindcore", "groove", "grunge", "guitar", "happy", "hard-rock", "hardcore", "hardstyle", "heavy-metal", "hip-hop", "holidays", "honky-tonk", "house", "idm", "indian", "indie", "indie-pop", "industrial", "iranian", "j-dance", "j-idol", "j-pop", "j-rock", "jazz", "k-pop", "kids", "latin", "latino", "malay", "mandopop", "metal", "metal-misc", "metalcore", "minimal-techno", "movies", "mpb", "new-age", "new-release", "opera", "pagode", "party", "philippines-opm", "piano", "pop", "pop-film", "post-dubstep", "power-pop", "progressive-house", "psych-rock", "punk", "punk-rock", "r-n-b", "rainy-day", "reggae", "reggaeton", "road-trip", "rock", "rock-n-roll", "rockabilly", "romance", "sad", "salsa", "samba", "sertanejo", "show-tunes", "singer-songwriter", "ska", "sleep", "songwriter", "soul", "soundtracks", "spanish", "study", "summer", "swedish", "synth-pop", "tango", "techno", "trance", "trip-hop", "turkish", "work-out", "world-music"]
