# Plogue sforzando (native Linux VST3), patchet for NixOS: RPATH bakt inn og en
# no-op curl-shim (vendor-.deb krever CURL_OPENSSL_4, nixpkgs har CURL_GNUTLS_4).
{ pkgs, lib }:
let
  curlShimC = pkgs.writeText "curlshim.c" ''
    #include <stddef.h>
    /* sforzando bruker curl kun til nettverk (oppdateringssjekk), ikke lyd
       -> trygge no-op-stubber, versjonert som CURL_OPENSSL_4. */
    void* curl_easy_init(void){return NULL;}
    long  curl_easy_setopt(void*a,int b,...){return 0;}
    long  curl_easy_perform(void*a){return 1;}
    void  curl_easy_cleanup(void*a){}
    void* curl_mime_init(void*a){return NULL;}
    void* curl_mime_addpart(void*a){return NULL;}
    long  curl_mime_name(void*a,const char*b){return 0;}
    long  curl_mime_data(void*a,const char*b,size_t c){return 0;}
    void  curl_mime_free(void*a){}
  '';
  curlShimMap = pkgs.writeText "curlshim.map" ''
    CURL_OPENSSL_4 {
      global:
        curl_easy_init; curl_easy_setopt; curl_easy_perform; curl_easy_cleanup;
        curl_mime_init; curl_mime_addpart; curl_mime_name; curl_mime_data; curl_mime_free;
      local: *;
    };
  '';
in
pkgs.stdenv.mkDerivation rec {
  pname = "sforzando";
  version = "1.982";
  src = pkgs.fetchurl {
    url = "https://sforzando.s3.us-east-1.amazonaws.com/LINUX_plogue-sforzando_${version}_x86_64.zip";
    hash = "sha256-7ms1T9N1/50M4wgZaD9E07cSof5P9Tx35E3wNtqCqQA=";
  };
  nativeBuildInputs = [ pkgs.unzip pkgs.dpkg pkgs.patchelf pkgs.gcc ];
  buildInputs = with pkgs; [
    stdenv.cc.cc.lib pango cairo glib fontconfig zlib libpng
    libxcb libxcb-util libxkbcommon
  ];
  dontStrip = true;
  unpackPhase = ''
    runHook preUnpack
    unzip $src
    runHook postUnpack
  '';
  installPhase = ''
    runHook preInstall
    cd LINUX_plogue-sforzando_${version}_x86_64
    mkdir -p extract
    dpkg-deb -x plogue-aria_${version}_amd64.deb extract
    dpkg-deb -x plogue-sforzando_${version}_amd64.deb extract
    mkdir -p $out/opt $out/vst3
    cp -r extract/opt/Plogue $out/opt/Plogue
    cp -r extract/usr/lib/vst3/sforzando.vst3 $out/vst3/sforzando.vst3
    chmod -R u+w $out
    # curl-kompatibilitets-shim (unikt soname, kolliderer ikke med systemets curl)
    gcc -shared -fPIC -O2 -o $out/opt/Plogue/Aria/libcurl_ariacompat.so \
      ${curlShimC} -Wl,--version-script=${curlShimMap} \
      -Wl,-soname,libcurl_ariacompat.so
    rpath="${lib.makeLibraryPath buildInputs}"
    # motoren: bytt curl-avhengighet til shim; RPATH = $ORIGIN + libs
    patchelf --replace-needed libcurl.so.4 libcurl_ariacompat.so \
      $out/opt/Plogue/Aria/libAria.so
    patchelf --set-rpath '$ORIGIN':"$rpath" $out/opt/Plogue/Aria/libAria.so
    # ARIA-effektene
    for so in $out/opt/Plogue/Aria/Plugins/*.so; do
      patchelf --set-rpath "$rpath" "$so"
    done
    # selve VST3-plugin-en
    patchelf --set-rpath "$rpath" \
      $out/vst3/sforzando.vst3/Contents/x86_64-linux/sforzando.so
    runHook postInstall
  '';
  meta.description = "Plogue sforzando (native Linux VST3), NixOS-patchet";
}
