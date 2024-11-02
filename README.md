<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Wprowadź swój nick i lokalizację</title>
</head>
<body>
    <h1>Wprowadź swoje imię lub nick:</h1>
    <input type="text" id="username" placeholder="Twoje imię lub nick" required>
    <h2>Wykrywanie lokalizacji...</h2>
    <p id="locationStatus">Kliknij przycisk, aby uzyskać swoje miasto.</p>
    <button onclick="getLocation()">Uzyskaj lokalizację</button>
    <button onclick="submitUsername()" id="submitBtn" disabled>Wyślij</button>
    <script>
        let userCity = ""; // Zmienna do przechowywania lokalizacji
        async function getLocation() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(async (position) => {
                    const lat = position.coords.latitude;
                    const lon = position.coords.longitude;
                    const city = await getCityFromCoordinates(lat, lon);
                    userCity = city;
                    document.getElementById('locationStatus').innerText = `Twoje miasto: ${userCity}`;
                    document.getElementById('submitBtn').disabled = false; // Włącz przycisk wysyłania
                }, () => {
                    document.getElementById('locationStatus').innerText = 'Nie udało się uzyskać lokalizacji.';
                });
            } else {
                document.getElementById('locationStatus').innerText = 'Geolokalizacja nie jest wspierana przez tę przeglądarkę.';
            }
        }
        async function getCityFromCoordinates(lat, lon) {
            const response = await fetch(`https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lon}&format=json`);
            const data = await response.json();
            return data.address.city || data.address.town || "Nieznane miasto"; // Zwraca miasto lub informację, że miasto jest nieznane
        }
        async function submitUsername() {
            const username = document.getElementById('username').value;
            if (!username || !userCity) {
                alert('Wprowadź swoje imię lub nick oraz uzyskaj lokalizację!');
                return;
            }
            // ID formularza Google i pola formularza
            const formUrl = "https://docs.google.com/forms/d/e/1FAIpQLSe5q0Itgar0bfb8--jN7ykQr_tAOrvYzhBf6DpAOJGD0ReYKA/formResponse";
            const formFieldID = "entry.1068117997";  // ID pola formularza
            // Dodaj użytkownika i lokalizację do wartości
            const prefixedUsername = `Użytkownik: ${username}, Miasto: ${userCity}`;
            // Utwórz dane formularza
            const formData = new FormData();
            formData.append(formFieldID, prefixedUsername);
            try {
                // Wyślij dane do formularza Google
                await fetch(formUrl, {
                    method: "POST",
                    mode: "no-cors",
                    body: formData
                });
                alert("Nick i lokalizacja zapisane pomyślnie!");
                document.getElementById('username').value = ""; // Wyczyść pole po wysłaniu
                userCity = ""; // Wyczyść lokalizację
                document.getElementById('locationStatus').innerText = "Kliknij przycisk, aby uzyskać swoje miasto.";
                document.getElementById('submitBtn').disabled = true; // Wyłącz przycisk wysyłania
            } catch (error) {
                console.error("Błąd:", error);
                alert("Wystąpił błąd podczas zapisu.");
            }
        }
    </script>
</body>
</html>
