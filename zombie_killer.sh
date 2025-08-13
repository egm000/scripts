#!/bin/bash

echo "🔍 Searching for zombie processes..."

# Find zombie processes
ZOMBIES=$(ps -eo pid,ppid,state,cmd | awk '$3=="Z"')

if [ -z "$ZOMBIES" ]; then
    echo "✅ No zombie processes found."
    exit 0
fi

echo "⚠️ Zombie processes detected:"
echo "$ZOMBIES"
echo

# Extract parent PIDs of zombies
PARENTS=$(echo "$ZOMBIES" | awk '{print $2}' | sort | uniq)

for PPID in $PARENTS; do
    echo "Zombie parent process: PID $PPID"
    ps -p $PPID -o pid,cmd
    echo -n "Do you want to kill this parent process? [y/N]: "
    read -r ANSWER
    if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
        kill -9 "$PPID"
        echo "✅ Killed parent process $PPID"
    else
        echo "❌ Skipped killing parent process $PPID"
    fi
    echo
done

echo "🧹 Zombie cleanup attempt complete."
