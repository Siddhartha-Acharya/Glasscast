🌤 Glasscast — Minimal Weather App (AI-First)

Glasscast is a minimal, modern weather app built with an AI-first development workflow.
It features Supabase authentication, synced favorite cities, and a polished Liquid Glass–inspired UI.

✨ Features
🔐 Authentication

Email / Password login & signup

Powered by Supabase Auth

Session persistence on app relaunch

🌦 Weather

Current weather for selected city

Temperature, condition, high / low

5-day forecast

Pull-to-refresh support

⭐ Favorites

Search and add cities

Save favorites to Supabase

Synced per user account

⚙️ Settings

Temperature unit toggle (°C / °F)

Sign out

App-wide preference sync

🧠 AI-First Development Workflow

This project was built using Claude Code / Cursor as the primary development environment.

AI was used for:

App architecture planning (MVVM, state flow)

SwiftUI screen scaffolding

Supabase auth & database integration

Debugging state and navigation issues

Iterative UI polish

A detailed explanation of the workflow is documented in CLAUDE.md.

🎨 Design

Design created using AI Design Tools (Google Stitch / Figma Make)

Inspired by iOS 26 Liquid Glass

Glass-morphism effects, translucency, blur, depth

Smooth animations and transitions

Clean typography and spacing

🧱 Architecture

SwiftUI

MVVM

Dependency Injection via DIContainer

Shared state via EnvironmentObject

Clean separation of Views, ViewModels, and Services

🔧 Tech Stack

SwiftUI

Supabase (Auth + Database)

Weather API (OpenWeatherMap / WeatherAPI)

Async / Await

Environment-based configuration

🔐 Environment Configuration

Secrets are not hardcoded.

Create an .xcconfig file (or use environment variables):

SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
WEATHER_API_KEY=your_weather_api_key


These are accessed via:

AppEnvironment.supabaseURL
AppEnvironment.supabaseAnonKey
AppEnvironment.weatherAPIKey

🗄 Supabase Setup
Table: favorite_cities
Column	Type
id	uuid (PK)
user_id	uuid (FK)
city_name	text
lat	float
lon	float
created_at	timestamp
Row Level Security (RLS)
CREATE POLICY "Users can manage their own favorites"
ON favorite_cities
FOR ALL
USING (auth.uid() = user_id);

▶️ Running the App

Clone the repository

Open in Xcode

Add your environment variables

Build & run on simulator or device
<img width="414" height="896" alt="IMG_5280" src="https://github.com/user-attachments/assets/f2062278-4be1-40bd-be49-b8868fc353bf" />
<img width="414" height="896" alt="IMG_5282" src="https://github.com/user-attachments/assets/580f780e-6641-49f6-92cc-d4e695075c41" />
<img width="414" height="896" alt="IMG_5281" src="https://github.com/user-attachments/assets/0ef010c1-a989-4ed0-9e44-b9550f861d56" />
<img width="414" height="896" alt="IMG_5283" src="https://github.com/user-attachments/assets/a79ed1f3-9be6-47fe-bdc3-2c1e8450c417" />
<img width="414" height="896" alt="IMG_5279" src="https://github.com/user-attachments/assets/47047066-8da2-46d8-8bb5-83c04b3664f5" />
<img width="414" height="896" alt="IMG_5284" src="https://github.com/user-attachments/assets/4a435331-82b6-4dac-90e6-b091cc901e2d" />

