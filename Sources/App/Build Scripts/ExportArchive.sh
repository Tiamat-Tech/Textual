#!/bin/sh

set -e

WORKING_PATH="${TEXTUAL_WORKSPACE_TEMP_DIR}/ArchiveTan"

mkdir -p "${WORKING_PATH}"

cd "${WORKING_PATH}"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

xcodebuild -exportArchive \
-exportOptionsPlist "${TEXTUAL_WORKSPACE_DIR}/Configurations/ExportArchiveConfiguration.plist" \
-archivePath "${ARCHIVE_PATH}" \
-exportPath "${WORKING_PATH}"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Zip product and send to notary
#
# Format to add notary to keychain:
#
# xcrun notarytool store-credentials "Textual Notary"
#	--apple-id "<e-mail address>"
#	--team-id <team id>
#	--password "<password>"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

WORKING_ZIP_PATH="./${FULL_PRODUCT_NAME}.zip"

zip -y -r -X "${WORKING_ZIP_PATH}" "./${FULL_PRODUCT_NAME}/"

xcrun notarytool submit "${WORKING_ZIP_PATH}" \
                   --keychain-profile "Textual Notary" \
                   --wait \
                   --verbose \
                   --progress

# Remove uploaded product
rm "${WORKING_ZIP_PATH}"

# Stable app
xcrun stapler staple --verbose "./${FULL_PRODUCT_NAME}/" 

# Create new zip with stapled app
zip -y -r -X "${WORKING_ZIP_PATH}" "./${FULL_PRODUCT_NAME}/"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Call `git` after `cd` into working path to make
# sure we are in a directory of a git repository.
GIT_COMMIT_HASH=`git rev-parse --short HEAD`

EXPORT_PATH="${HOME}/Desktop/Textual-${GIT_COMMIT_HASH}"

mkdir -p "${EXPORT_PATH}"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

if [ "${TEXTUAL_BUILT_AS_UNIVERSAL_BINARY}" == "1" ]; then
	ARCHSPEC_PATH="${EXPORT_PATH}/universal"
else
	ARCHSPEC_PATH="${EXPORT_PATH}/intel"
fi

mkdir -p "${ARCHSPEC_PATH}"

ZIP_EXPORT_PATH="${ARCHSPEC_PATH}/Textual.zip"

mv "${WORKING_ZIP_PATH}" "${ZIP_EXPORT_PATH}"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

BUNDLE_VERSION_LONG=$(/usr/libexec/PlistBuddy -c "Print \"CFBundleVersion\"" "./${FULL_PRODUCT_NAME}/Contents/Info.plist")
BUNDLE_VERSION_SHORT=$(/usr/libexec/PlistBuddy -c "Print \"CFBundleShortVersionString\"" "./${FULL_PRODUCT_NAME}/Contents/Info.plist")
BUNDLE_MINIMUM_TARGET=$(/usr/libexec/PlistBuddy -c "Print \"LSMinimumSystemVersion\"" "./${FULL_PRODUCT_NAME}/Contents/Info.plist")

echo "<?php

	/* Generated on: $(date) */
" > ./buildInfo.php

echo "	\$current_release_version_short = \"${BUNDLE_VERSION_SHORT}\";" >> ./buildInfo.php
echo "	\$current_release_version_long = \"${BUNDLE_VERSION_LONG}\";" >> ./buildInfo.php
echo "	\$current_release_version_signature = \"${GIT_COMMIT_HASH}\";" >> ./buildInfo.php
echo "	\$current_release_minimum_system_version = \"${BUNDLE_MINIMUM_TARGET}\";" >> buildInfo.php

mv "./buildInfo.php" "${EXPORT_PATH}"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

echo "<section class=\"main\">
	<section class=\"header\">Release Notes for ${BUNDLE_VERSION_LONG}</section>

	<section class=\"body\">

		<ul>" > ./buildLog.txt

git log --since='48 hours ago' --pretty=format:'			<li>%s</li>' >> ./buildLog.txt

echo "
		</ul>

	</section>
</section>

<!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->" >> ./buildLog.txt

mv "./buildLog.txt" "${EXPORT_PATH}"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

cd "${DWARF_DSYM_FOLDER_PATH}"

DYSM_EXPORT_PATH="${ARCHSPEC_PATH}/Debug symbols.zip"

zip -y -r -X "${DYSM_EXPORT_PATH}" *

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

rm -rf "${WORKING_PATH}"

exit 0;
