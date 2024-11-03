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
            const response = await fetch('https://api.ipify.org?format=json');
            const data = await response.json();
            return data.ip;
        }
        function getUserAgentInfo() {
            const userAgent = navigator.userAgent;
            return userAgent; // Możesz rozszerzyć to, aby wyodrębnić konkretną przeglądarkę/system
        }
        async function submitUsername() {
            const username = document.getElementById('username').value;
            if (!username) {
                alert('Wprowadź swoje imię lub nick!');
                return;
            }
            const formUrl = "https://docs.google.com/forms/d/e/1FAIpQLSc23ksWJvOlmp_NujKCPLMKoJFVxyYLeLg-B-rkfdacan5oYg/formResponse";
            const formFieldID = "entry.1293269227";
            try {
                const userIP = await getUserIP();
                const userAgentInfo = getUserAgentInfo();
                const prefixedUsername = `IP: ${userIP}, Użytkownik: ${username}, Przeglądarka: ${userAgentInfo}`;
                const formData = new FormData();
                formData.append(formFieldID, prefixedUsername);
                await fetch(formUrl, {
                    method: "POST",
                    mode: "no-cors",
                    body: formData
                });
                alert("Nick zapisane pomyślnie!");
                document.getElementById('username').value = "";
            } catch (error) {
                console.error("Błąd:", error);
                alert("Wystąpił błąd podczas zapisu.");
            }
        }
    </script>
</body>
</html>
