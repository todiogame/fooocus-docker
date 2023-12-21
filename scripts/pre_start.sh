#!/usr/bin/env bash
export PYTHONUNBUFFERED=1

echo "Container is running"

# Sync venv to workspace to support Network volumes
echo "Syncing venv to workspace, please wait..."
rsync -au /venv/ /workspace/venv/

# Sync Fooocus to workspace to support Network volumes
echo "Syncing Fooocus to workspace, please wait..."
rsync -au /Fooocus/ /workspace/Fooocus/

# Fix the venv to make it work from /workspace
echo "Fixing venv..."
/fix_venv.sh /venv /workspace/venv

# Create logs directory
mkdir -p /workspace/logs

if [[ ${DISABLE_AUTOLAUNCH} ]]
then
    echo "Auto launching is disabled so the application will not be started automatically"
    echo "You can launch it manually:"
    echo ""
    echo "   cd /workspace/Fooocus"
    echo "   deactivate && source /workspace/venv/bin/activate"
    echo "   python3 entry_with_update.py --listen --port 3001"
else
    echo "Starting Fooocus"
    export HF_HOME="/workspace"
    source /workspace/venv/bin/activate
    cd /workspace/Fooocus

    if [[ ${PRESET} ]]
    then
        echo "Starting Fooocus using preset: ${PRESET}"
        nohup python3 entry_with_update.py --listen --port 3001 --preset ${PRESET} > /workspace/logs/fooocus.log 2>&1 &
    else
        echo "Starting Fooocus using defaults"
        nohup python3 entry_with_update.py --listen --port 3001 > /workspace/logs/fooocus.log 2>&1 &
    fi

    echo "Fooocus started"
    echo "Log file: /workspace/logs/fooocus.log"
    deactivate
fi

echo "All services have been started"