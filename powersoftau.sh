#!/bin/bash

set -e

powersoftau() {
    POWER="$1"  # Nhận power từ tham số

    echo "Starting Powers of Tau ceremony (power=$POWER)..."

    # 1. Start new ceremony
    echo "[1/3] Creating new ceremony..."
    time snarkjs powersoftau new bn128 $POWER pot${POWER}_0000.ptau

    # 2. Contribute
    echo "[2/3] Contributing to ceremony..."
    ENTROPY=$(head -c 64 /dev/urandom | od -An -tx1 -v | tr -d ' \n')
    time snarkjs powersoftau contribute \
        pot${POWER}_0000.ptau \
        pot${POWER}_0001.ptau \
        --name="First contribution" \
        -e="$ENTROPY"

    # 3. Prepare phase 2
    echo "[3/3] Preparing phase 2..."
    time snarkjs powersoftau prepare phase2 \
        pot${POWER}_0001.ptau \
        pot${POWER}_final.ptau

    # Cleanup
    rm -f pot${POWER}_0000.ptau pot${POWER}_0001.ptau

    echo ""
    echo "✓ Powers of Tau completed!"
    echo ""
    echo "Generated file: pot${POWER}_final.ptau"
    echo "Max constraints: $((2**POWER))"
    echo ""
    echo "Use this file for circuit setup:"
    echo "  snarkjs groth16 setup circuit.r1cs pot${POWER}_final.ptau circuit.zkey"
}

# Kiểm tra tham số
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 POWER" >&2
    echo "Example: ./powers-of-tau.sh 12" >&2
    echo "         ./powers-of-tau.sh 15" >&2
    echo "         ./powers-of-tau.sh 17" >&2
    exit 1
fi

POWER="$1"

mkdir -p build
cd build

powersoftau "$POWER"