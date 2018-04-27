# Measurement Kit iOS API

Based on the new C `ffi.h` of Measurement Kit v0.9.0.

The expected usage is that we compile this piece of code and we link it all
together with all dependencies and the bulk of Measurement Kit, to make a single
framework that people can integrate. (Pretty much like we do now.)

The main difference will be that this API is ObjectiveC native and, given that
`ffi.h` is quite general, can be developed asynchronously of MK's core.

Currently experimental code. Do not use!!!
