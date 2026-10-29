# Lumina System Manager

Moderní, lehký a bleskurychlý nástroj pro diagnostiku, správu a údržbu operačních systémů **macOS**, **Windows** a **Linux**.

Lumina kombinuje výkon a nízkou spotřebu systémových prostředků nativního C++ jádra s moderním tmavým glassmorphic rozhraním postaveným na technologiích Apple WebKit / Cocoa (macOS), Microsoft WebView2 (Windows) a WebKitGTK (Linux).

---

## 🚀 Rychlé stažení & Instalace (Verze v1.4.10)

### 🪟 Pro Windows (10 & 11) – Plná podpora
Nejnovější verzi moderního grafického instalátoru stáhnete přímo zde:
* **[Stáhnout LuminaSetup.exe (Vydání v1.4.10)](https://github.com/Petr-Harnach/lumina-releases/raw/main/LuminaSetup.exe)**
* **[Stáhnout jako ZIP archiv (LuminaSetup.zip)](https://github.com/Petr-Harnach/lumina-releases/raw/main/LuminaSetup.zip)** *(doporučeno, pokud vám Microsoft Edge / Chrome blokuje přímé stažení `.exe`)*

1. Stáhněte a spusťte `LuminaSetup.exe`.
2. Zvolte instalační složku a potvrďte instalaci.
3. Instalátor automaticky nakonfiguruje systémovou službu na pozadí a vytvoří zástupce na ploše i v nabídce Start.

---

### 🍏 Pro macOS (Apple Silicon M1/M2/M3/M4/M5 & Intel) – Plná podpora
* **[Stáhnout Lumina-macOS.zip (Vydání v1.4.10)](https://github.com/Petr-Harnach/lumina-releases/raw/main/Lumina-macOS.zip)**

1. Stáhněte a rozbalte balíček `Lumina-macOS.zip`.
2. Přesuňte aplikaci `Lumina.app` do složky `/Applications`.
3. Spusťte Lumina přímo z Launchpadu, Spotlightu nebo složky Aplikace.
   > 💡 **Tip při prvním spuštění (macOS Gatekeeper):**  
   > Pokud macOS zobrazí hlášení, že vývojáře nelze ověřit, stačí v **Nastavení systému ➔ Soukromí a zabezpečení** kliknout dole na **„Přesto otevřít“**, případně v Terminálu zadat: `xattr -cr /Applications/Lumina.app`.

---

### 🐧 Pro Linux (Ubuntu, Debian, Fedora, Arch) – Experimentální
> ⚠️ **Upozornění:** Verze pro Linux je v současnosti v experimentálním stavu a slouží především pro testování a vývojářské účely. Není garantována plná stabilita.

Instalaci provedete příkazem v terminálu:

```bash
curl -sSL https://raw.githubusercontent.com/Petr-Harnach/lumina-releases/main/install-linux.sh | bash
```

---

## 💎 Klíčové funkce a novinky ve verzi v1.4.10
* **Zabezpečení a uzamčení vývojářských nástrojů (macOS):** Vývojářské rozhraní WebKit Web Inspector (DevTools) a kontextová nabídka pravého tlačítka myši jsou v produkčním režimu pro běžné uživatele striktně zakázány. Inspekce je povolena výhradně při spuštění aplikace s vývojářským přepínačem `--dev` nebo `--debug`.
* **Nativní detekce aktualizací Mac App Store aplikací:** Přímé čtení interní cache databáze systémového démona `appstoreagent` (`storeSystem.db`) přes vestavěnou SQLite knihovnu. Lumina spolehlivě detekuje veškeré čekající aktualizace z Mac App Storu včetně názvu aplikace, nainstalované vs. dostupné verze, poznámek k vydání a přímého tlačítka pro aktualizaci.
* **Rozšířená správa položek po spuštění a úloh na pozadí (macOS):** Kompletní synchronizace se systémovým nastavením *Aktivita aplikací na pozadí*, automatický překlad technických identifikátorů na čitelné názvy aplikací a živá detekce běžících procesů na pozadí s vizuálním indikátorem (`🟢 Běží na pozadí` / `⚪ Neběží na pozadí`).
* **Přímé propojení s obchodem aplikací (Mac App Store):** Jedním kliknutím v sekci *Aktualizace softwaru* otevře nativní záložku aktualizací v Mac App Storu.
* **Správce vývojářských služeb na macOS:** Plná podpora a ovládání běhu kontejnerových enginů (Docker), relačních databází (PostgreSQL, MySQL), vestavěného webového serveru Apache HTTP a cache pamětí (Redis).
* **Plnohodnotná správa proměnných prostředí:** Načítání a správa uživatelských i systémových proměnných prostředí s okamžitou perzistencí do systémového profilu i subsystému launchd.
* **Živá diagnostická konzole se streamovaným výstupem:** Terminálový výstup diagnostických síťových testů (Ping, Traceroute, DNS) v reálném čase.
* **Přehled hardwarových zařízení:** Detekce zvukových zařízení, displejů, kamerových modulů a periferií.
* **Nativní lokalizace a průvodce transparentním čištěním:** Kompletně přizpůsobené texty a vysvětlení pro platformu macOS ($TMPDIR, ~/Library/Caches, DerivedData, systémové protokoly).
* **Nativní přetahování okna záhlavím (macOS Titlebar Drag):** Plynulé přemisťování okna tažením za záhlaví s automatickým ukládáním pozice a rozměrů mezi spuštěními.
* **Plnohodnotný Správce po spuštění na macOS:** Skutečné vypínání a zapínání aplikací spouštěných po přihlášení (Login Items) a služeb na pozadí (LaunchAgents) s okamžitou deaktivací a spolehlivou perzistencí po restartu.
* **Hloubkový odinstalátor aplikací:** Bezpečný přesun odinstalovávaných aplikací do systémového Koše a automatické vyhledání a odstranění zbytků z uživatelské knihovny.
* **Responzivní odznak aktualizací v boční liště:** Elegantní kompaktní pulzující notifikační tečka pro úzké zobrazení a pill badge v plné šířce.
* **Správa a online ověřování grafických ovladačů:** Tříúrovňové srovnání verzí (nainstalováno vs. Windows Update WHQL vs. oficiální cloud výrobce) s možností přímého stažení instalačních balíčků (.exe).
* **Blesková analýza disku:** Extrémně rychlý paralelní skener úložného prostoru s post-order stromovou agregací.
* **Smart Disk Advisor:** Inteligentní transparentní rádce pro úsporu místa a bezpečná recyklace instalačních souborů do systémového Koše.
* **Kompletní dvojjazyčnost:** Stoprocentní podpora pro češtinu a angličtinu napříč celou aplikací.
* **Amethyst Dark Glassmorphism:** Čistý, minimalistický design laděný do ametystové fialové bez rušivých prvků.
