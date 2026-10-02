#!/bin/sh
# ---------------------------------------------------------------------------
# Maakt een Debian-pakket (.deb) van Advanced Html Designer.
#
# Uitvoeren ONDER LINUX, nadat het project in Lazarus (GTK2) gecompileerd is:
#
#     sh project/tools/make-deb.sh            (versie 1.1.0)
#     sh project/tools/make-deb.sh 1.2.0      (eigen versienummer)
#
# Resultaat: project/tools/deb/advanced-html-designer_<versie>_<arch>.deb
# Installeren:  sudo apt install ./advanced-html-designer_<versie>_<arch>.deb
# Verwijderen:  sudo apt remove advanced-html-designer
#
# Waarom een startscript?
# Het programma schrijft naast zijn eigen uitvoerbaar bestand (htd/temp.htd,
# previewN.html, DesignerDefaults.ini, talen.lng). In /opt mag een gewone
# gebruiker niet schrijven. Het startscript kopieert het programma daarom
# per gebruiker naar ~/.local/share/advanced-html-designer en start het
# vandaar. Eigen ontwerpen, instellingen en vertalingen blijven bij een
# update behouden; programma en help worden vervangen.
# ---------------------------------------------------------------------------
set -e

VERSION="${1:-1.1.0}"
PKG=advanced-html-designer
EXE_NAME="Advanced Html Designer"   # = Doelbestandsnaam in project1.lpi

TOOLS=$(cd "$(dirname "$0")" && pwd)
PROJECT=$(dirname "$TOOLS")
OUT="$TOOLS/deb"
ARCH=$(dpkg --print-architecture)

if [ ! -x "$PROJECT/$EXE_NAME" ]; then
  echo "Bouw eerst het programma in Lazarus: '$PROJECT/$EXE_NAME' ontbreekt." >&2
  exit 1
fi

STAGE="$OUT/${PKG}_${VERSION}_${ARCH}"
rm -rf "$STAGE"
mkdir -p "$STAGE/DEBIAN" \
         "$STAGE/opt/$PKG" \
         "$STAGE/usr/bin" \
         "$STAGE/usr/share/applications" \
         "$STAGE/usr/share/pixmaps"

# ------------------------------------------------------------------
# Programmabestanden (zelfde inhoud als de Windows-release-zip)
# ------------------------------------------------------------------
cp "$PROJECT/$EXE_NAME" "$STAGE/opt/$PKG/"
strip "$STAGE/opt/$PKG/$EXE_NAME" 2>/dev/null || true
cp "$PROJECT/talen.lng" "$STAGE/opt/$PKG/"
cp -r "$PROJECT/help" "$STAGE/opt/$PKG/help"
mkdir -p "$STAGE/opt/$PKG/htd"
# LICENSE: in de werkmap onder tools/publish, in de GitHub-repository bovenaan
for LIC in "$TOOLS/publish/LICENSE" "$PROJECT/../../LICENSE"; do
  if [ -f "$LIC" ]; then
    cp "$LIC" "$STAGE/opt/$PKG/LICENSE"
    break
  fi
done
echo "$VERSION" > "$STAGE/opt/$PKG/VERSION"

# ------------------------------------------------------------------
# Startscript
# ------------------------------------------------------------------
cat > "$STAGE/usr/bin/$PKG" <<EOF
#!/bin/sh
SRC=/opt/$PKG
DST="\${XDG_DATA_HOME:-\$HOME/.local/share}/$PKG"

if [ "\$(cat "\$DST/VERSION" 2>/dev/null)" != "\$(cat "\$SRC/VERSION")" ]; then
  mkdir -p "\$DST/htd"
  # Programma, help en licentie altijd vernieuwen
  cp -f "\$SRC/$EXE_NAME" "\$SRC/LICENSE" "\$DST/"
  rm -rf "\$DST/help"
  cp -r "\$SRC/help" "\$DST/help"
  # Vertalingen alleen de eerste keer (kunnen door de gebruiker bewerkt zijn)
  [ -f "\$DST/talen.lng" ] || cp "\$SRC/talen.lng" "\$DST/"
  cp -f "\$SRC/VERSION" "\$DST/VERSION"
fi

cd "\$DST"
exec "\$DST/$EXE_NAME" "\$@"
EOF
chmod 755 "$STAGE/usr/bin/$PKG"

# ------------------------------------------------------------------
# Menu-item en pictogram
# ------------------------------------------------------------------
# Kant-en-klare 48x48 PNG (gemaakt uit project1.ico), dus geen ImageMagick nodig
mkdir -p "$STAGE/usr/share/icons/hicolor/48x48/apps"
cp "$TOOLS/$PKG.png" "$STAGE/usr/share/icons/hicolor/48x48/apps/$PKG.png"
cp "$TOOLS/$PKG.png" "$STAGE/usr/share/pixmaps/$PKG.png"
ICON_LINE="Icon=$PKG"

cat > "$STAGE/usr/share/applications/$PKG.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Advanced Html Designer
Comment=HTML-tabellen en pagina's visueel ontwerpen
Exec=$PKG
$ICON_LINE
Terminal=false
Categories=Development;WebDevelopment;
EOF

# ------------------------------------------------------------------
# Pakketbeschrijving
# ------------------------------------------------------------------
SIZE=$(du -sk "$STAGE" | cut -f1)

cat > "$STAGE/DEBIAN/control" <<EOF
Package: $PKG
Version: $VERSION
Section: web
Priority: optional
Architecture: $ARCH
Depends: libc6, libgtk2.0-0, xdg-utils
Installed-Size: $SIZE
Maintainer: Willy Jansen <willyjansen@telenet.be>
Description: Visuele ontwerper voor HTML-tabellen en -pagina's
 Advanced Html Designer is een Lazarus-programma om HTML-tabellen,
 cellen en tekstblokken visueel te ontwerpen en als HTML te exporteren.
EOF

# Na installeren/verwijderen de menu- en pictogramcache vernieuwen,
# anders verschijnt het item soms pas na opnieuw aanmelden.
for SCRIPT in postinst postrm; do
  cat > "$STAGE/DEBIAN/$SCRIPT" <<'EOF'
#!/bin/sh
set -e
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
exit 0
EOF
done

# Rechten zoals dpkg ze verwacht
find "$STAGE" -type d -exec chmod 755 {} +
find "$STAGE" -type f -exec chmod 644 {} +
chmod 755 "$STAGE/usr/bin/$PKG" "$STAGE/opt/$PKG/$EXE_NAME" \
          "$STAGE/DEBIAN/postinst" "$STAGE/DEBIAN/postrm"

dpkg-deb --root-owner-group --build "$STAGE" "$OUT/${PKG}_${VERSION}_${ARCH}.deb"
rm -rf "$STAGE"

echo
echo "Klaar: $OUT/${PKG}_${VERSION}_${ARCH}.deb"
echo "Installeren met: sudo apt install \"$OUT/${PKG}_${VERSION}_${ARCH}.deb\""
