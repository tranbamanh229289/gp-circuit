pragma circom 2.1.1;

include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/eddsaposeidon.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";

template KYCAge() {
  // public input
  signal input userId;
  signal input currentTime;
  signal input minAge;
  signal input claimSchemaHash;
  
  // private input
  signal input birthday;
  signal input documentType;
  signal input revocationNonce;
  signal input expTime;
  signal input claimIndexSlots[4];
  signal input claimValueSlots[4];
  
  // signature proof
  signal input issuerSigR8x;
  signal input issuerSigR8y;
  signal input issuerSigS;
  signal input issuerAuthPubKeyX;
  signal input issuerAuthPubKeyY;

  // output
  signal output isValid;

  // check input
  component schemaCheck = IsEqual();
  schemaCheck.in[0] <== claimIndexSlots[0];
  schemaCheck.in[1] <== claimSchemaHash;
  schemaCheck.out === 1;

  component userCheck = IsEqual();
  userCheck.in[0] <== claimIndexSlots[1];
  userCheck.in[1] <== userId;
  userCheck.out === 1;

  component birthdayCheck = IsEqual();
  birthdayCheck.in[0] <== claimIndexSlots[2];
  birthdayCheck.in[1] <== birthday;
  birthdayCheck.out === 1;

  component docTypeCheck = IsEqual();
  docTypeCheck.in[0] <== claimIndexSlots[3];
  docTypeCheck.in[1] <== documentType;
  docTypeCheck.out === 1;

  // check expiration: currentTime <= expTime
  component expTimeCheck = LessThan(32);
  expTimeCheck.in[0] <== currentTime;
  expTimeCheck.in[1] <== expTime;
  expTimeCheck.out === 1;

  // calculate real age
  signal birthYear <== birthday / 10000;
  signal birthMonthDay <== birthday - birthYear * 10000;
  signal currentYear <== currentTime / 10000;
  signal currentMonthDay <== currentTime - currentYear * 10000;
  signal age <== currentYear - birthYear;

  component lt = LessThan(32);
  lt.in[0] <== currentMonthDay;
  lt.in[1] <== birthMonthDay;
  signal realAge <== age - lt.out;

  // check realAge > minAge
  component geq = GreaterEqThan(8);
  geq.in[0] <== realAge;
  geq.in[1] <== minAge;
  geq.out === 1;

  // hash claim
  component indexHasher = Poseidon(4);
  component valueHasher = Poseidon(4);
  component claimHasher = Poseidon(2);
  for (var i = 0; i < 4; i ++) {
    indexHasher.inputs[i] <== claimIndexSlots[i];
  }
  signal indexHash <== indexHasher.out;

  for (var i = 0; i < 4; i ++) {
    valueHasher.inputs[i] <== claimValueSlots[i];
  }
  signal valueHash <== valueHasher.out;

  claimHasher.inputs[0] <== indexHash;
  claimHasher.inputs[1] <== valueHash;
  signal claimHash <== claimHasher.out;

  // verify issuer signature
  component verifier = EdDSAPoseidonVerifier();
  verifier.enabled <== 1;
  verifier.Ax <== issuerAuthPubKeyX;
  verifier.Ay <== issuerAuthPubKeyY;
  verifier.R8x <== issuerSigR8x;
  verifier.R8y <== issuerSigR8y;
  verifier.S <== issuerSigS;
  verifier.M <== claimHash;

  isValid <== 1;
}

component main {public [currentTime, minAge, userId, claimSchemaHash]} = AgeVerification();