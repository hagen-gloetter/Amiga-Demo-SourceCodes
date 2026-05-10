# Amiga Demo SourceCodes

## Sprache / Language

[Deutsch](#deutsch) | [English](#english)

## Deutsch

### Kurzüberblick
Dieses Repository enthält meine Amiga-Demos und ein Spiel als Quellcode, die ich in Motorola-680x0-Assembler programmiert habe.

- Top-Level-Ordner unter `Sources`: 51

### Demo-Module und Effekte

**8Way-Scroller** - 8-Wege-Scrollsystem (Richtungswechsel, Timing, Engine).

**Addtro** - Addtro-/Intro-Code mit Effektsteuerung und Assets.

**Argon-ShootEmUp-Game** - Shoot-'em-up-Spiel ARGON: Spiellogik, Leveltabellen, Level-Editor.

**Ball** - Routinen für Kreis-/Ball-Effekte mit Tabellen.

**Ball-Scroller** - Laufschrift, die auf einen springenden Ball gemappt ist.

**Beast-Scroller** - "Shadow of the Beast"-Scroller für Parallax-Scroll-Effekte.

**Big-Scroller** - Extrem große Laufschrift.

**Bounce** - Einfache Bounce-Demos mit Bewegungslogik.

**BrushZoom** - Zoom-Effekte für Brushes/Sprites.

**Circles** - Kreis-Testprogramme als Basis für spätere Effektbausteine.

**Converter** - Konverter-Routinen zum Umformen von Datenformaten für die Demo-Pipeline.

**Copper-Animation** - Copper-gesteuerte Animationen mit Farbwechseln pro Rasterzeile.

**Copper-Sinus-Scroller** - Sinus-Copper-Scroller.

**CPUFill** - Tests zum schnellen Füllen von Bildspeicher mit CPU-/Blitter-Verfahren.

**Cracktro** - Cracktro-Code mit Introaufbau und Effekten; komplettes Intro mit Musik unter 9 KB.

**Demands** - Kleinere Effekt-/Bildschirmtests für Demo-Bestandteile.

**Dot-Scroller** - Dot-Scroller mit Text/Grafik als Punktmatrix.

**DotFlag** - Dot-Flag-Effekte mit punktbasierter Flagge.

**DS9-Intro** - Code und Assets für ein DS9-BBS-Intro; komplettes Intro mit Musik unter 9 KB.

**FunkyBall** - Varianten eines Ball-Effekts.

**FW-Addtro** - FastWay-Addtro-Variante; komplettes Intro mit Musik unter 9 KB.

**Gurutro** - Guru-Meditation-Intro.

**IntelOut** - Intro-/Outro für den IntelOutside-Effekt.

**Intro1-Motion-Intro** - Erstes Motion-Intro.

**Intro2-JumpingChessfield** - Jumping-Chessfield-Effekt.

**Intro3-Raster-Demo** - Raster-Dance-Demo mit Copper-Effekten.

**Intro4-Motion-Intro-4** - Motion-Intro 4.

**Intro5-Motion-Twist-Intro** - Motion-Twist-Intro.

**Intro6-Motion-Jump-Scroller** - Intro mit Jump-Scroller.

**Lines** - Linien-Effekte inklusive Laser-Varianten.

**Liquid** - Liquid-/Wobble-ähnliche Verformungseffekte mit tabellengesteuerter Deformation.

**Logo-Waver-Wobble** - Kombinierte Logo-Waver-/Wobble-Effekte mit umfangreichen Tabellen.

**Logo-Wobble** - Logo-Wobble-Effekte in vielen Versionen.

**Logo-Wobble-2-AGA** - AGA-spezifische Logo-Wobble-Varianten mit angepassten Datenformaten.

**Makros** - Zentrale Makros und wiederverwendbare Includes als Grundlage vieler Projekte.

**No-Aga-No-Fun** - Effektroutinen rund um AGA-/Nicht-AGA-Abhängigkeiten.

**Parallax-Scroller** - Ressourcen für Parallax-Scroller.

**Perspektivisches-Raster** - Perspektivische Rasterdarstellung mit Tiefe und Projektionswirkung.

**Plasma** - Plasma-Effekte mit mehreren Parametern.

**Quark** - Intro für die Quark-Demogruppe.

**Sing-Scroller** - Sing-Scroller mit Font-Konvertern.

**Sinus-Scroller** - Sinus-Scroller.

**Spiel-8way-Scroller** - Gametauglicher 8-Way-Scroller.

**Spirale-Twist** - Spiral-/Twist-Effekte mit Sinustabellen.

**TainerMenu** - Trainer-Menü-Code.

**Tests** - Techniktests (Bresenham, Sprites, Modi, Zahlenformate).

**Tunes** - Soundtracker-Dateien für Demos.

**TypeWriter** - Typewriter-Effekt.

**Zoom-Scroller** - Zoom-Scroller mit Sinus-Tabellen.

**Zoom-Scroller2** - Zweite Zoom-Scroller-Generation mit überarbeiteten Tabellen.

### Hinweise zur Repository-Struktur
- Sehr viele Versionsstände pro Effekt: Lern- und Experimentierverlauf statt konsolidierter Releases.
- Asset-Dateien ohne Endung sind Teil der Effekt-Pipelines.
- Für langfristige Wartbarkeit wären Vereinheitlichung und Stabilisierung pro Effekt sinnvoll.

## English

### Overview
This repository contains my Amiga demos and one game as source code, all written in Motorola 680x0 assembly.

- Top-level folders inside `Sources`: 51

### Demo Modules and Effects

**8Way-Scroller** - 8-direction scrolling system (direction changes, timing, engine).

**Addtro** - Addtro/intro code with effect control and assets.

**Argon-ShootEmUp-Game** - ARGON shoot-'em-up game: game logic, level tables, level editor.

**Ball** - Circle/ball effect routines with lookup tables.

**Ball-Scroller** - Scroller text mapped onto a bouncing ball.

**Beast-Scroller** - "Shadow of the Beast" style scroller for parallax scrolling effects.

**Big-Scroller** - Extremely large text scroller.

**Bounce** - Simple bounce demos with movement logic.

**BrushZoom** - Zoom effects for brushes/sprites.

**Circles** - Circle test programs used as a basis for later effect building blocks.

**Converter** - Converter routines for transforming data formats in the demo pipeline.

**Copper-Animation** - Copper-driven animations with per-scanline color changes.

**Copper-Sinus-Scroller** - Sine-wave copper scroller.

**CPUFill** - Tests for fast framebuffer filling using CPU/blitter methods.

**Cracktro** - Cracktro code with intro structure and effects; full intro with music under 9 KB.

**Demands** - Smaller effect/screen tests for demo components.

**Dot-Scroller** - Dot scroller with text/graphics as a pixel matrix.

**DotFlag** - Dot-flag effects using a point-based flag.

**DS9-Intro** - Code and assets for a DS9 BBS intro; full intro with music under 9 KB.

**FunkyBall** - Variants of a ball effect.

**FW-Addtro** - FastWay addtro variant; full intro with music under 9 KB.

**Gurutro** - Guru Meditation intro.

**IntelOut** - Intro/outro for the IntelOutside effect.

**Intro1-Motion-Intro** - First motion intro.

**Intro2-JumpingChessfield** - Jumping chessfield effect.

**Intro3-Raster-Demo** - Raster dance demo with copper effects.

**Intro4-Motion-Intro-4** - Motion Intro 4.

**Intro5-Motion-Twist-Intro** - Motion twist intro.

**Intro6-Motion-Jump-Scroller** - Intro with jump scroller.

**Lines** - Line effects including laser variants.

**Liquid** - Liquid/wobble-like distortion effects with table-driven deformation.

**Logo-Waver-Wobble** - Combined logo waver/wobble effects with extensive tables.

**Logo-Wobble** - Logo wobble effects in many versions.

**Logo-Wobble-2-AGA** - AGA-specific logo wobble variants with adapted data formats.

**Makros** - Central macros and reusable includes used across many projects.

**No-Aga-No-Fun** - Effect routines around AGA/non-AGA dependencies.

**Parallax-Scroller** - Resources for parallax scrollers.

**Perspektivisches-Raster** - Perspective raster rendering with depth/projection effect.

**Plasma** - Plasma effects with multiple parameters.

**Quark** - Intro for the Quark demo group.

**Sing-Scroller** - Sing scroller with font converters.

**Sinus-Scroller** - Sine scroller.

**Spiel-8way-Scroller** - Game-capable 8-way scroller.

**Spirale-Twist** - Spiral/twist effects with sine tables.

**TainerMenu** - Trainer menu code.

**Tests** - Technical tests (Bresenham, sprites, display modes, number formats).

**Tunes** - Soundtracker files for demos.

**TypeWriter** - Typewriter effect.

**Zoom-Scroller** - Zoom scroller with sine tables.

**Zoom-Scroller2** - Second-generation zoom scroller with revised tables.

### Notes on Repository Structure
- Many version states per effect: this repo reflects a learning/experiment process rather than consolidated releases.
- Asset files without extensions are part of effect pipelines.
- For long-term maintainability, standardization and stabilization per effect would be beneficial.
