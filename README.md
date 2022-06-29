# Bluespec Project done under SHAKTI

**Hardware accelerator for SHA3 encryption**:
SHA3 is an encryption algorithm and is the latest member of the Secure Hash Algorithm family of standards, released by NIST (National Institute of Standards and Technology). SHA-3 provides a secure one-way function which means that one can't reconstruct the input data from the hash output. More about SHA3: https://en.wikipedia.org/wiki/SHA-3


**Side Channel Analysis of SHAKTI's AES accelerators**:
AES accelerators have a major edge over AES software implementation in terms of throughput and side channel security. SHAKTI built three AES accelerators and the three of them are compared against each other for Hardware security using TVLA test. Bluespec is used to make the wrapper modules and detailed analysis can be found in the report.
