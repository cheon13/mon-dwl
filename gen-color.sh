#!/usr/bin/env bash
# Script pour générer le fichier de couleur de dwl
# il sera appeler à partir de config.def.h
#!/usr/bin/env bash

# Chemin absolu étendu vers ton fichier de thème utilisateur
THEME_FILE="$HOME/.config/dwl/theme.sh"
OUTPUT_H="color.h"

# Vérifier si le fichier de thème existe
if [ ! -f "$THEME_FILE" ]; then
    echo "Erreur : Fichier de thème introuvable à l'emplacement : $THEME_FILE"
    exit 1
fi

# Étape 1 : Sourcer le fichier pour chasser la variable focuscolor
FOCUS_HEX=$(bash -c "source $THEME_FILE; echo \$focuscolor")

# Étape 2 : Vérifier la validité
if [ -z "$FOCUS_HEX" ]; then
    echo "Erreur : Impossible de lire la variable 'focuscolor' dans $THEME_FILE."
    exit 1
fi

# Étape 3 : Générer le fichier color.h épuré
cat << EOF > "$OUTPUT_H"
/* Fichier généré automatiquement par gen-colors.sh - Ne pas modifier manuellement */
#ifndef DWL_COLOR_H
#define DWL_COLOR_H

/* #define FOCUS_COLOR_HEX 0x${FOCUS_HEX}*/
#define FOCUS_COLOR_HEX 0x${FOCUS_HEX}FF

#endif /* DWL_COLOR_H */
EOF

echo "Fichier $OUTPUT_H généré avec succès dans $(pwd)"
