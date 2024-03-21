{
  description = "The Non-Steam App Toolkit";

  outputs = { self, nixpkgs, }:
    let
      pkgsFor = nixpkgs.legacyPackages;
      systems = [ "aarch64-linux" "i686-linux" "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      mkDate = longDate:
        with builtins;
        (concatStringsSep "-" [
          (substring 0 4 longDate)
          (substring 4 2 longDate)
          (substring 6 2 longDate)
        ]);
    in {
      packages = forAllSystems (system: {
        default = with pkgsFor.${system};
          let
            stub = writeScript "nostatoo" ''
              #!${ruby}/bin/ruby

              require_relative "../share/nostatoo/nostatoo"
            '';
          in stdenv.mkDerivation {
            name = "nostatoo";
            version = mkDate (self.lastModifiedDate or "19700101") + "_"
              + (self.shortRev or "dirty");

            src = self;

            installPhase = ''
              runHook preInstall

              mkdir -p $out/share/nostatoo
              cp -r -t $out/share/nostatoo lib nostatoo.rb COPYING

              mkdir -p $out/bin
              cp ${stub} $out/bin/nostatoo

              runHook postInstall
            '';
          };
      });
    };
}
