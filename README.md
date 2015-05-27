# Magento Audit Toolbox

The `generate-reports.sh` script generates various reports on a Magento installation that are useful as foundation for a shop audit.

## Usage

Copy the files of this repository into a Magento installation (Using a development environment and not the live system is strongly recommended):

    wget https://github.com/schmengler/magento-audit/tarball/master -O  | tar -xz

Run the script:

    ./generate-reports.sh

**Warning:** The script will download a clean Magento source from the Magento website to run comparisons and some addons for n98-magerun and phpcs from Github, all to the user's home directory.

When it's done, you will find the results in `var/audit`:

 - `modules.csv`: List of all modules and their status (active or inactive)
 - `module-updates-from-connect.csv`: List of extensions that have been installed via Magento Connect and can be updated
 - `sysinfo.csv`: General information about the Magento instance
 - `codepooloverrides.html`: Overridden core classes in `app/code/local`
 - `corehacks.html`: Modified core files
 - `rewrites.csv`: List of all class rewrites
 - `rewrite-conflicts.xml`: Conflicting class rewrites
 - `phpcs.csv`: Report from code sniffer about coding standard violations and possible problems