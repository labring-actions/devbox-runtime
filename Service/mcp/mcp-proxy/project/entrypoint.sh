#!/bin/bash

app_env=${1:-development}

source /home/devbox/project/.venv/bin/activate

export PYTHONPATH=$PYTHONPATH:/home/devbox/project

dev_commands() {
    echo "Running development environment commands..."
    cd /home/devbox/project && python -m project
}

prod_commands() {
    echo "Running production environment commands..."
    cd /home/devbox/project && python -m project
}

if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ]; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi

deactivate
