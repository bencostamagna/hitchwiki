<?php
/**
 * Settings for MediaWiki extensions
 *
 */


/**
 * VisualEditor
 * https://www.mediawiki.org/wiki/Extension:VisualEditor
 */
if(file_exists("$IP/extensions/VisualEditor/VisualEditor.php")) {
  wfLoadExtension('VisualEditor');
  // Enable by default for everybody
  $wgDefaultUserOptions['visualeditor-enable'] = 1;
  // Don't allow users to disable it
  $wgHiddenPrefs[] = 'visualeditor-enable';
  // OPTIONAL: Enable VisualEditor's experimental code features
  #$wgDefaultUserOptions['visualeditor-enable-experimental'] = 1;
  // URL to the Parsoid instance
  // MUST NOT end in a slash due to Parsoid bug
  // Use port 8142 if you use the Debian package
  $wgVisualEditorParsoidURL = 'http://' . $hwConfig["general"]["domain"] . ':8142';
  // Interwiki prefix to pass to the Parsoid instance
  // Parsoid will be called as $url/$prefix/$pagename
  $wgVisualEditorParsoidPrefix = $hwConfig["general"]["domain"];
}

/**
 * WikiEditor (code)
 * https://www.mediawiki.org/wiki/Extension:WikiEditor
 */
require_once "$IP/extensions/WikiEditor/WikiEditor.php";
# Enables use of WikiEditor by default but still allow users to disable it in preferences
$wgDefaultUserOptions['usebetatoolbar'] = 1;
$wgDefaultUserOptions['usebetatoolbar-cgd'] = 1;
# Displays the Preview and Changes tabs
$wgDefaultUserOptions['wikieditor-preview'] = 1;
# Displays the Publish and Cancel buttons on the top right side
$wgDefaultUserOptions['wikieditor-publish'] = 1;


/**
 * GeoCrumbs
 * https://www.mediawiki.org/wiki/Extension:GeoCrumbs
 */
wfLoadExtension('GeoCrumbs');

/**
 * GeoData
 * https://www.mediawiki.org/wiki/Extension:GeoData
 */
wfLoadExtension('GeoData');

/**
 * ExternalData
 * https://www.mediawiki.org/wiki/Extension:ExternalData
 */
wfLoadExtension('ExternalData');

/**
 * MultimediaViewer
 * https://www.mediawiki.org/wiki/Extension:MultimediaViewer
 */
wfLoadExtension('MultimediaViewer');
$wgMediaViewerEnableByDefaultForAnonymous = true;
$wgMediaViewerEnableByDefault = true;

/**
 * OAuth
 * The OAuth extension implements OAuth 1.0a
 * https://www.mediawiki.org/wiki/Extension:OAuth
 */
wfLoadExtension('OAuth');

/**
 * HeaderTabs
 * https://www.mediawiki.org/wiki/Extension:Header_Tabs
 */
wfLoadExtension('HeaderTabs');

/**
 * AddBodyClass
 * https://www.mediawiki.org/wiki/Extension:AddBodyClass
 * Rather unmaintained extension.
 * We should see if functionality of this extension is
 * redundant now, or perhaps we can do it ourselves.
 */
require_once "$IP/extensions/AddBodyClass/AddBodyClass.php";

/**
 * AdminLinks
 * Define "Special:AdminLinks" page, that holds links meant to be helpful for wiki administrators
 * https://www.mediawiki.org/wiki/Extension:AdminLinks
 */
require_once "$IP/extensions/AdminLinks/AdminLinks.php";
$wgGroupPermissions['my-group']['adminlinks'] = true;

/**
 * DismissableSiteNotice
 * This can be disabled after http://hitchwiki.org/en/MediaWiki:Sitenotice is no more needed.
 * http://www.mediawiki.org/wiki/Extension:DismissableSiteNotice
 */
require_once "$IP/extensions/DismissableSiteNotice/DismissableSiteNotice.php";

/**
 * Semantic MediaWiki extensions
 * https://semantic-mediawiki.org/wiki/Help:Installation#Installation
 *
 * `SemanticMediaWikiEnabled` file is created during first `vagrant up` command
 * from `./scripts/bootstrap_vagrant.sh` file. It's to ensure we don't load them
 * too early in process and cause DB errors.
 */
