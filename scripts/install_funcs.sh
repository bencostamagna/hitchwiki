#!/bin/bash

#
# Hitchwiki installation functions helper
#

set -e
# Makes sure we have settings.ini and "Bash ini parser"
source "$SCRIPTDIR/_settings.sh"

OK_SYMBOL="✅ "
SKIP_SYMBOL="🔀 "

# Print divider between setup blocks
print_divider()
{
  echo " "
  echo " "
  echo "-------------------------------------------------------------------------"
  echo " "
  echo " "
}

update_system()
{
  echo "$OK_SYMBOL Update system"
  sudo apt-get -qq update
  sudo apt-get -qq upgrade -y

  echo " "
  echo "$OK_SYMBOL Install helper tools"
  sudo apt-get -qq install -y \
    unattended-upgrades \
    vim \
    curl \
    git \
    unzip \
    zip \
    imagemagick \
    build-essential \
    python-software-properties \
    fail2ban;

  echo " "
  echo "$OK_SYMBOL Do apt-get purge & autoremove"
  sudo apt-get -qq --purge autoremove -y

  print_divider
}

print_versions()
{
  echo "$OK_SYMBOL System versions:"
  echo " "
  echo " "
  echo "Apache version:"
  apache2 -version
  echo " "
  echo "MariaDB version:"
  mysql -V
  echo " "
  echo "PHP version:"
  php -v
  echo " "
  echo "NPM version:"
  npm --version
  echo " "
  echo "Node.js version:"
  node --version
  echo " "
  echo "Bower version:"
  bower --version
  echo " "
  echo "OpenSSL version:"
  openssl version
  echo " "
  echo "Composer version:"
  composer --version

  print_divider
}

install_mariadb()
{
  echo "$OK_SYMBOL Add keys and repository for MariaDB"
  # https://downloads.mariadb.org/mariadb/repositories/#mirror=digitalocean-ams
  sudo apt-get -qq install -y --allow-unauthenticated software-properties-common
  sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
  sudo add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://ams2.mirrors.digitalocean.com/mariadb/repo/10.2/ubuntu xenial main'
  sudo apt-get -qq update

  echo "$OK_SYMBOL Configure MariaDB installation not to prompt for passwords"
  sudo debconf-set-selections <<< "mariadb-server-10.2 mysql-server/root_password password "$HW__db__password
  sudo debconf-set-selections <<< "mariadb-server-10.2 mysql-server/root_password_again password "$HW__db__password

  echo "$OK_SYMBOL Install MariaDB"
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get -qq install -y --allow-unauthenticated mariadb-server

  echo "$OK_SYMBOL Secure MariaDB root user"
  # `mysql_secure_installation` is interactive so doing the same directly in DB instead...
  # https://gist.github.com/Mins/4602864#gistcomment-1299116
  #mysqladmin -u $HW__db__username -p$HW__db__password password "$HW__db__password"
  mysql -u $HW__db__username -p$HW__db__password -e "UPDATE mysql.user SET Password=PASSWORD('$HW__db__password') WHERE User='$HW__db__username'"
  mysql -u $HW__db__username -p$HW__db__password -e "DELETE FROM mysql.user WHERE User='$HW__db__username' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
  mysql -u $HW__db__username -p$HW__db__password -e "DELETE FROM mysql.user WHERE User=''"
  mysql -u $HW__db__username -p$HW__db__password -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
  mysql -u $HW__db__username -p$HW__db__password -e "FLUSH PRIVILEGES"

  print_divider
}

install_apache()
{
  echo "$OK_SYMBOL Install Apache"
  sudo apt-get -qq install -y apache2

  echo "$OK_SYMBOL Enable SSL support in Apache"
  sudo a2enmod ssl
  # sudo a2ensite default-ssl

  echo "$OK_SYMBOL Enable Mod Rewrite in Apache"
  sudo a2enmod rewrite

  echo "$OK_SYMBOL Allowing Apache override to all"
  sudo sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

  echo "$OK_SYMBOL Configure Apache to serve `./public` folder"
  cd /etc/apache2/sites-available
  sudo ln -s /var/www/configs/apache-hitchwiki.conf hitchwiki.conf

  cd /etc/apache2/sites-enabled
  sudo rm -f 000-default.conf
  sudo ln -s ../sites-available/hitchwiki.conf hitchwiki.conf

  echo "$OK_SYMBOL Restart Apache"
  sudo service apache2 restart

  # Clean out folder created by Apache installer
  sudo rm -fr "$ROOTDIR/html"

  print_divider
}

