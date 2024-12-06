haskell-mode haskell-ts-mode

(language "{-# LANGUAGE "
          (p (completing-read "Extension: "
                              haskell-ghc-supported-extensions))
          " #-}")