if(file_exists("$IP/extensions/SemanticMediaWikiEnabled")) {
  require_once "$IP/extensions/SemanticMediaWiki/SemanticMediaWiki.php";
  enableSemantics();
  require_once "$IP/extensions/Maps/Maps.php";
  require_once "$IP/extensions/SemanticWatchlist/SemanticWatchlist.php";
  wfLoadExtension('PageForms');

  // Sets whether help information on the edit page is displayed
  $smwgEnabledEditPageHelp = false;

  // You can have the set of values used for autocompletion in forms be cached, which may
  // improve performance. To do that, add something like the following to LocalSettings.php:
  $sfgCacheAutocompleteValues = true;
  $sfgAutocompleteCacheTimeout = 60 * 60 * 24; // 1 day (in seconds)
}

/**
 * ParserFunctions
 */
# Enable old string functions (needed at our semantic templates)
require_once "$IP/extensions/ParserFunctions/ParserFunctions.php";
$wgPFEnableStringFunctions = true;

/**
 * Interwiki links (nomadwiki, trashwiki etc)
 * - Grant sysops permissions to edit interwiki data
 * - See Database settings to understand how Interwiki settings are shared between wikis
 */
require_once "$IP/extensions/Interwiki/Interwiki.php";
$wgGroupPermissions['sysop']['interwiki'] = true;
// To create a new user group that may edit interwiki data
// (bureaucrats can add users to this group)
#$wgGroupPermissions['developer']['interwiki'] = true;

/**
 * Recent changes cleanup
 * https://www.mediawiki.org/wiki/Extension:Recent_Changes_Cleanup
 */
// require_once "$IP/extensions/RecentChangesCleanup/RecentChangesCleanup.php";
// $wgAvailableRights[] = 'recentchangescleanup';
// $wgGroupPermissions['sysop']['recentchangescleanup'] = true;
// $wgGroupPermissions['recentchangescleanup']['recentchangescleanup'] = true;

/**
 * CheckUser
 * https://www.mediawiki.org/wiki/Extension:CheckUser
 * Requires install, see scripts/vagrant_bootstrap.sh
 */
#require_once "$IP/extensions/CheckUser/CheckUser.php";
#$wgGroupPermissions['sysop']['checkuser'] = true;

/**
 * AntiSpoof
 * Preventing confusable usernames from being created.
 * It blocks the creation of accounts with mixed-script,
 * confusing and similar usernames.
 * https://www.mediawiki.org/wiki/Extension:AntiSpoof
 * Requires install, see scripts/vagrant_bootstrap.sh
 */
require_once "$IP/extensions/AntiSpoof/AntiSpoof.php";
$wgSharedTables[] = 'spoofuser';

/**
 * ReplaceText
 * Provides a special page to allow administrators to do a global string
 * find-and-replace on both the text and titles of the wiki's content pages.
 * https://www.mediawiki.org/wiki/Extension:Replace_Text
 */
require_once "$IP/extensions/ReplaceText/ReplaceText.php";
$wgGroupPermissions['bureaucrat']['replacetext'] = true;

/**
 * AbuseFilter
 * Allow privileged users to set specific controls on actions by users,
 * such as edits, and create automated reactions for certain behaviors.
 * https://www.mediawiki.org/wiki/Extension:AbuseFilter
 */
require_once "$IP/extensions/AbuseFilter/AbuseFilter.php";
$wgGroupPermissions['sysop']['abusefilter-modify'] = true;
$wgGroupPermissions['*']['abusefilter-log-detail'] = true;
$wgGroupPermissions['*']['abusefilter-view'] = true;
$wgGroupPermissions['*']['abusefilter-log'] = true;
$wgGroupPermissions['sysop']['abusefilter-private'] = true;
$wgGroupPermissions['sysop']['abusefilter-modify-restricted'] = true;
$wgGroupPermissions['sysop']['abusefilter-revert'] = true;

/**
 * Echo
 * https://www.mediawiki.org/wiki/Extension:Echo
 */
#require_once "$IP/extensions/Echo/Echo.php";
$wgEchoAgentBlacklist = array( 'Hitchbot', 'Hitchwiki' );


/**
 * EventLogging
 * Required by original `$wgVectorBetaPersonalBar` of
 * https://www.mediawiki.org/wiki/Extension:VectorBeta
 *
 * ...but since that was buggy and anyway not needed,
 * we forked that unmaintained extension and removed this feature.
 * Thus this isn't needed anymore
 * Fork: https://github.com/Hitchwiki/mediawiki-extensions-VectorBeta
 *
 * https://www.mediawiki.org/wiki/Extension:EventLogging
 */
