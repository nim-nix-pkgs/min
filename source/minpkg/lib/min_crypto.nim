import
  base64,
  strutils,
  times,
  ../vendor/aes/aes
import
  ../core/parser, 
  ../core/value, 
  ../core/interpreter, 
  ../core/utils

{.compile: "../vendor/aes/libaes.c".}

when defined(ssl):
  import 
    openssl
  
  proc EVP_MD_CTX_new*(): EVP_MD_CTX {.cdecl, importc: "EVP_MD_CTX_new".}
  proc EVP_MD_CTX_free*(ctx: EVP_MD_CTX) {.cdecl, importc: "EVP_MD_CTX_free".}
else:
  import
      std/sha1,
      md5

proc crypto_module*(i: In)=
  let def = i.define()

  
  def.symbol("encode") do (i: In):
    let vals = i.expect("'sym")
    let s = vals[0]
    i.push s.getString.encode.newVal
    
  def.symbol("decode") do (i: In):
    let vals = i.expect("'sym")
    let s = vals[0]
    i.push s.getString.decode.newVal

  when defined(ssl):

    when defined(windows): 
      {.passL: "-static -Lminpkg/vendor/openssl/windows -lssl -lcrypto -lws2_32".}
    elif defined(linux):
      {.passL: "-static -Lminpkg/vendor/openssl/linux -lssl -lcrypto".}
    elif defined(macosx):
      {.passL: "-Bstatic -Lminpkg/vendor/openssl/macosx -lssl -lcrypto -Bdynamic".}

    proc hash(s: string, kind: EVP_MD, size: int): string =
      var hash_length: cuint = 0
      var hash = alloc[ptr uint8](size)
      let ctx = EVP_MD_CTX_new()
      discard EVP_DigestInit_ex(ctx, kind, nil)
      discard EVP_DigestUpdate(ctx, unsafeAddr s[0], s.len.cuint)
      discard EVP_DigestFinal_ex(ctx, hash, cast[ptr cuint](hash_length))
      EVP_MD_CTX_free(ctx)
      var hashStr = newString(size)
      copyMem(addr(hashStr[0]), hash, size)
      dealloc(hash)
      return hashStr.toHex.toLowerAscii[0..size-1]

    def.symbol("md5") do (i: In):
      let vals = i.expect("'sym")
      let s = vals[0].getString
      i.push hash(s, EVP_md5(), 32).newVal

    def.symbol("md4") do (i: In):
      let vals = i.expect("'sym")
      let s = vals[0].getString
      i.push hash(s, EVP_md4(), 32).newVal

    def.symbol("sha1") do (i: In):
      let vals = i.expect("'sym")
      var s = vals[0].getString
      i.push hash(s, EVP_sha1(), 40).newVal

    def.symbol("sha224") do (i: In):
      let vals = i.expect("'sym")
      let s = vals[0].getString
      i.push hash(s, EVP_sha224(), 56).newVal

    def.symbol("sha256") do (i: In):
      let vals = i.expect("'sym")
      let s = vals[0].getString
      i.push hash(s, EVP_sha256(), 64).newVal

    def.symbol("sha384") do (i: In):
      let vals = i.expect("'sym")
      let s = vals[0].getString
      i.push hash(s, EVP_sha384(), 96).newVal

    def.symbol("sha512") do (i: In):
      let vals = i.expect("'sym")
      let s = vals[0].getString
      i.push hash(s, EVP_sha512(), 128).newVal

    def.symbol("aes") do (i: In):
      let vals = i.expect("'sym", "'sym")
      let k = vals[0]
      let s = vals[1]
      var text = s.getString
      var key = hash(k.getString, EVP_sha1(), 40)
      var iv = hash((key & $getTime().toUnix), EVP_sha1(), 40)
      var ctx = cast[ptr AES_ctx](alloc0(sizeof(AES_ctx)))
      AES_init_ctx_iv(ctx, cast[ptr uint8](key[0].addr), cast[ptr uint8](iv[0].addr));
      var input = cast[ptr uint8](text[0].addr)
      AES_CTR_xcrypt_buffer(ctx, input, text.len.uint32);
      i.push text.newVal

  else:

    def.symbol("md5") do (i: In):
      let vals = i.expect("'sym")
      let s = vals[0].getString
      i.push newVal($toMD5(s))

    def.symbol("sha1") do (i: In):
      let vals = i.expect("'sym")
      var s = vals[0].getString
      i.push newVal(toLowerAscii($secureHash(s)))

    def.symbol("aes") do (i: In):
      let vals = i.expect("'sym", "'sym")
      let k = vals[0]
      let s = vals[1]
      var text = s.getString
      var key = ($secureHash(k.getString)).toLowerAscii
      var iv = ($secureHash((key & $getTime().toUnix))).toLowerAscii
      var ctx = cast[ptr AES_ctx](alloc0(sizeof(AES_ctx)))
      AES_init_ctx_iv(ctx, cast[ptr uint8](key[0].addr), cast[ptr uint8](iv[0].addr));
      var input = cast[ptr uint8](text[0].addr)
      AES_CTR_xcrypt_buffer(ctx, input, text.len.uint32);
      i.push text.newVal
      
  def.finalize("crypto")