install_php()
{
  echo "$OK_SYMBOL Install PHP and extensions"
  sudo apt-get -qq install -y \
    php7.0 \
    libapache2-mod-php7.0 \
    php7.0-mysql \
    php7.0-curl \
    php7.0-gd \
    php7.0-intl \
    php7.0-imap \
    php7.0-mcrypt \
    php7.0-pspell \
    php7.0-recode \
    php7.0-sqlite3 \
    php7.0-tidy \
    php7.0-xmlrpc \
    php7.0-xsl \
    php7.0-mbstring \
    php7.0-opcache \
    php-memcache \
    php-pear \
    php-imagick \
    php-apcu \
    php-gettext;

  echo -e "$OK_SYMBOL Turn on PHP errors"
  sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
  sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/apache2/php.ini

  echo "$OK_SYMBOL Restart Apache"
  sudo service apache2 restart

  print_divider
}

install_phpmyadmin()
{
  echo "$OK_SYMBOL Configure PHPMyAdmin installation not to prompt for passwords"
  sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
  sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
  sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-user string $HW__db__username"
  sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $HW__db__password"
  sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $HW__db__phpmyadmin_password"
  sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $HW__db__phpmyadmin_password"

  echo "$OK_SYMBOL Install PHPMyAdmin"
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get -qq install -y phpmyadmin

  #echo "Add PHPMyAdmin configuration to Apache"
  #sed -i -r "s:(Alias /).*(/usr/share/phpmyadmin):\1$PHPMYADMIN_DIR \2:" /etc/phpmyadmin/apache.conf

  print_divider
}

install_nodejs()
{
  echo "$OK_SYMBOL Install NodeJS"
  # https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
  curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
  sudo apt-get -qq install -y nodejs

  print_divider
}

install_mail_support()
{
  echo "$OK_SYMBOL Install PEAR mail, Net_SMTP, Auth_SASL and mail_mime..."
  sudo pear install mail
  sudo pear install Net_SMTP
  sudo pear install Auth_SASL
  sudo pear install mail_mime

  print_divider

  echo "$OK_SYMBOL Install Maildev for catching emails while developing"
  # https://github.com/djfarrelly/MailDev
  npm install -g -q maildev@1.0.0-rc3

  echo "$OK_SYMBOL Setup Maildev to start on reboot"
  # Automatically run maildev on start
  sudo cp scripts/init_maildev.sh /etc/init.d/maildev
  sudo chmod 755 /etc/init.d/maildev
  ln -s /etc/init.d/maildev /etc/rc3.d/S99maildev

  echo "$OK_SYMBOL Start Maildev"
  sudo sh /etc/init.d/maildev &>/dev/null &

  print_divider
}

# Install self signed SSL certificate if command line flag `--ssl` is set
# Remember to set `protocol` setting to `https` from `configs/settings.ini`
install_self_signed_ssl()
{
  if [[ $* == *--ssl* ]]; then
    echo "$OK_SYMBOL Setup self signed SSL certificate..."
    cd "$ROOTDIR"
    bash "$SCRIPTDIR/cert_selfsigned.sh"
  else
    echo "$SKIP_SYMBOL Skipped installing self signed SSL certificate. "
  fi

  print_divider
}

install_bower()
{
  echo "$OK_SYMBOL Install Bower"
  npm install -g -q bower@~1.8

  print_divider
}

install_composer()
{
  echo "$OK_SYMBOL Install Composer"
  cd "$ROOTDIR"

  # https://getcomposer.org/download/
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  # Verification hash might change over time so we can't rely on it here...
  # php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
  sudo php composer-setup.php --install-dir=/usr/local/bin # Intaller creates file `composer.phar`
  sudo ln -s /usr/local/bin/composer.phar /usr/local/bin/composer # Create symlink
  sudo rm composer-setup.php

  print_divider
}

