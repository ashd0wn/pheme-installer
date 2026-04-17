#!/usr/bin/env bash

##############################################################################
# setup_pheme_build
##############################################################################

### Build
cd /var/pheme/www/frontend

# Simple way to switch to production
export NODE_ENV=production

# Pull Node Dependencies
npm ci --include=dev

# Build Pheme Frontend Scripts
npm run build

cd $installerHome
