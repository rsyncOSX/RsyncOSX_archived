## RsyncOSX

![](icon/rsyncosx.png)

Bitte [lesen Sie das Changelog](https://rsyncosx.github.io/Changelog). Wenn Sie Änderungen diskutieren oder Fehler melden möchten, erstellen Sie bitte ein [Problem](https://github.com/rsyncOSX/RsyncOSX/issues).

**Lesen Sie über den --delete Parameter** (unten) zum rsync **vor** unter Verwendung von rsync und RsyncOSX.

RsyncOSX ist eine GUI über dem Kommandozeilenwerkzeug `rsync`. Rsync ist ein dateibasiertes Synchronisations- und Sicherungswerkzeug. Es gibt keine individuelle Lösung für das Backup-Archiv. Sie können die Verwendung von RsyncOSX (und rsync) jederzeit beenden und haben trotzdem Zugriff auf alle synchronisierten Dateien.

RsyncOSX wird mit Unterstützung für **macOS El Capitan Version 10.11 - macOS Catalina Version 10.15** kompiliert. Die Anwendung wird in Swift 5 unter Verwendung von Xcode 11 implementiert. RsyncOSX ist nicht auf Binärdistributionen von Dritten angewiesen. Es ist jedoch [ein Dritter Quellcode](https://github.com/swiftsocket/SwiftSocket) vorhanden, um auf TCP-Verbindungen zu überprüfen.

Geplante Aufgaben werden innerhalb von RsyncOSX hinzugefügt und gelöscht. Die Ausführung der geplanten Aufgaben erfolgt über die [Menü-App](https://github.com/rsyncOSX/RsyncOSXsched).

RsyncOSX hängt davon ab, dass [weniger Passwörter für entfernte Server einrichtet.](https://rsyncosx.github.io/Remotelogins) Sowohl ssh-keys als auch rsync-Daemon Setup sind aktiviert. Es wird empfohlen, ssh-keys zu verwenden.

### Unterschreiben und notarisieren

Die App ist mit meinem Apple-ID-Entwicklerzertifikat unterzeichnet und [von Apple notariell](https://support.apple.com/en-us/HT202491) zertifiziert. Siehe [Unterschrift und Notarisierung](https://rsyncosx.github.io/Notarized) für Infos. Unterschreiben und Notarisieren ist erforderlich, um auf macOS Catalina laufen zu können.

### Lokalisierung

[RsyncOSX spricht neue Sprachen](https://rsyncosx.github.io/Localization). RsyncOSX ist lokalisiert auf:
- Chinesisch (vereinfacht) - von [StringKe](https://github.com/StringKe)
- Deutsch - von [Andre](https://github.com/andre68723) (ist abgeschlossen, aber noch nicht freigegeben)
- Norwegisch - von mir
- Englisch - von mir, der Basissprache von RsyncOSX

Die Übersetzung erfolgt durch Verwendung von [Crowdin](https://crowdin.com/project/rsyncosx) zur Übersetzung der xliff-Dateien, die bei der Übersetzung in Xcode importiert werden. [Crowdin ist kostenlos für Open-Source-Projekte](https://crowdin.com/page/open-source-project-setup-request).

Die deutsche Übersetzung ist in Arbeit. Auch die chinesischen (vereinfachten) und norwegischen Übersetzungen werden aktualisiert. Eine neue aktualisierte Version wird im Januar 2020 verfügbar sein.

### Version von rsync

RsyncOSX wird nur mit den rsync-Versionen 2.6.9, 3.1.2 und 3.1.3 überprüft. Andere Versionen von rsync werden funktionieren, aber Zahlen über übertragene Dateien sind nicht in Logs gesetzt. Es wird empfohlen [](https://rsyncosx.github.io/Install) die neueste Version von rsync zu installieren.

Wenn Sie nur auf der Suche nach einer Lagerversion von rsync sind (Version 2.6. ) und nur Daten mit lokalen angehängten Festplatten oder entfernten Servern synchronisieren [Im Mac App Store](https://itunes.apple.com/us/app/rsyncgui/id1449707783?l=nb&ls=1&mt=12) ist eine kleinere Version (RsynGUI) verfügbar. RsyncGUI does **not** support snapshots or scheduling task.

### Einige Worte über RsyncOSX

RsyncOSX ist kein einfach zu bedienendes Synchronisations- und Sicherungswerkzeug. Der Hauptzweck besteht darin, die Verwendung von `rsync` zu unterstützen und zu vereinfachen, um Dateien auf Ihrem Mac mit entfernten FreeBSD- und Linux-Servern zu synchronisieren. Und natürlich stellen Sie Dateien von diesen entfernten Servern wieder her.

Das UI kann für Benutzer, die nicht wissen, `rsync`, schwer oder komplex zu verstehen. Es wird nicht benötigt `rsync` zu kennen, aber es wird die Verwendung und das Verständnis von RsyncOSX erleichtern. Aber es ist möglich, RsyncOSX zu verwenden, indem Sie einfach einen Quell- und einen Remote-Backup-Katalog mit Standardparametern hinzufügen.

RsyncOSX unterstützt Synchronisierung und Schnappschüsse von Dateien.

Wenn Ihr Plan es ist, RsyncOSX als Ihr Hauptwerkzeug für die Sicherung von Dateien zu verwenden, untersuchen Sie bitte die Grenzen und verstehen Sie es. RsyncOSX ist ziemlich mächtig, aber es ist vielleicht nicht das primäre Sicherungswerkzeug für den durchschnittlichen Benutzer von macOS.

Es gibt eine [kurze Einführung in RsyncOSX](https://rsyncosx.github.io/Intro) und [weitere Dokumentation von RsyncOSX](https://rsyncosx.github.io/AboutRsyncOSX).

### Der Parameter --delete
```
Vorsicht vor RsyncOSX und dem `--delete` Parameter. Der `--delete` ist ein Standardparameter.
Der Parameter weist rsync an, um die Quell- und Zieldaten synchronisieren zu lassen (sync).
Der Parameter weist rsync an, alle Dateien im Ziel zu löschen, die nicht in der Quelle
vorhanden sind.

Jedes Mal, wenn Sie RsyncOSX eine neue Aufgabe hinzufügen, führen Sie eine Schätzung aus (--dry-run) und überprüfen
das Ergebnis, bevor Sie einen echten Run durchführen. Wenn Sie zufällig einen leeren Katalog als Quelle setzen
RsyncOSX (rsync) löscht alle Dateien im Ziel.

Um gelöschte Dateien zu speichern und zu ändern, verwenden Sie entweder Snapshots (https://rsyncosx.github.io/Snapshots)
oder die `--backup` Funktion (https://rsyncosx.github.io/Parameters).

Der Parameter --delete und andere Standardparameter können gelöscht werden, wenn gewünscht.
```
### Hauptansicht

Die Hauptansicht von RsyncOSX. ![](images/main1.png) Bereiten Sie sich auf die Synchronisierung der Aufgaben vor. ![](images/main2.png)

### Eine Sandbox Version

[Es gibt auch eine kleinere Version, RsyncGUI](https://itunes.apple.com/us/app/rsyncgui/id1449707783?l=nb&ls=1&mt=12) von RsyncOSX im Apple Mac App Store. Siehe [Changelog](https://rsyncosx.github.io/RsyncGUIChangelog). RsyncGUI verwendet die Standardversion von rsync in macOS und RsyncGUI unterstützt nur die Synchronisierung der Aufgabe (keine Snapshots).

### Über Fehler und Absturz?

Was passiert [, wenn Fehler bei der Ausführung von Aufgaben in RsyncOSX auftreten?](https://rsyncosx.github.io/Bugs). Fehler zu bekämpfen ist schwierig. Ich bin nicht in der Lage, RsyncOSX auf alle möglichen Benutzerinteraktionen und Verwendungsmöglichkeiten zu testen. Gelegentlich entdecke ich neue Fehler. Aber ich brauche auch Unterstützung von anderen Benutzern, die Fehler oder nicht erwartete Ergebnisse entdecken. Wenn Sie einen Fehler entdecken, verwenden Sie bitte die [Tickets](https://github.com/rsyncOSX/RsyncOSX/issues) und melden Sie ihn.

### Über das Wiederherstellen von Dateien in einem Katalog zur temporären Wiederherstellung

Wenn Sie **** von der `Fernbedienung` auf die `Quelle wiederherstellen`, einige Dateien in der Quelle könnten gelöscht werden. Dies ist darauf zurückzuführen, wie rsync im `synchronisieren` Modus funktioniert. Als Vorsichtsmaßnahme leistet **niemals** eine Wiederherstellung direkt vom `Remote` auf die `Quelle`, immer eine Wiederherstellung eines temporären Restaurierungskatalogs durchführen.

### Anwendungssymbol

Das Anwendungssymbol wird von [Zsolt Sándor](https://github.com/graphis) erstellt. Alle Rechte sind Zsolt Sándor vorbehalten.

### Verwendung von RsyncOSX - YouTube-Videos

Es gibt zwei kurze YouTube-Videos von RsyncOSX:

- [Lädt RsyncOSX](https://youtu.be/MrT8NzdF9dE) und installiert es
  - das Video zeigt auch, wie man die beiden lokalen SSH-Zertifikate für weniger Passwort-Logins zum entfernten Server erstellt
- [das erste Backup hinzufügen und ausführen](https://youtu.be/8oe1lKgiDx8)

#### SwiftLint und SwiftFormat

Ich benutze [SwiftLint](https://github.com/realm/SwiftLint) als Werkzeug, um lesbaren Code zu schreiben. Ich benutze auch die [Schnell-Skripte](https://github.com/PaulTaykalo/swift-scripts) von Paul Taykalo, um nicht verwendeten Code zu finden und zu löschen. Ein weiteres Werkzeug ist [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) um schnellen Code zu formatieren.

Es gibt etwa 130 Klassen mit 14.900 Codezeilen in RsyncOSX.

### Kompilieren

Um den Code zu kompilieren, installieren Sie Xcode und öffnen Sie die RsyncOSX Projektdatei. Bevor Sie kompilieren, öffnen Sie in Xcode die `RsyncOSX/General` Preference Seite und ersetzen Sie durch Ihre eigenen Zugangsdaten in `Signing`oder deaktivieren Sie Signieren.

Es gibt zwei Möglichkeiten, entweder `make` zu verwenden oder Xcode zu kompilieren. `make release` kompiliert die `RsyncOSX.app` und `make dmg` erzeugt eine dmg-Datei, die freigegeben wird.  Die Erstellung von dmg-Dateien erfolgt durch das [andreyvit](https://github.com/andreyvit/create-dmg) Skript zum Erstellen von dmg und [Syncthing-macos](https://github.com/syncthing/syncthing-macos) Setup.

### XCTest

XCTest Konfigurationen befinden sich in der [-Entwicklung](https://github.com/rsyncOSX/RsyncOSX/blob/master/XCTestconfiguration/XCTest.md).
