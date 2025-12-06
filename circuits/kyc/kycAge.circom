pragma circom 2.1.1;

include "../offchain/credentialAtomicQueryV3OffChain.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/eddsaposeidon.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";

template KYCAge(issuerLevels, claimLevels, maxValueArraySizeß) {
    signal output userID;

    signal output {binary} merklized;
    signal input proofType;

    signal output issuerState;

    signal input linkNonce;
    signal output linkID;

    signal input nullifierSessionID;
    signal output nullifier;

    signal output operatorOutput;
    
    signal input proofType;
    signal input requestID;
    signal input userGenesisID;
    signal input profileNonce;
    signal input claimSubjectProfileNonce;
    signal input issuerID;
    signal input verifierID;
    signal input timestamp;

    // MTP
    signal input issuerClaim[8];
    signal input issuerClaimMtp[issuerLevels];
    signal input issuerClaimNonRevMtp[issuerLevels];
    signal input issuerClaimNonRevMtpNoAux;
    signal input issuerClaimNonRevMtpAuxHi;
    signal input issuerClaimNonRevMtpAuxHv;
    signal input issuerClaimClaimsTreeRoot;
    signal input issuerClaimRevTreeRoot;
    signal input issuerClaimRootsTreeRoot;
    signal input issuerClaimIdenState;
    signal input isRevocationChecked;

    // Sig
    signal input issuerAuthClaim[8];
    signal input issuerAuthClaimMtp[issuerLevels];
    signal input issuerAuthClaimNonRevMtp[issuerLevels];
    signal input issuerAuthClaimNonRevMtpNoAux;
    signal input issuerAuthClaimNonRevMtpAuxHi;
    signal input issuerAuthClaimNonRevMtpAuxHv;
    signal input issuerAuthClaimsTreeRoot;
    signal input issuerAuthRevTreeRoot;
    signal input issuerAuthRootsTreeRoot;
    signal input issuerAuthState;
    signal input issuerClaimsSignaturesR8x;
    signal input issuerClaimsSignaturesR8y;
    signal input issuerClaimsSignatureS;

    signal input issuerClaimNonRevClaimsTreeRoot;
    signal input issuerClaimNonRevRevTreeRoot;
    signal input issuerClaimNonRevRootsTreeRoot;
    signal input issuerClaimNonRevState;

    // Query
    signal input claimSchema;
    signal input slotIndex;
    signal input operator;
    signal input value[maxValueArraySize];
    signal input valueArraySize;

    signal input claimPathKey;
    signal input claimPathValue;
    signal input claimPathMtp[claimsLevels]
    signal input claimPathMtpNoAux;
    signal input claimPathMtpAuHi;
    signal input claimPathMtpAuxHv;

    (merklized, userID, issuerState, linkID, nullifier, operatorOutput) <== credentialAtomicQueryV3OffChain(issuerLevels, claimLevels, maxValueArraySize)(
        proofType <== proofType,
        requestID <== requestID,
        userGenesisID <== genesisID,
        profileNonce <== profileNonce,
        claimSubjectProfileNonce <== claimSubjectProfileNonce,
        issuerID <== issuerID,
        isRevocationChecked <== isRevocationChecked,
        issuerClaimNonRevMtp <== issuerClaimNonRevMtp,
        issuerClaimNonRevMtpNoAux <== issuerClaimNonRevMtpNoAux,
        issuerClaimNonRevMtpAuxHi <== issuerClaimNonRevMtpAuxHi,
        issuerClaimNonRevMtpAuxHv <== issuerClaimNonRevMtpAuxHv,
        issuerClaimNonRevClaimsTreeRoot <== issuerClaimNonRevClaimsTreeRoot,
        issuerClaimNonRevRevTreeRoot <== issuerClaimNonRevRevTreeRoot,
        issuerClaimNonRevState <== issuerClaimNonRevState,
        timestamp <== timestamp,
        claimSchema <== claimSchema,
        claimPathMtp <== claimPathMtp,
        claimPathMtpNoAux <== claimPathMtpNoAux,
        claimPathMtpNoAuxHi <== claimPathMtpNoAuxHi,
        claimPathMtpNoAuxHv <== claimPathMtpNoAuxHv,
        claimPathKey <== claimPathKey,
        claimPathValue <== claimPathValue,
        slotIndex <== slotIndex,
        operator <== operator,
        value <== value,
        valueArraySize <== valueArraySize,
        issuerClaim <== issuerClaim,
        issuerClaimMtp <== issuerClaimMtp,
        issuerClaimClaimsTreeRoot <== issuerClaimClaimsTreeRoot,
        issuerClaimRevTreeRoot <== issuerClaimRevTreeRoot,
        issuerClaimRootsTreeRoot <== issuerClaimRootsTreeRoot,
        issuerClaimIdenState <== issuerClaimIdenState,
        issuerAuthClaim <== issuerClaim,
        issuerAuthClaimMtp <== issuerAuthClaimMtp,
        issuerAuthClaimsTreeRoot <== issuerAuthClaimsTreeRoot,
        issuerAuthRevTreeRoot <== issuerAuthRevTreeRoot,
        issuerAuthRootsTreeRoot <== issuerAuthRootsTreeRoot,
        issuerAuthState <== issuerAuthClaim,
        issuerAuthClaimNonRevMtp <== issuerAuthClaimNonRevMtp,
        issuerAuthClaimNonRevMtpNoAux <== issuerAuthClaimNonRevMtpNoAux,
        issuerAuthClaimNonRevMtpAuxHi <== issuerAuthClaimNonRevMtpAuxHi,
        issuerAuthClaimNonRevMtpAuxHv <== issuerAuthClaimNonRevMtpAuxHv,
        issuerClaimSignatureR8x <== issuerClaimSignatureR8x,
        issuerClaimSignatureR8y <== issuerClaimSignatureRy,
        issuerClaimSignatureS <== issuerClaimSignatureS,
        linkNonce <== linkNonce,
        verifierID <== verifierID,
        nullifierSessionID <== nullifierSessionIDß,ß
    )

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
}

component main {public [currentTime, minAge, userId, claimSchemaHash]} = AgeVerification();