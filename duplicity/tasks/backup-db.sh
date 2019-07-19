#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get settings
source ${DIR}/conf/settings.sh

# Get running php containers and have wp-cli make a backup.
containers=$(docker ps -q -f name='-php')

for container in $containers
do
    # Ensure dump dir exists
    $(which docker) exec $container mkdir -p ${dumps_dir}
    # Clear old dumps (> 1 month)
    echo ">> [${container}] Clearing old dumps..."
    $(which docker) exec $container find ${dumps_dir} -type f -name '*.sql' -mtime +8 -delete
    echo ">> [${container}] Dumping database..."
    # Generate new dumnp
    $(which docker) exec $container wp db export - | gzip -7 -c > ${dumps_dir}/$(date +%Y.%m.%d).sql.gz
    echo ">> [${container}] Done."
    echo
    echo
done
