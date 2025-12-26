<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Derin Odak - Mobile Fix</title>
    
    <script src="https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js"></script>
    <script src="https://www.gstatic.com/firebasejs/8.10.1/firebase-database.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.5.1/dist/confetti.browser.min.js"></script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;800&display=swap" rel="stylesheet">
    
    <style>
        :root { --bg: #0f172a; --card: #1e293b; --text: #f8fafc; --accent: #38bdf8; --border: #334155; }
        body { font-family: 'Plus Jakarta Sans', sans-serif; background: var(--bg); color: var(--text); display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; overflow: hidden; }
        .app-card { background: var(--card); padding: 1.5rem; border-radius: 35px; box-shadow: 0 20px 40px rgba(0,0,0,0.4); width: 90%; max-width: 340px; text-align: center; border: 1px solid var(--border); }
        .hidden { display: none !important; }
        .main-btn { background: var(--accent); color: #fff; padding: 16px; border-radius: 18px; font-weight: 800; width: 100%; margin-top: 10px; border:none; cursor:pointer; font-size: 1rem; }
        .main-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .logo-circle { width: 50px; height: 50px; background: linear-gradient(135deg, #0284c7, #38bdf8); border-radius: 50%; margin: 0 auto 10px; display: flex; align-items: center; justify-content: center; font-weight: 900; color: white; }
        .stats-row { display: flex; justify-content: space-around; margin-bottom: 15px; background: rgba(255,255,255,0.03); padding: 10px; border-radius: 15px; }
        .stat-val { display: block; font-size: 1rem; color: var(--accent); font-weight: 800; }
        input { width: 100%; padding: 14px; border-radius: 15px; border: 2px solid var(--border); background: var(--bg); color: var(--text); margin: 10px 0; box-sizing: border-box; font-size: 16px; /* Mobil zoom önleyici */ }
        .timer-text { font-size: 4rem; font-weight: 900; color: var(--accent); margin: 10px 0; }
    </style>
</head>
<body>

    <div class="app-card">
        <div id="statusArea">
            <div class="logo-circle">D</div>
            <div class="stats-row">
                <div>SERİ 🔥 <span id="streakVal" class="stat-val">0</span></div>
                <div>HEDEF ✅ <span id="totalVal" class="stat-val">0</span></div>
                <div>PUAN ✨ <span id="xpVal" class="stat-val">0</span></div>
            </div>
        </div>

        <div id="loginScreen">
            <p id="msg" style="font-size: 0.8rem; color: var(--accent);">Buluta bağlanılıyor...</p>
            <input type="text" id="userNameInput" placeholder="Adını yaz knk...">
            <button class="main-btn" id="connectBtn" onclick="connect()">BAĞLAN</button>
        </div>

        <div id="mainScreen" class="hidden">
            <h3 id="welcomeText"></h3>
            <button class="main-btn" onclick="showScreen('goalScreen')">ODAKLAN</button>
            <button class="main-btn" onclick="logout()" style="background:transparent; color: #ef4444; font-size:0.7rem;">Çıkış Yap</button>
        </div>

        <div id="goalScreen" class="hidden">
            <input type="text" id="targetInput" placeholder="Neye odaklanıyoruz?">
            <button class="main-btn" onclick="startFocus()">BAŞLAT</button>
        </div>

        <div id="focusScreen" class="hidden">
            <h1 class="timer-text" id="timer">25:00</h1>
            <button class="main-btn" onclick="finishGoal()">BİTİRDİM!</button>
        </div>
    </div>

    <script>
        const firebaseConfig = {
            apiKey: "AIzaSyD4vRKdlx60gK85MhnXOgs4UyoPnDkfrK4",
            authDomain: "derin-odak.firebaseapp.com",
            databaseURL: "https://derin-odak-default-rtdb.europe-west1.firebasedatabase.app/",
            projectId: "derin-odak",
            storageBucket: "derin-odak.firebasestorage.app",
            messagingSenderId: "898035634670",
            appId: "1:898035634670:web:6f61ba8cdb24d6422e3eff"
        };

        // Firebase Güvenli Başlatma
        try {
            if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
            var database = firebase.database();
            document.getElementById('msg').innerText = "Bulut Hazır ✅";
        } catch (e) {
            alert("Firebase yüklenemedi: " + e.message);
        }

        let userData = { xp: 0, totalGoals: 0, streak: 0, name: "" };

        // Sayfa açıldığında hafızada isim var mı bak
        window.onload = () => {
            const saved = localStorage.getItem('derinOdakUser');
            if(saved) {
                document.getElementById('userNameInput').value = saved;
                connect(saved);
            }
        };

        function connect(autoName = null) {
            const n = autoName || document.getElementById('userNameInput').value.trim().toLowerCase();
            if(!n) return;

            const btn = document.getElementById('connectBtn');
            btn.disabled = true;
            btn.innerText = "BAĞLANIYOR...";

            database.ref('users/' + n).on('value', (snapshot) => {
                const data = snapshot.val();
                if(data) userData = data;
                else {
                    userData.name = n;
                    save();
                }
                localStorage.setItem('derinOdakUser', n);
                updateUI();
                showScreen('mainScreen');
            }, (err) => {
                alert("Hata: " + err.message);
                btn.disabled = false;
                btn.innerText = "TEKRAR DENE";
            });
        }

        function save() {
            if(userData.name) database.ref('users/' + userData.name).set(userData);
        }

        function updateUI() {
            document.getElementById('welcomeText').innerText = "Selam, " + userData.name.toUpperCase();
            document.getElementById('xpVal').innerText = userData.xp;
            document.getElementById('totalVal').innerText = userData.totalGoals;
            document.getElementById('streakVal').innerText = userData.streak;
        }

        function finishGoal() {
            confetti({ particleCount: 100, spread: 70, origin: { y: 0.6 } });
            userData.xp += 100; userData.totalGoals += 1; userData.streak += 1;
            save();
            showScreen('mainScreen');
        }

        function startFocus() {
            if(!document.getElementById('targetInput').value) return;
            showScreen('focusScreen');
            let t = 25 * 60;
            const i = setInterval(() => {
                let m=Math.floor(t/60), s=t%60;
                document.getElementById('timer').innerText=(m<10?"0"+m:m)+":"+(s<10?"0"+s:s);
                if(--