install_mediawiki()
{
  echo "$OK_SYMBOL Download MediaWiki using Composer..."
  cd "$ROOTDIR"
  composer install --no-autoloader --no-dev --no-progress --no-interaction

  print_divider

  echo "$OK_SYMBOL Create cache directories..."
  mkdir -p "$ROOTDIR/tmp/sessions"
  mkdir -p "$WIKIDIR/cache"
  mkdir -p "$WIKIDIR/images/cache"

  echo "$OK_SYMBOL Create dumps directory..."
  sudo mkdir -p "$WIKIDIR/dumps"

  set_wiki_folder_permissions

  echo "$OK_SYMBOL Download basic MediaWiki extensions using Composer..."
  cd "$WIKIDIR"
  sudo ln -s "$CONFDIR/composer.local.json" composer.local.json
  sudo composer update --no-dev --no-progress --no-interaction

  print_divider

  # Run some post-install scripts for a few extensions
  # These are not run automatically so we'll just manually invoke them.
  # https://github.com/composer/composer/issues/1193
  cd "$WIKIDIR"
  echo "$OK_SYMBOL Run post-install-cmd for HWMap extension..."
  composer run-script post-install-cmd -d ./extensions/HWMap
  # solve_mw_maps_extension_bug
  echo
  echo "$OK_SYMBOL Run post-install-cmd for HitchwikiVector extension..."
  composer run-script post-install-cmd -d ./extensions/HitchwikiVector
  echo
  echo "$OK_SYMBOL Run post-install-cmd for HWRatings extension..."
  composer run-script post-install-cmd -d ./extensions/HWRatings
  echo
  echo "$OK_SYMBOL Run post-install-cmd for HWLocationInput extension..."
  composer run-script post-install-cmd -d ./extensions/HWLocationInput

  # Setup MediaWiki
  echo "$OK_SYMBOL Running Mediawiki install script..."
  # https://www.mediawiki.org/wiki/Manual:Installing_MediaWiki#Run_the_installation_script
  # Usage: php install.php [--conf|--confpath|--dbname|--dbpass|--dbpassfile|--dbpath|--dbport|--dbprefix|--dbschema|--dbserver|--dbtype|--dbuser|--env-checks|--globals|--help|--installdbpass|--installdbuser|--lang|--memory-limit|--pass|--passfile|--profiler|--quiet|--scriptpath|--server|--wiki] [name] <admin>
  #
  cd "$WIKIDIR"
  # Runs Mediawiki install script:
  # - sets up wiki in one language ("en")
  # - creates one admin user "hitchwiki" with password "authobahn"
  php maintenance/install.php --conf "$MWCONFFILE" \
  --dbuser $HW__db__username \
  --dbpass $HW__db__password \
  --dbname $HW__db__database \
  --dbtype mysql \
  --pass autobahn \
  --scriptpath /$WIKIFOLDER \
  --lang en \
  "$HW__general__sitename" \
  hitchwiki

  print_divider
}

# Install VisualEditor
# Since it requires submodules, we don't install this using composer
# https://www.mediawiki.org/wiki/Extension:VisualEditor
install_mw_visual_editor()
{
  echo "$OK_SYMBOL Install VisualEditor extension..."
  cd "$WIKIDIR/extensions"
  git clone \
  --branch $HW__general__mw_branch \
  --single-branch \
  --depth=1 \
  --recurse-submodules \
  --quiet \
  https://gerrit.wikimedia.org/r/p/mediawiki/extensions/VisualEditor.git \
  VisualEditor;

  print_divider
}

