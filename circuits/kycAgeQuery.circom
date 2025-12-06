
pragma circom 2.1.1;

include "kyc/kycAge.circom";

/*
 public output signals:
 userID - user profile id
 merklized - `1` if claim is merklized
 issuerState - equals to issuerAuthState for sig, and to issuerCßßlaimIdenState for mtp
 nullifier - sybil resistant user identifier for session id
 linkID - linked proof identifier
*/
component main{public [requestID,
                       issuerID,
                       issuerClaimNonRevState,
                       claimSchema,
                       slotIndex,
                       claimPathKey,
                       operator,
                       value,
                       valueArraySize,
                       timestamp, 
                       isRevocationChecked,
                       proofType,
                       verifierID,
                       nullifierSessionID
                       ]} = KycAge(40, 32, 64);
