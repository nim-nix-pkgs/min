{
  description = ''A tiny concatenative programming language and shell.'';

  inputs.flakeNimbleLib.owner = "riinr";
  inputs.flakeNimbleLib.ref   = "master";
  inputs.flakeNimbleLib.repo  = "nim-flakes-lib";
  inputs.flakeNimbleLib.type  = "github";
  inputs.flakeNimbleLib.inputs.nixpkgs.follows = "nixpkgs";
  
  inputs.src-min-v0_19_5.flake = false;
  inputs.src-min-v0_19_5.ref   = "refs/tags/v0.19.5";
  inputs.src-min-v0_19_5.owner = "h3rald";
  inputs.src-min-v0_19_5.repo  = "min";
  inputs.src-min-v0_19_5.type  = "github";
  
  inputs."nifty".owner = "nim-nix-pkgs";
  inputs."nifty".ref   = "master";
  inputs."nifty".repo  = "nifty";
  inputs."nifty".dir   = "v1_2_2";
  inputs."nifty".type  = "github";
  inputs."nifty".inputs.nixpkgs.follows = "nixpkgs";
  inputs."nifty".inputs.flakeNimbleLib.follows = "flakeNimbleLib";
  
  outputs = { self, nixpkgs, flakeNimbleLib, ...}@deps:
  let 
    lib  = flakeNimbleLib.lib;
    args = ["self" "nixpkgs" "flakeNimbleLib" "src-min-v0_19_5"];
    over = if builtins.pathExists ./override.nix 
           then { override = import ./override.nix; }
           else { };
  in lib.mkRefOutput (over // {
    inherit self nixpkgs ;
    src  = deps."src-min-v0_19_5";
    deps = builtins.removeAttrs deps args;
    meta = builtins.fromJSON (builtins.readFile ./meta.json);
  } );
}