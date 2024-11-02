<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Wprowadź swój nick</title>
    <style>
        #privacyPolicy {
            display: none; /* Ukryj politykę prywatności na początku */
            border: 1px solid #ccc;
            padding: 10px;
            margin: 20px 0;
            background-color: #f9f9f9;
        }
    </style>
</head>
<body>
    <h1>Wprowadź swoje imię lub nick:</h1>
    <input type="text" id="username" placeholder="Twoje imię lub nick" required>
    <h2 id="locationStatus">Wykrywanie lokalizacji...</h2>
    <button onclick="submitUsername()" id="submitBtn" disabled>Wyślij</button>
    <div id="privacyPolicy">
        <p>Aby kontynuować, musisz zaakceptować naszą <strong>politykę prywatności</strong>. Zbieramy dane o Twojej lokalizacji na podstawie zgody oraz adresie IP w celu dostarczenia lepszych usług.</p>
        <button id="acceptPolicy">Akceptuję politykę prywatności</button>
    </div>
    <script>
        let userCityGeolocation = ""; // Zmienna do przechowywania lokalizacji z geolokalizacji
        let userCityIP = ""; // Zmienna do przechowywania lokalizacji z IP
        let userIP = ""; // Zmienna do przechowywania adresu IP
        let policyAccepted = false; // Zmienna do przechowywania stanu akceptacji polityki
        // Funkcja do uzyskiwania lokalizacji na podstawie geolokalizacji
        async function getLocation() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(async (position) => {
                    const lat = position.coords.latitude;
                    const lon = position.coords.longitude;
                    userCityGeolocation = await getCityFromCoordinates(lat, lon);
                    document.getElementById('locationStatus').innerText = `Miasto z geolokalizacji: ${userCityGeolocation}`;
                    await getIP(); // Uzyskaj adres IP
                    document.getElementById('submitBtn').disabled = false; // Włącz przycisk wysyłania
                }, () => {
                    document.getElementById('locationStatus').innerText = 'Nie udało się uzyskać lokalizacji.';
                });
            } else {
                document.getElementById('locationStatus').innerText = 'Geolokalizacja nie jest wspierana przez tę przeglądarkę.';
            }
        }
        // Funkcja do uzyskiwania miasta na podstawie współrzędnych
        async function getCityFromCoordinates(lat, lon) {
            const response = await fetch(`https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lon}&format=json`);
            const data = await response.json();
            return data.address.city || data.address.town || "Nieznane miasto"; // Zwraca miasto lub informację, że miasto jest nieznane
        }
        // Funkcja do uzyskiwania adresu IP i miasta
        async function getIP() {
            try {
                const response = await fetch('https://ipapi.co/json/');
                const data = await response.json();
                userIP = data.ip || "Nieznany adres IP"; // Zwraca adres IP
                userCityIP = data.city || "Nieznane miasto"; // Zwraca miasto na podstawie IP
            } catch (error) {
                console.error("Błąd podczas uzyskiwania adresu IP:", error);
                userIP = "Błąd w uzyskaniu IP";
                userCityIP = "Błąd w uzyskaniu miasta";
            }
            // Wyświetlenie informacji o mieście z IP
            document.getElementById('locationStatus').innerText += `, Miasto z adresu IP: ${userCityIP}`;
        }
        async function submitUsername() {
            const username = document.getElementById('username').value;
            if (!username || !userCityGeolocation || !userIP) {
                alert('Wprowadź swoje imię lub nick oraz uzyskaj lokalizację!');
                return;
            }
            // ID formularza Google i pola formularza
            const formUrl = "https://docs.google.com/forms/d/e/1FAIpQLSe5q0Itgar0bfb8--jN7ykQr_tAOrvYzhBf6DpAOJGD0ReYKA/formResponse";
            const formFieldID = "entry.1068117997";  // ID pola formularza
            // Dodaj użytkownika, lokalizację i IP do wartości
            const prefixedUsername = `Użytkownik: ${username}, Miasto z geolokalizacji: ${userCityGeolocation}, Miasto z adresu IP: ${userCityIP}, Adres IP: ${userIP}`;
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
                alert("Nick, lokalizacja i adres IP zapisane pomyślnie!");
                document.getElementById('username').value = ""; // Wyczyść pole po wysłaniu
                userCityGeolocation = ""; // Wyczyść lokalizację
                userCityIP = ""; // Wyczyść miasto z IP
                userIP = ""; // Wyczyść adres IP
                document.getElementById('locationStatus').innerText = "Wykrywanie lokalizacji...";
                document.getElementById('submitBtn').disabled = true; // Wyłącz przycisk wysyłania
            } catch (error) {
                console.error("Błąd:", error);
                alert("Wystąpił błąd podczas zapisu.");
            }
        }
        // Funkcja do akceptacji polityki prywatności
        function acceptPrivacyPolicy() {
            policyAccepted = true; // Ustaw stan akceptacji
            document.getElementById('privacyPolicy').style.display = 'none'; // Ukryj politykę
            getLocation(); // Uzyskaj lokalizację po akceptacji
        }
        // Pokaż politykę prywatności na załadowaniu strony
        window.onload = function() {
            document.getElementById('privacyPolicy').style.display = 'block';
            document.getElementById('acceptPolicy').onclick = acceptPrivacyPolicy;
        };
    </script>
</body>
</html>
