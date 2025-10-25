# Red Pill — Frontend (Flutter minimal MVP)

Prosty frontend: logowanie, lista rytuałów, dodawanie rytuału, check-in (done/skip/fail).
Domyślnie łączy się z backendem pod `http://127.0.0.1:8000`.

## Wymagania
- Flutter 3.x+
- Android/iOS/Chrome (Web)

## Instalacja
```bash
cd redpill_frontend
flutter pub get
# Web:
flutter run -d chrome
# Android (emulator/urządzenie):
flutter run -d android
```
> Uwaga Web: potrzebujesz **CORS** na backendzie. Dodaj do `backend/app/main.py`:
```python
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Red Pill API", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```
(Jeśli odpalasz apkę **mobilną**, CORS nie jest potrzebny.)

## Konfiguracja adresu API
W pliku `lib/api.dart` zmień stałą `apiBase` jeśli backend działa pod innym adresem.
