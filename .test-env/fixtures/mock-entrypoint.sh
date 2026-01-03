#!/bin/bash
# Mock server entrypoint - accepts SSH connections for testing

# Generate SSH host keys if not present
if [[ ! -f /etc/ssh/ssh_host_rsa_key ]]; then
    ssh-keygen -A
fi

# Wait for testhost public key and add to authorized_keys (allow slow start)
for i in {1..60}; do
    if [[ -f /shared-ssh/testhost.pub ]]; then
        cat /shared-ssh/testhost.pub >> /root/.ssh/authorized_keys
        chmod 600 /root/.ssh/authorized_keys
        echo "[Mock Server] Added testhost public key"
        break
    fi
    sleep 1
done

echo "[Mock Server] Starting SSH on $(hostname) (${MOCK_SERVICE:-unknown})"

# Execute the main command (sshd)
exec "$@"
