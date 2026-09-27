# Advanced Html Designer

Visual HTML table designer for Lazarus / Free Pascal — as a ready-to-use
Windows program and as reusable Lazarus components.

*Nederlandstalige uitleg: zie [onderaan](#nederlands).*

![Advanced Html Designer](docs/screenshot.png)

## Features

- Design an HTML table on a page with rulers in mm
- Add, delete, merge and unmerge rows, columns and cells
- Cell formatting: bold, italic, underline, alignment, colours, font size, borders, rounded corners
- Images in cells (left / centre / right, size), text and image hyperlinks
- Free-floating **text blocks** anywhere on the page, positioned with the mouse or to the millimetre
- Export as a complete HTML document or as table-only HTML, preview in your browser
- Save and load designs (`.htd`)
- User interface in **Dutch, English, French and German**, with a built-in translation editor
- Built-in help in all four languages

## Download (Windows)

Download the latest zip from the [Releases](../../releases) page, unzip it
anywhere and run `Advanced Html Designer.exe`. No installation needed.
Keep `talen.lng` and the `help` folder next to the program.

## Building from source

Requirements: [Lazarus](https://www.lazarus-ide.org/) 4.x with Free Pascal 3.2.2 or newer.

```
git clone https://github.com/willem750-win/AdvancedHtmlDesigner.git
```

This repository contains two Lazarus packages and a demo program:

| Folder | Package / project | Description |
|---|---|---|
| `core/` | `tabledesignerhtml.lpk` (TableDesignerHtml) | Base component `THtmlTableDesigner` |
| `advanced/` | `htmltabledesigner_advanced.lpk` | `THtmlTableDesignerAdvanced` with floating toolbox, translations and settings |
| `advanced/project/` | `project1.lpi` | The **Advanced Html Designer** program |

Steps:

1. In Lazarus, open `core/tabledesignerhtml.lpk` and choose *Use > Install*.
2. Open `advanced/htmltabledesigner_advanced.lpk` and choose *Use > Install*.
   Lazarus rebuilds the IDE; the components appear on the **JanWilly** palette tab.
3. For the demo program, also install the **ExpandPanels** package
   (it provides the roll-out panel `TMyRollOut`).
4. Open `advanced/project/project1.lpi` and build it.

## License

[MIT](LICENSE) © 2026 Willy Jansen

---

## Nederlands

**Advanced Html Designer** is een visuele ontwerper voor HTML-tabellen, gemaakt
met Lazarus / Free Pascal. Het bestaat uit een kant-en-klaar Windows-programma
en herbruikbare Lazarus-componenten.

- **Gewoon gebruiken:** download de zip bij [Releases](../../releases), pak hem
  uit en start `Advanced Html Designer.exe`. Laat `talen.lng` en de map `help`
  naast het programma staan.
- **Zelf compileren:** installeer in Lazarus eerst `core/tabledesignerhtml.lpk`,
  daarna `advanced/htmltabledesigner_advanced.lpk`. Voor het voorbeeldprogramma
  heb je ook het pakket **ExpandPanels** nodig. Open dan
  `advanced/project/project1.lpi`.
- De help (in het programma via de Help-knop) is beschikbaar in het Nederlands,
  Engels, Frans en Duits.
