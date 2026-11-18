# Chapter 1

## Introduction

Travelers often need more than a list of popular destinations. They need reliable route information, local context, practical planning details, and opportunities to connect with people who have similar interests. These needs are especially important for travelers exploring Southeast Asia, where routes may include mountains, islands, rivers, temples, and remote communities.

Odyssey is a Flutter-based field journal and expedition network designed to support this kind of travel. The application brings together travel stories, expedition routes, map locations, personal schedules, community connections, and group gatherings in one mobile-oriented experience. Its visual design is inspired by expedition notebooks, archival maps, and field journals.

The current version of Odyssey is an evolving prototype. It demonstrates the main user experience and interaction flow using curated sample content and in-memory application state. It is intended to validate the product concept and interface before a production backend, persistent storage, and real authentication services are added.

## Background of the Project

Many travel applications focus on destinations, bookings, or short reviews. This can make travel planning feel disconnected from the personal stories and practical knowledge that shape an actual expedition. A traveler may need to discover a route, understand its conditions, identify meaningful places along the way, find companions, and organize plans without switching between several unrelated applications.

Odyssey addresses this gap by presenting travel as an expedition experience rather than a checklist of destinations. The application combines narrative content with practical planning tools:

- Chronicles provide first-hand stories about places and journeys.
- Routes present practical multi-day travel information.
- Map locations connect stories and points of interest to geography.
- Circle helps travelers discover companions and local knowledge.
- Gatherings support shared expeditions and community plans.

The prototype currently focuses on Southeast Asia, with sample content inspired by Vietnam, Laos, Indonesia, and the Mekong region.

## Statement of the Problem

Travelers who want slower, more personal, and community-oriented journeys may find it difficult to discover trustworthy local context, organize expedition details, and connect with suitable companions in one place. Existing travel tools can separate stories, maps, schedules, and social interactions into different services.

This project therefore explores the following question:

**How can a single, visually coherent application help travelers discover meaningful routes, understand the stories behind them, plan their journeys, and connect with fellow travelers?**

The prototype specifically investigates how the following functions can work together:

1. Discovering stories, routes, events, and people.
2. Viewing travel stories and places on an interactive map.
3. Organizing personal plans and joined expeditions.
4. Connecting with companions and responding to friend requests.
5. Joining community gatherings and shared trips.

## Objectives of the Project

### General Objective

To design and develop a Flutter-based expedition network prototype that combines travel discovery, storytelling, planning, mapping, and community interaction for Southeast Asian travel.

### Specific Objectives

The project aims to:

1. Provide a home experience for discovering travel stories, posts, notifications, and upcoming plans.
2. Present practical routes and expedition events with dates, locations, capacity, and participation status.
3. Provide an interactive map for viewing story locations and adding map pins.
4. Enable users to browse potential companions and manage friend-request interactions.
5. Allow users to create stories, text posts, invitation posts, map pins, and schedule plans.
6. Demonstrate login, sign-up, validation, password-reset, and sign-out user flows.
7. Establish a reusable visual theme and component structure for future feature development.

## Scope and Limitations

### Scope

The current prototype includes the following modules:

- **Authentication:** Login, sign-up, validation, password reset feedback, and sign-out flows.
- **Home:** Personalized greeting, next expedition, social feed, and post interactions.
- **Schedule:** Calendar navigation, plans, joined events, filters, and timeline entries.
- **Map:** Southeast Asia map view, story pins, pin creation, zoom controls, and story browsing.
- **Community:** Wayfarer search, suggested companions, friends, and friend requests.
- **Events:** Upcoming gatherings, multi-day expeditions, filters, capacity information, and join/leave actions.
- **Content creation:** Story, text, invitation, map-pin, and schedule-entry composition flows.
- **Detail views:** Story reader, profile screen, and event details screen.

### Limitations

The following items are outside the current prototype or remain simulated:

- Authentication is not connected to a real account provider or backend service.
- Google sign-in and sign-up are not connected.
- User data, posts, plans, likes, saves, friend statuses, and joined events are stored only in memory.
- There is no database, API service, messaging system, or cloud synchronization.
- The initial content is curated sample data rather than user-generated remote content.
- Comments, direct messaging, content sharing, and profile editing are not implemented.
- The map currently uses a public OpenStreetMap tile endpoint and requires a production tile-provider strategy for deployment.
- The repository currently targets Android, web, and Windows; other Flutter platforms are not included.
- The application is a prototype and should not be considered production-ready without security, persistence, accessibility, performance, and deployment work.

## Significance of the Project

### Travelers

The project provides a focused way to discover routes, stories, locations, events, and companions in one experience. It emphasizes practical and human context instead of destination listings alone.

### Local Communities and Experienced Wayfarers

The application creates a potential space for sharing local knowledge, personal stories, route guidance, and invitations to community activities.

### Expedition Organizers

The event and schedule concepts provide a foundation for organizing multi-day trips, tracking participation, and communicating essential expedition details.

### Future Developers

The project establishes a Flutter application structure with reusable theme components, data models, a centralized observable store, and modular screens that can be extended with backend services.

### Researchers and Designers

The prototype can be used to evaluate how storytelling, mapping, planning, and social discovery can be combined in a travel-oriented interface.

## Definition of Terms

- **Chronicle:** A first-hand travel story or field-journal entry about a place or journey.
- **Circle:** The community area where users discover companions and local knowledge.
- **Expedition:** A planned journey that may contain multiple dates, locations, or activities.
- **Gathering:** A community event or shared travel activity that users can join.
- **Map Pin:** A geographic marker representing a story, place, or point of interest.
- **Odyssey:** The name of the proposed expedition network and field-journal application.
- **Plan Item:** A personal schedule entry associated with a date, time, location, or activity.
- **Route:** A practical travel journey containing information such as distance, surface, elevation, season, resupply, and lodging.
- **Wayfarer:** A user or traveler participating in the Odyssey community.

## Summary

Odyssey is a Flutter prototype that explores a unified approach to expedition planning and travel discovery. It combines stories, routes, maps, schedules, community connections, and gatherings within a single Southeast Asia-focused experience. The prototype demonstrates the primary user interface and interaction flows using local sample data. Future development will require backend authentication, persistent storage, real-time synchronization, production map services, and additional community features.