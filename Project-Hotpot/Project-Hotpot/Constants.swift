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

