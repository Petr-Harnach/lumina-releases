# Lumina System Manager

Moderní, lehký a bleskurychlý nástroj pro diagnostiku, správu a údržbu operačních systémů **macOS**, **Windows** a **Linux**.

Lumina kombinuje výkon a nízkou spotřebu systémových prostředků nativního C++ jádra s moderním tmavým glassmorphic rozhraním postaveným na technologiích Apple WebKit / Cocoa (macOS), Microsoft WebView2 (Windows) a WebKitGTK (Linux).

---

## 🚀 Rychlé stažení & Instalace

### 🍏 Pro macOS (Apple Silicon M1/M2/M3/M4/M5 & Intel) – Plná podpora
* **[Stáhnout Lumina-macOS.zip (Vydání v1.4.0)](https://github.com/Petr-Harnach/lumina-releases/releases/latest/download/Lumina-macOS.zip)**

1. Stáhněte a rozbalte balíček `Lumina-macOS.zip`.
2. Přesuňte aplikaci `Lumina.app` do složky `/Applications`.
3. Spusťte Lumina přímo z Launchpadu nebo Spotlightu.

---

### 🪟 Pro Windows (10 & 11) – Plná podpora
Nejnovější verzi moderního grafického instalátoru stáhnete přímo zde:
* **[Stáhnout LuminaSetup.exe (Vydání v1.4.0)](https://github.com/Petr-Harnach/lumina-releases/releases/latest/download/LuminaSetup.exe)**

1. Stáhněte a spusťte `LuminaSetup.exe`.
2. Zvolte instalační složku a potvrďte instalaci.
3. Instalátor automaticky nakonfiguruje systémovou službu na pozadí a vytvoří zástupce na ploše i v nabídce Start.

---

### 🐧 Pro Linux (Ubuntu, Debian, Fedora, Arch) – Experimentální
> ⚠️ **Upozornění:** Verze pro Linux je v současnosti v experimentálním stavu a slouží především pro testování a vývojářské účely. Není garantována plná stabilita.

Instalaci provedete příkazem v terminálu:

```bash
curl -sSL https://raw.githubusercontent.com/Petr-Harnach/lumina-releases/main/install-linux.sh | bash
```

---

## 💎 Klíčové funkce verze v1.4.0
* **Nativní podpora macOS:** Ultralehký Cocoa / AppKit bundle (~600 KB), Metal GPU a Mach telemetrie, správa systémových aktualizací Apple Siliconu, Sleepimage & Swap advisor.
* **Blesková analýza disku:** Extrémně rychlý paralelní skener úložného prostoru s post-order stromovou agregací.
* **Smart Disk Advisor:** Inteligentní transparentní rádce pro úsporu místa a bezpečná recyklace instalačních souborů do systémového Koše.
* **Kompletní dvojjazyčnost:** Stoprocentní podpora pro češtinu a angličtinu napříč celou aplikací.
* **Amethyst Dark Glassmorphism:** Čistý, minimalistický design laděný do ametystové fialové bez rušivých prvků.
