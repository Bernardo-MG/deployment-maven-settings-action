#!/bin/sh
#
# Function for creating the Maven settings file for the CI process, storing it in the
# ~/settings.xml path.
#
# It will take care of two pieces of data:
# - Servers settings
# - Active profile
#
# Server settings will be read by Maven from the environmental variables, and this
# file will tell him so.
#
# The active profile will depend on the type of version the current code is for.
# Depending on if this is a release or a development version.
#
# REMEMBER: For security reasons the data stored in the generated file should not be
# shared. Never print it on the console or let it be accessed in any way.
#
# --- SERVERS ---
#
# A total of four servers will be set:
# - releases: for deploying release artifacts
# - site: for deploying the Maven site for the release version
# - snapshots: for deploying snapshot artifacts
# - site-development: for deploying the Maven site for the development version
#
# --- ENVIRONMENTAL VARIABLES ---
#
# The following environmental variables are required by the script:
#
# - DEPLOY_USER: string, user for the releases repo
# - DEPLOY_PASSWORD: string, password for the releases repo
#
# - DEPLOY_DEVELOP_USER: string, user for the development repo
# - DEPLOY_DEVELOP_PASSWORD: string, password for the development repo
#
# - DEPLOY_DOCS_USER: string, user for the releases documentation site repo
# - DEPLOY_DOCS_PASSWORD: string, password for the releases documentation site repo
#
# - DEPLOY_DOCS_DEVELOP_USER: string, user for the development documentation site repo
# - DEPLOY_DOCS_DEVELOP_PASSWORD: string, password for the development documentation site repo
#
# - DEPLOY_DOCS_SITE: string, path for deploying the Maven site
# - DEPLOY_DOCS_DEVELOP_SITE: string, path for deploying the development Maven site
#

# Fails if any commands returns a non-zero value
set -e

settings_path="settings.xml"

# The contents of the file are created
{
   echo "<settings>";

   # ----------------
   # Servers settings
   # ----------------

   echo "<servers>";

   # Release artifacts server
   if [ -n "${DEPLOY_USER}" ]; then
      echo "<server>";
         echo "<id>releases</id>";
         echo "<username>${DEPLOY_USER}</username>";
         echo "<password>${DEPLOY_PASSWORD}</password>";
      echo "</server>";
   fi
   # Release site server
   if [ -n "${DEPLOY_DOCS_USER}" ]; then
      echo "<server>";
         echo "<id>site</id>";
         echo "<username>${DEPLOY_DOCS_USER}</username>";
         echo "<password>${DEPLOY_DOCS_PASSWORD}</password>";
         echo "<configuration>";
            echo "<strictHostKeyChecking>no</strictHostKeyChecking>";
            echo "<preferredAuthentications>publickey,password</preferredAuthentications>";
            echo "<interactive>false</interactive>";
         echo "</configuration>";
      echo "</server>";
   fi

   # Development artifacts server
   if [ -n "${DEPLOY_DEVELOP_USER}" ]; then
      echo "<server>";
         echo "<id>snapshots</id>";
         echo "<username>${DEPLOY_DEVELOP_USER}</username>";
         echo "<password>${DEPLOY_DEVELOP_PASSWORD}</password>";
      echo "</server>";
   fi
   # Development site server
   if [ -n "${DEPLOY_DOCS_DEVELOP_USER}" ]; then
      echo "<server>";
         echo "<id>site-development</id>";
         echo "<username>${DEPLOY_DOCS_DEVELOP_USER}</username>";
         echo "<password>${DEPLOY_DOCS_DEVELOP_PASSWORD}</password>";
         echo "<configuration>";
            echo "<strictHostKeyChecking>no</strictHostKeyChecking>";
            echo "<preferredAuthentications>publickey,password</preferredAuthentications>";
            echo "<interactive>false</interactive>";
         echo "</configuration>";
      echo "</server>";
   fi

   echo "</servers>";
   
   # --------
   # Profiles
   # --------
   
   echo "<profiles>";
   
      echo "<profile>";
         echo "<id>deployment_site</id>"
         # This profile is used to define the deployment site URL
         echo "<properties>"
            # Release site
            echo "<site.release.url>${DEPLOY_DOCS_SITE}</site.release.url>"
            # Development site
            echo "<site.develop.url>${DEPLOY_DOCS_DEVELOP_SITE}</site.develop.url>"
         echo "</properties>"
      echo "</profile>";

   echo "</profiles>";

   # --------------
   # Active profile
   # --------------

   # These profiles are used to set configuration specific to a version type
   echo "<activeProfiles>"
      echo "<activeProfile>deployment_site</activeProfile>"
   echo "</activeProfiles>"

   echo "</settings>";
} >> ${settings_path}

echo "Created Maven settings file at ${settings_path}"

exit 0