solve_mw_maps_extension_bug()
{
  # Stop Maps extension from setting up a {{#coordinates}} parser function hook
  # that conflicts with GeoData extensions's {{#coordinates}} parser function hook
  #
  # We are using GeoData's function in templates to index articles with spatial info
  #
  # TODO: any solution that is cleaner than this temporary dirty hack..
  #echo "Stop Maps extension from setting up a {{#coordinates}} parser function hook..."
  # sed -i -e '111i\ \ /*' -e '116i\ \ */' "$WIKIDIR/extensions/Maps/Maps.php" # wrap damaging lines of code as a /* comment */
  # sed -i -e '112i\ \ // This code block has been commented out by Hitchwiki install script. See scripts/server_install.sh for details\n' "$WIKIDIR/extensions/Maps/Maps.php"

  print_divider
}

create_db()
{
  # Prepare databases
  echo "$OK_SYMBOL Prepare databases..."
  mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS $HW__db__database"
  mysql -u$HW__db__username -p$HW__db__password -e "CREATE DATABASE $HW__db__database CHARACTER SET utf8 COLLATE utf8_general_ci"
  #IFS=$'\n' languages=($(echo "SHOW DATABASES;" | mysql -u$username -p$password | grep -E '^hitchwiki_..$' | sed 's/^hitchwiki_//g'))

  print_divider
}

setup_mediawiki()
{

  # Config file is stored elsewhere, require it from MW's LocalSettings.php
  echo "$OK_SYMBOL Point Mediawiki configuration to Hitchwiki configuration file..."
  cp -f "$SCRIPTDIR/configs/mediawiki_LocalSettings.php" "$WIKIDIR/LocalSettings.php"

  print_divider

  # Import interwiki table
  # https://www.mediawiki.org/wiki/Extension:Interwiki
  echo "$OK_SYMBOL Importing interwiki table..."
  cd "$ROOTDIR"
  mysql -u$HW__db__username -p$HW__db__password $HW__db__database < "$SCRIPTDIR/configs/interwiki.sql"

  print_divider

  echo "$OK_SYMBOL Setup database for several MW extensions (SemanticMediaWiki, AntiSpoof etc)..."
  # Mediawiki config file has a check for `SemanticMediaWikiEnabled` file:
  # basically SMW extensions are not included in MediaWiki before this
  # file exists, because it would cause errors when running
  # `maintenance/install.php`.
  touch "$WIKIDIR/extensions/SemanticMediaWikiEnabled"
  cd "$WIKIDIR"
  php maintenance/update.php --quick --conf "$MWCONFFILE"

  print_divider

  echo "$OK_SYMBOL Pre-populate the AntiSpoof extension's table..."
  cd "$WIKIDIR"
  php extensions/AntiSpoof/maintenance/batchAntiSpoof.php

  print_divider

  # Create bot users
  echo "$OK_SYMBOL Create MediaWiki users"
  cd "$ROOTDIR"
  bash "$SCRIPTDIR/create_users.sh"

  print_divider

  # Import Semantic pages, main navigation etc
  echo "$OK_SYMBOL Import Semantic templates and other MediaWiki special pages..."
  cd "$ROOTDIR"
  bash "$SCRIPTDIR/import_pages.sh"

  print_divider
}

# Install Parsoid
# Parsoid is a Node application required by VisualEditor extension
# https://www.mediawiki.org/wiki/Parsoid/Setup
install_parsoid()
{
  echo "$OK_SYMBOL Install Parsoid..."
  cd "$ROOTDIR"
  bash "$SCRIPTDIR/install_parsoid.sh"

  print_divider
}

set_wiki_folder_permissions()
{
  echo "$OK_SYMBOL Setting wiki folder permissions..."

  HW_OWNERS="${HW__general__webserver_user}:${HW__general__webserver_group}"

  sudo chown -R $HW_OWNERS "$ROOTDIR"
  # sudo chmod -R g+rw "$ROOTDIR"

  sudo chown -R $HW_OWNERS "$ROOTDIR/tmp/sessions"
  sudo chmod -R ug+rw "$ROOTDIR/tmp/sessions"

  sudo chown -R $HW_OWNERS "$WIKIDIR/images"
  sudo chmod -R ug+rw "$WIKIDIR/images"

  sudo chown -R $HW_OWNERS "$WIKIDIR/cache"
  sudo chmod -R ug+rw "$WIKIDIR/cache"

  print_divider
}
