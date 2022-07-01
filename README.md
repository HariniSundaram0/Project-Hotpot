# Project-Hotpot
Project Hotpot: Project Plan 

**Description**
This project aims to utilize a "Tinder-like" design feature for users to explore completely new genres and styles of music. Currently music streaming platforms— including Spotify, Youtube Music, etc — utilize recommendation algorithms based on what users already listen to. As a result, it is very common for clients to get into "Music ruts", where they get bored of the music they constantly listen to. Therefore, I aim to introduce clients to completely different styles, genres, and languages of music via a simple UI. 

## Required Must-have Stories 

#### P0:
- users can swipe through infinite scroll of "randomized" songs
- user can listen to the audio, and view the song information, which includes singer, title, duration of song
- users are able to pause and play songs. 
- users can perform a swipe right gesture to 'like' the song and add the song to 'Liked Songs' or a playlist of their choice. 
- this option should be able to be changed either in settings or via a alert triggered by the gesture 
- users can perform a swipe left gesture to disregard the song,causing a new song to appears 
- users can sign up locally via the app, log in, log out
- Users can log into the spotify account, and allow access to their account. 
#### P1: 
- Users can adjust a few of the the  algorithm preferences/filters via the settings tab, such as: 
  - language preferences  
  - allowing explicit language or not
  - Genre of music
- Users can view their liked songs / playlists created within this app
- The algorithm keeps track of the songs users listen to, to prevent repetitive songs.
## Optional Stories: 
#### P2: 
- Users can play songs via the ‘liked songs’ / ‘Library’ View. 
- Users can further customize their randomization preferences to: 
  - BPM (if using soundcloud API) 
  - Duration
  - Tags (i.e “dancability”, “moody”)
- If user selects fully random, algorithm should find songs the most different from past songs listened to 
- Users are able to listen to songs without too long of a lag 
  - Implemented by some version of prefetching 
- Users can delete their account, causing all of their playlists and data to be also be deleted. 
#### P3: 
- Users can view previously created Spotify playlists 
- users can view their profile. 
- users can upload their own music to the app, which will be included in the 'randomization' algorithm. 
- users who have uploaded their own music can view the analytics of their song, including how many people listened to the song, and how many people swiped right on it 
- users can report songs via the randomization view. When a certain percentage of the song's listens are reported, the song is removed. 
- if an 'artist' removes a song or deletes their account, the song should be removed from the database, and also other user's playlists. 

*PLANNED PROBLEM*: instead of a 'randomization' algorithm, create an algorithm that varies the language, BPM, genre, and tempo of the music, to truly introduce users to new music. 

App Evaluation
- Category: Music
- Mobile:swipe gestures are uniquely tailored for mobile devices. The layout will be tailored for mobile screens, meaning a limitation of information present at any given moment. 
- Story:The value/main goal of this app is to alleviate 'music boredom'. I believe that many people would be open to the idea of at least exploring many languages/genres of music that they don't often get to experience. 
- Market:This app is tailored for people who listen to music quite often. I have personally experienced getting tired of my own playlists and recommendations. The 'radio' or 'random' features on streaming platforms often consist of solely english / mainstream pop songs, which do not cater towards the entire listening audience. Often, the only way to explore new music, is via recommendations from friends, or by already knowing what to search for. The size of the market is enormous. In 2022, Spotify received over 422 million monthly active users.
- Habit:I believe this app won't necessarily become addicting, but could become a regular part of someone's life. I envision someone opening the app every week or so, exploring songs, and adding a few to their playlist. Depending on how many features I add, it can become a daily habit instead of weekly. 
- Scope:This app is fairly well defined. The main feature is the tinder esque song exploration. Other features and their ease of implementation will depend on how much information the Spotify API provides. 



