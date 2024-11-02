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
    <h2 id="locationStatus">....</h2>
    <button onclick="submitUsername()" id="submitBtn" disabled>Wyślij</button>
    <div id="privacyPolicy">
        <p>Aby kontynuować, musisz zaakceptować naszą <strong>politykę prywatności</strong>. Zbieramy dane o Twojej lokalizacji na podstawie adresu IP w celu dostarczenia lepszych usług.</p>
        <button id="acceptPolicy">Akceptuję politykę prywatności</button>
    </div>
    <script>
        let userCity = ""; // Zmienna do przechowywania lokalizacji
        let policyAccepted = false; // Zmienna do przechowywania stanu akceptacji polityki
        async function getLocation() {
            try {
                const response = await fetch('https://ipapi.co/json/');
                const data = await response.json();
                userCity = data.city || "Nieznane miasto"; // Zwraca miasto lub informację, że miasto jest nieznane
                document.getElementById('locationStatus').innerText = `Twoje miasto: ${userCity}`;
                document.getElementById('submitBtn').disabled = false; // Włącz przycisk wysyłania
            } catch (error) {
                console.error("Błąd podczas uzyskiwania lokalizacji:", error);
                document.getElementById('locationStatus').innerText = 'Nie udało się uzyskać lokalizacji.';
            }
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
                alert("Nick zapisane pomyślnie!");
                document.getElementById('username').value = ""; // Wyczyść pole po wysłaniu
                userCity = ""; // Wyczyść lokalizację
                document.getElementById('locationStatus').innerText = "....";
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
