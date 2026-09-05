# Lumina System Manager

Moderní, lehký a rychlý nástroj pro diagnostiku, správu a údržbu operačního systému Windows. 

Lumina kombinuje výkon a nízkou spotřebu systémových prostředků nativního C++ jádra s moderním tmavým uživatelským rozhraním postaveným na technologii Microsoft WebView2.

---

## Rychlé stažení

Nejnovější verzi instalačního balíčku stáhnete přímo zde:

* **[Stáhnout LuminaSetup.exe (Poslední vydání v1.2.5)](https://github.com/Petr-Harnach/lumina-releases/releases/latest/download/LuminaSetup.exe)**

---

## Hlavní funkce

### 1. Živá telemetrie a monitoring hardwaru
* Sledování vytížení procesoru (CPU), grafické karty (GPU), operační paměti (RAM) a pevných disků v reálném čase.
* Průběžné měření provozních teplot procesoru i grafické karty s adaptivním barevným varováním při přehřívání.
* Přehled o síťovém toku (stahování/odesílání dat) a podrobné hardwarové specifikace počítače.

### 2. Správa aktualizací software a ovladačů
* Automatické vyhledávání dostupných aktualizací pro instalované aplikace i hardwarové ovladače.
* Možnost jednorázové aktualizace nebo zařazení konkrétních položek na seznam ignorovaných.

### 3. Čištění a optimalizace systému
* Bezpečné odstraňování dočasných souborů, systémového odpadu a mezipaměti prostřednictvím dedikované služby na pozadí s právy správce.
* Rychlé systémové akce:
  * Vyčištění vyrovnávací paměti DNS (DNS flush).
  * Oprava poškozené mezipaměti ikon na ploše (Icon cache rebuild).
  * Spuštění kontroly integrity chráněných systémových souborů (SFC scan).

### 4. Automatické aktualizace (Self-Updater)
* Integrovaný systém tiché kontroly nových verzí přes GitHub.
* Automatické stažení a bezpečná výměna binárních souborů na pozadí bez nutnosti ruční reinstalace.

---

## Technická architektura

Lumina je navržena s důrazem na maximální stabilitu, bezpečnost a minimální zatížení procesoru i paměti:

* **Jádro aplikace (C++20 & Win32 API):** Přímá komunikace s Windows API, Performance Counters (PDH) a DirectX/DXGI rozhraním.
* **Uživatelské rozhraní (Microsoft WebView2):** Moderní rozhraní s plynulými přechody, rychlou odezvou a nízkou režií.
* **Systémová služba (LuminaService):** Zajišťuje bezpečné provádění údržbových úkonů na pozadí bez nutnosti spouštět celé grafické rozhraní s trvalými administrátorskými právy.
* **Instalační modul (LuminaSetup):** Podpora čisté instalace, automatické konfigurace služby i offline rozbalení.

---

## Systémové požadavky

* **Operační systém:** Windows 10 / Windows 11 (64-bit)
* **Závislosti:** Microsoft Edge WebView2 Runtime (ve Windows 11 výchozí součást systému; ve Windows 10 se v případě potřeby doinstaluje automaticky)
* **Oprávnění:** Pro instalaci a správu služeb jsou vyžadována standardní administrátorská práva.

---

## Instalace

1. Stáhněte soubor **`LuminaSetup.exe`**.
2. Spusťte instalátor a potvrďte instalaci.
3. Instalátor automaticky nakopíruje potřebné soubory, zaregistruje systémovou službu a vytvoří zástupce na ploše i v nabídce Start.
