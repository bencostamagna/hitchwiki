#!/bin/bash

#
# Hitchwiki update script: update MediaWiki, its database, extensions and assets
#
# Usage:
#   "git pull"
#   "bash scripts/update.sh"
#

if [ ! -f Vagrantfile ]; then # an arbirtrary file that appears only once in the whole repository tree
    echo "ERROR: Bad working directory ($(pwd))."
    echo "Scripts have to be run from the root directory of the hitchwiki repository."
    echo "Aborting."
    exit 1
fi
source "scripts/_path_resolve.sh"
source "scripts/_settings.sh"

echo
echo "Update Hitchwiki dependencies using `composer.local.json`..."
cd "$WIKIDIR"
composer update --no-progress --no-interaction
echo
echo "-------------------------------------------------------------------------"

echo
echo "Update VisualEditor..."
cd "$WIKIDIR/extensions/VisualEditor"
git checkout -b $HW__general__mw_branch origin/$HW__general__mw_branch
git pull
git submodule update --init
echo
echo "-------------------------------------------------------------------------"

echo
echo "Run update script for MediaWiki..."
cd "$WIKIDIR"
php maintenance/update.php --doshared --quick --conf "$MWCONFFILE"
echo
echo "-------------------------------------------------------------------------"

echo
echo "Run update script for Semantic MediaWiki..."
cd "$WIKIDIR"
php extensions/SemanticMediaWiki/maintenance/SMW_refreshData.php -d 50 -v
echo
echo "-------------------------------------------------------------------------"

# Run some post-install scripts for a few extensions
# These are not run automatically so we'll just manually invoke them.
# https://github.com/composer/composer/issues/1193
cd "$WIKIDIR"
echo
echo "Run post-update-cmd for HWMap extension..."
composer run-script post-update-cmd -d ./extensions/HWMap
echo
echo "Run post-update-cmd for HitchwikiVector extension..."
composer run-script post-update-cmd -d ./extensions/HitchwikiVector
echo
echo "Run post-update-cmd for HWRatings extension..."
composer run-script post-update-cmd -d ./extensions/HWRatings
echo
echo "Run post-update-cmd for HWLocationInput extension..."
composer run-script post-update-cmd -d ./extensions/HWLocationInput
echo
echo "-------------------------------------------------------------------------"

# Localisation update
# https://www.mediawiki.org/wiki/Extension:LocalisationUpdate
#echo
#echo "Fetch latest localisation files..." # Update locales
#cd "$WIKIDIR"
#php extensions/LocalisationUpdate/update.php --quiet
#echo
#echo "-------------------------------------------------------------------------"

echo
echo "Import forms, templates etc..."
cd "$SCRIPTDIR"
bash ./scripts/import_pages.sh
echo
echo "-------------------------------------------------------------------------"

echo
echo "All done!"
