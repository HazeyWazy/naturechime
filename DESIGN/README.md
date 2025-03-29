# NatureChime

## _"Capture the world, one sound at a time."_

NatureChime is a mobile application designed to help users discover, record, and catalog the diverse audio environments that surround us daily. From the gentle rustling of leaves in a forest to the rhythmic clatter of a passing train, our world is filled with distinctive sounds that often go unnoticed or undocumented. NatureChime lets users capture these audio moments, and build personal sound libraries.

Unlike traditional audio recording apps that focus on voice memos or music creation, NatureChime is specifically designed for environmental sound collection. Whether you're a nature enthusiast documenting bird calls, an urban explorer mapping city soundscapes, or someone who simply appreciates unique audio experiences, NatureChime provides the tools to create a personal archive of environmental sounds.

## Main Features of NatureChime

### Core Functionality

#### Sound Recording & Capture

- One-touch recording activation (start/stop button)
- Automatic metadata capture (time, date)
- Manual entry for title and description
- Geolocation capture (optional)

#### Sound Organisation & Management

- View a list of recordings (title, date recorded)
- Edit recording details (rename, update description)
- Delete recordings (with confirmation prompt)
- Store/retrieve recordings from Firebase Storage

#### Playback

- Basic playback controls (play/pause, seek bar)
- Recording details display during playback
- Delete/edit options for recordings

#### User Authentication & Profile

- Sign up/login with Firebase Authentication
- Personal profile displaying profile picture, username and email
- Log out functionality

#### Basic UI & Navigation

- Home screen displaying recordings
- Navigation between home, record, library, explore, and profile screens
- Loading/error handling
- Dark mode

### Additional Features

#### Advanced Audio Features

- High-quality audio recording with adjustable settings
- Waveform visualisation during recording and playback
- Noise reduction

#### Enhanced Organisation

- Tagging system
- Search and filtering by title, location, date

#### User Experience

- Dark mode
- Favourites system for quick access to preferred sounds
- Offline recording capability with later synchronisation

#### Community Features

- Option to make recordings public or keep them private
- Likes and comments system for community engagement
- Following system to track favorite sound collectors

## User Analysis of Nature Chime

### Target User Groups

NatureChime appeals to several distinct user segments, each with different motivations for capturing environmental sounds:

#### Nature Enthusiasts & Outdoor Adventurers

This group values documenting authentic natural soundscapes during their outdoor activities. They seek to preserve memories of their experiences and create personal collections of natural sounds from different environments, seasons, and locations.

#### Urban Explorers & City Dwellers

These users are fascinated by the distinctive sounds of urban environments. They enjoy discovering and documenting the unique acoustic character of different cities, neighborhoods, and human-made structures, from subway stations to historic buildings.

#### Mindfulness Practitioners & Sound Therapy Users

These users collect calming or interesting sounds to use for meditation, relaxation, or sound therapy. They focus on sounds that evoke specific emotions or mental states, such as gentle rainfall or distant wind chimes.

### Potential User Groups

#### Content Creators & Educators

This segment includes podcasters, filmmakers, teachers, and other creators who collect environmental sounds for their projects. They value high-quality recordings and detailed metadata for potential reuse in various creative and educational contexts.

#### Acoustic Ecology Enthusiasts & Researchers

This niche but passionate user group is interested in documenting changing soundscapes for cultural preservation, environmental awareness, or scientific documentation, capturing sounds that might be disappearing due to environmental changes.

### User Personas

#### **Emma, 34 - The Nature Enthusiast**

**Background**: Wildlife biologist and amateur photographer

**Motivation**: Documenting biodiversity through sound

**Behaviours**: Regular hiking trips to national parks and nature reserves, particularly interested in bird calls and seasonal variations in forest sounds

**Usage Pattern**: Records weekly during outdoor excursions, meticulously tags and categorises findings, occasionally shares interesting discoveries

**Pain Points**: Existing apps lack proper organization systems for nature sounds

