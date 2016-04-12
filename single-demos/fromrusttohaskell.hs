module Stage25() where

import Foreign.C
import Text.Parsec

foreign export ccall "blep" c_blep :: CString -> IO CString

c_blep cfoo = do
    foo <- peekCString (cfoo :: CString)
    let bar = ("Type-safe greetings: <" ++ foo ++ ">") :: String
    (newCString bar) :: IO CString

