# Run the AI Planner web app locally
$FlutterPath = "C:\Users\psoni\Documents\work_data\Ideas\flutter\bin"
$env:PATH = "$FlutterPath;$env:PATH"

flutter pub get
flutter run -d chrome