#### **Marcus, 27 - The Urban Sound Explorer**

**Background**: Architectural student and podcast listener

**Motivation**: Capturing the voice of different urban spaces

**Behaviours**: Explores different neighborhoods on weekends, fascinated by how sound reflects cultural and structural aspects of cities

**Usage Pattern**: Records spontaneously while commuting or exploring, uses location features heavily, actively shares favorite urban soundscapes with friends

**Pain Points**: Wants better ways to organize city sounds, existing apps are too focused on music or voice memos

#### **Sophia, 42 - The Mindfulness Practitioner**

**Background**: Yoga instructor and wellness blogger

**Motivation**: Collecting calming sounds for classes and personal practice

**Behaviours**: Seeks out peaceful environments, records longer ambient soundscapes

**Usage Pattern**: Selective recording of peaceful sounds, focused on playback quality, less interested in social features

**Pain Points**: Other apps have too much ambient noises, wants clean recordings for professional use

### Competitive Advantage

Users choose NatureChime over alternatives for several key reasons:

#### Compared to General Recording Apps (Voice Memos, Field Recording Apps)

- Purpose-built interface specifically for environmental sounds
- Automatic metadata and context capture
- Organization system designed for sound types rather than just dates or titles
- Community of like-minded sound enthusiasts

#### Compared to Social Audio Platforms (SoundCloud, Audio-sharing Apps)

- Focus on environmental sounds rather than music or podcasts
- Location-based discovery features
- More detailed metadata and context preservation
- More privacy options for personal collections

#### Compared to Professional Sound Equipment/Software

- Accessibility for non-technical users
- Mobile-first approach for spontaneous recording
- Built-in community and discovery features
- No expensive equipment required

NatureChime fills a unique niche between professional audio tools and casual recording apps, offering the perfect balance of functionality, community engagement, and ease of use for people who want to capture and appreciate the everyday sounds around them.

## App Design

### Key Screen Designs and User Flows

#### Welcome Screen

![Welcome Screen](./Wireframe/welcome.png)

#### Login Screen

![Login Screen](./Wireframe/login.png)

#### Create Account Screen

![Create Account Screen](./Wireframe/create_account.png)

### Authentication Flow

The welcome screen introduces users to NatureChime's core functionalities. New users can create an account with email or Google login, while returning users enter through a streamlined login process. The account creation screen collects essential information while clearly communicating privacy practices.

**Key Design Elements:**

- Brief, iconographic representation of core features
- Clear call-to-action buttons for Sign Up and Login
- Option to explore limited features before signing up

**User Flow:**

From the welcome screen, users can either:

1. Tap "Create Account" to create a new account (transitions to create account screen)
2. Tap "Log In" if they're returning users (transitions to login screen)
3. Tap "Explore Without Account" to browse public recordings without an account (transitions to explore screen)

### Home Screen

![Home Screen](./Wireframe/home.png)

The home screen features recently recorded sounds, and quick-access recording control.

**Key Design Elements:**

- Floating action button for instant recording
- four recent recordings displayed as lists with title, date, and location
- Bottom navigation providing access to all main sections

**User Flow:**

The dashboard connects to all primary functions:

1. Tap the microphone button to start recording (transitions to recording screen)
2. Tap any recent recording to view detailed playback (transitions to playback screen)
3. Use bottom navigation to access other main sections

### Library Screen

![Library Screen](./Wireframe/library.png)

The library provides a list view to browse personal recordings.

**Key Design Elements**:

- List view displays recordings with title, date, and location
- Number of total recordings shown at the top
- 3 dots icon to delete and edit on the right side of each recording list
- Bottom navigation providing access to all main sections

User Flow:

1. Tap any recording to open detailed view (transitions to playback screen)
2. Tap the filter button to narrow results by tags, date, or location (transitions to filter screen)
3. Tap 3 dots icon to delete recording or edit recording description
4. Use bottom navigation to access other main sections