// require_once "$IP/extensions/EventLogging/EventLogging.php";
// $wgEventLoggingBaseUri = 'http://'.$hwConfig["general"]["domain"].':8080/event.gif';
// $wgEventLoggingFile = "{$logDir}/events.log";

/**
 * Adds some new features to MediaWiki and Vector theme
 * https://www.mediawiki.org/wiki/Beta_Features
 * https://www.mediawiki.org/wiki/Extension:BetaFeatures
 * https://www.mediawiki.org/wiki/Extension:VectorBeta
 *
 * Features are forced to be enabled to everyone using
 * https://github.com/Hitchwiki/BetaFeatureEverywhere
 * ...since by default users would need to opt-in to beta features.
 */
wfLoadExtension('BetaFeatures');
wfLoadExtension('HWVectorBeta');
require_once "$IP/extensions/BetaFeatureEverywhere/BetaFeatureEverywhere.php";
$wgBetaFeaturesWhitelist = array('betafeatures-vector-typography-update', 'betafeatures-vector-fixedheader');
$wgBetaFeaturesWhitelistLoggedIn = array('betafeatures-vector-compact-personal-bar');
$wgDefaultUserOptions['betafeatures-vector-compact-personal-bar'] = '1';
$wgDefaultUserOptions['betafeatures-vector-typography-update'] = '1';
$wgDefaultUserOptions['betafeatures-vector-fixedheader'] = '1';
$wgVectorBetaTypography = true;
$wgVectorBetaPersonalBar = true;
$wgVectorBetaWinter = true;


/**
 * LocalisationUpdate
 * https://www.mediawiki.org/wiki/Extension:LocalisationUpdate
 */
wfLoadExtension( 'LocalisationUpdate' );
$wgLocalisationUpdateDirectory = "$IP/cache";

/**
 * Enables some features required by VectorBeta such as Special:MobileMenu
 * https://www.mediawiki.org/wiki/Extension:MobileFrontend
 */
require_once "$IP/extensions/MobileFrontend/MobileFrontend.php";
$wgMFAutodetectMobileView = true;
$wgMobileFrontendLogo = $wgScriptPath . "/../wiki-mobilelogo.png"; // Should be 35 × 22 px

/**
 * Rename user
 * https://www.mediawiki.org/wiki/Extension:Renameuser
 */
require_once "$IP/extensions/Renameuser/Renameuser.php";
$wgGroupPermissions['sysop']['renameuser'] = true;


/**
 * UploadWizard
 * https://www.mediawiki.org/wiki/Extension:UploadWizard
 */
wfLoadExtension('UploadWizard');
$wgUploadWizardConfig = array(
  'debug' => $hwDebug,
  #'autoCategory' => 'Uploaded with UploadWizard',
  #'feedbackPage' => '',
  'altUploadForm' => 'Special:Upload',
  'fallbackToAltUploadForm' => false,
  'enableFormData' => true,  # Should FileAPI uploads be used on supported browsers?
  'enableMultipleFiles' => true,
  'enableMultiFileSelect' => true,
  'tutorial' => array('skip' => true),
  'fileExtensions' => $wgFileExtensions # omitting this can cause errors
);
// Needed to make UploadWizard work in IE, see bug 39877
$wgApiFrameOptions = 'SAMEORIGIN';
$wgUploadNavigationUrl = '/'.$hwLang.'/Special:UploadWizard';
// This modifies the sidebar's "Upload file" link - probably in other places as well. More at Manual:$wgUploadNavigationUrl.
$wgExtensionFunctions[] = function() {
  $GLOBALS['wgUploadNavigationUrl'] = SpecialPage::getTitleFor( 'UploadWizard' )->getLocalURL();
  return true;
};


/**
 * Hitchwiki extensions
 * https://github.com/Hitchwiki/
 */
require_once "$IP/extensions/HitchwikiVector/HitchwikiVector.php"; // Customized theme based on `Vector` theme
require_once "$IP/extensions/HWMap/HWMap.php"; // Hitchwiki Maps (see `/Special:HWMap` page)
require_once "$IP/extensions/HWWaitingTime/HWWaitingTime.php"; // Waiting time -feature
require_once "$IP/extensions/HWRatings/HWRatings.php"; // "Hithability" ratings -feature
require_once "$IP/extensions/HWComments/HWComments.php"; // Comments -feature