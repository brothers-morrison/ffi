module Stage25() where

import Foreign.C
import Text.Parsec

foreign export ccall "stage25_blep" c_blep :: CString -> IO CString

c_blep cfoo = do
    foo <- peekCString (cfoo :: CString)
    let bar = ("[Stage 25: " ++ foo ++ "]") :: String
    (newCString bar) :: IO CString

