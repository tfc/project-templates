_final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (python-final: _python-prev: {
      xor-neural-net = python-final.callPackage ./package.nix { };
    })
  ];
}
